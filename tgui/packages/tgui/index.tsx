/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

// Themes
import './styles/main.scss';

import { perf } from 'common/perf';
import { setupGlobalEvents } from 'tgui-core/events';
import { setupHotKeys } from 'tgui-core/hotkeys';
import { setupHotReloading } from 'tgui-dev-server/link/client';

import { App } from './App';
import { setGlobalStore } from './backend';
import { captureExternalLinks } from './links';
import { render } from './renderer';
import { configureStore } from './store';

perf.mark('inception', window.performance?.timeOrigin);
perf.mark('init');

const store = configureStore();

function setupByondMapRefocusPolicy() {
  const ByondAny = (window as any).Byond;

  const refocusMap = () => {
    try {
      ByondAny?.command?.('tgui_refocus_map');
    } catch {}
  };

  const isTextTarget = (el: Element | null) => {
    if (!el) return false;

    const ht = el as HTMLElement;
    const tag = el.tagName?.toLowerCase();

    if (tag === 'input' || tag === 'textarea' || tag === 'select') return true;
    if (ht.isContentEditable) return true;

    return !!el.closest?.(
      'input, textarea, select, [contenteditable="true"]',
    );
  };

  const scheduleRefocus = (target: Element | null) => {
    if (isTextTarget(target)) return;
    queueMicrotask(refocusMap);
  };

  // Любой клик по UI -> после обработки клика вернуть фокус карте
  document.addEventListener(
    'pointerdown',
    (e) => {
      scheduleRefocus(e.target as Element | null);
    },
    true,
  );

  // Иногда pointerup надежнее для некоторых интерактивов
  document.addEventListener(
    'pointerup',
    (e) => {
      scheduleRefocus(e.target as Element | null);
    },
    true,
  );

  // Escape/Enter вне ввода -> вернуть фокус карте
  document.addEventListener(
    'keydown',
    (e) => {
      if (e.key !== 'Escape' && e.key !== 'Enter') return;
      if (isTextTarget(document.activeElement as any)) return;
      queueMicrotask(refocusMap);
    },
    true,
  );

  // Один раз на старте — если tgui открылся с фокусом
  queueMicrotask(refocusMap);
}

function setupApp() {
  // Delay setup
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', setupApp);
    return;
  }

  setGlobalStore(store);

  setupGlobalEvents();

  // ОСТАВЛЯЕМ: tgui всё равно шлёт KeyDown/KeyUp вербы,
  // а фокус мапы решаем отдельной политикой (ниже).
  setupHotKeys({
    keyUpVerb: 'KeyUp',
    keyDownVerb: 'KeyDown',
    verbParamsFn: (verb, key) => `${verb} "${key}" 0 0 0 0`,
  });

  setupByondMapRefocusPolicy();
  captureExternalLinks();

  store.subscribe(() => render(<App />));

  // Dispatch incoming messages as store actions
  Byond.subscribe((type, payload) => store.dispatch({ type, payload }));

  // Enable hot module reloading
  if (import.meta.webpackHot) {
    setupHotReloading();
    import.meta.webpackHot.accept(
      ['./debug', './layouts', './routes', './App'],
      () => {
        render(<App />);
      },
    );
  }
}

setupApp();
