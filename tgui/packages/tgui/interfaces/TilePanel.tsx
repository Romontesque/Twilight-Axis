// TilePanel.tsx

import type React from 'react';
import { useMemo, useState } from 'react';
import { useBackend } from 'tgui/backend';
import { Window } from 'tgui/layouts';
import { Icon, Input, NoticeBox, Stack } from 'tgui-core/components';

type TileAtom = {
  name: string;
  ref: string;
  img64?: string | null;
  is_turf?: boolean;
};

type Data = {
  has_target: boolean;
  name?: string;
  atoms?: TileAtom[];
};

const TRUNCATE_LENGTH = 20;

const truncate20 = (s: string) => {
  if (!s) return '';
  return s.length > TRUNCATE_LENGTH
    ? `${s.slice(0, TRUNCATE_LENGTH - 1)}…`
    : s;
};

export const TilePanel = () => {
  const { act, data } = useBackend<Data>();
  const [query, setQuery] = useState('');

  const atoms = data.atoms || [];

  const turfAtom = useMemo(() => atoms.find((a) => a.is_turf), [atoms]);
  const otherAtoms = useMemo(() => atoms.filter((a) => !a.is_turf), [atoms]);

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    if (!q) return otherAtoms;
    return otherAtoms.filter((a) =>
      (a.name || '').toLowerCase().includes(q),
    );
  }, [otherAtoms, query]);

  const title = data.has_target ? (data.name || 'Tile') : 'Tile Panel';

  const sendInteract = (atomRef: string, e: React.MouseEvent) => {
    if (e.button === 2) {
      e.preventDefault();
    }

    act('interact', {
      ref: atomRef,
      button: e.button,
      shift: e.shiftKey ? 1 : 0,
      ctrl: e.ctrlKey ? 1 : 0,
      alt: e.altKey ? 1 : 0,
    });
  };

  const renderCard = (a: TileAtom) => (
    <div
      key={a.ref}
      role="button"
      tabIndex={0}
      onContextMenu={(e) => e.preventDefault()}
      onMouseDown={(e) => sendInteract(a.ref, e)}
      style={{
        width: '86px',
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        padding: '6px',
        border: '1px solid rgba(255,255,255,0.12)',
        borderRadius: '4px',
        background: 'rgba(0,0,0,0.15)',
        cursor: 'pointer',
        userSelect: 'none',
      }}
      title={a.name}
    >
      <div
        style={{
          width: '64px',
          height: '64px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        {a.img64 ? (
          <img
            src={`data:image/png;base64,${a.img64}`}
            style={{
              maxWidth: '64px',
              maxHeight: '64px',
              imageRendering: 'pixelated',
            }}
          />
        ) : (
          <Icon name="cube" />
        )}
      </div>

      <div
        style={{
          marginTop: '6px',
          width: '100%',
          textAlign: 'center',
          fontSize: '11px',
          lineHeight: '12px',
          overflow: 'hidden',
          whiteSpace: 'nowrap',
          textOverflow: 'ellipsis',
        }}
      >
        {truncate20(a.name)}
      </div>
    </div>
  );

  return (
    <Window width={330} height={400} title={title}>
      <Window.Content>
        {!data.has_target ? (
          <NoticeBox>No turf selected.</NoticeBox>
        ) : (
          <Stack vertical fill>
            <Stack align="center">
              <Stack.Item grow>
                <Input
                  fluid
                  placeholder="Search..."
                  value={query}
                  onChange={setQuery}
                />
              </Stack.Item>
            </Stack>

            <div
              style={{
                marginTop: '6px',
                flex: 1,
                overflowY: 'auto',
                display: 'flex',
                flexWrap: 'wrap',
                alignContent: 'flex-start',
                gap: '8px',
                padding: '6px',
              }}
            >
              {turfAtom && renderCard(turfAtom)}

              {filtered.length === 0 ? (
                <NoticeBox>Nothing to show.</NoticeBox>
              ) : (
                filtered.map((a) => renderCard(a))
              )}
            </div>
          </Stack>
        )}
      </Window.Content>
    </Window>
  );
};

export default TilePanel;
