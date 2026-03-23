import { cls } from './helpers';
import { type Aspect } from './types';

export const GrimoireChapterList = ({
  aspects,
  attuned,
  locked,
  pendingUnbinds,
  selectedPath,
  isBlocked,
  onSelect,
}: {
  aspects: Aspect[];
  attuned: string[];
  locked: string[];
  pendingUnbinds: string[];
  selectedPath: string | null;
  isBlocked: (a: Aspect) => boolean;
  onSelect: (path: string) => void;
}) => (
  <>
    {aspects.map((aspect) => {
      const active = attuned.includes(aspect.path);
      const isLocked = locked.includes(aspect.path);
      const isPendingUnbind = pendingUnbinds.includes(aspect.path);
      const blocked = !active && isBlocked(aspect);
      const viewing = selectedPath === aspect.path;
      return (
        <div
          key={aspect.path}
          className={cls(
            'AspectPicker__chapter-entry',
            viewing && 'AspectPicker__chapter-entry--active',
            active && !isPendingUnbind && 'AspectPicker__chapter-entry--attuned',
            isLocked && 'AspectPicker__chapter-entry--locked',
            isPendingUnbind && 'AspectPicker__chapter-entry--unbinding',
            blocked && 'AspectPicker__chapter-entry--blocked',
          )}
          onClick={() => onSelect(aspect.path)}
        >
          <span
            style={{
              ...(aspect.school_color && !blocked
                ? { color: aspect.school_color }
                : {}),
              ...(blocked ? { color: 'rgba(150,80,80,0.6)' } : {}),
              ...(isPendingUnbind
                ? { textDecoration: 'line-through', opacity: 0.6 }
                : {}),
            }}
          >
            {aspect.name}
          </span>
          {blocked && (
            <span
              className="AspectPicker__spell-desc"
              style={{ marginLeft: '6px', color: 'rgba(150,80,80,0.5)', fontSize: '10px' }}
            >
              opposed
            </span>
          )}
          {isLocked && (
            <span
              className="AspectPicker__spell-desc"
              style={{ marginLeft: '6px' }}
            >
              bound
            </span>
          )}
          {active && !isLocked && !isPendingUnbind && (
            <span
              className="AspectPicker__spell-desc"
              style={{ marginLeft: '6px', opacity: 0.6 }}
            >
              attuned
            </span>
          )}
          {isPendingUnbind && (
            <span
              className="AspectPicker__spell-desc"
              style={{ marginLeft: '6px', color: 'rgba(200,100,100,0.8)' }}
            >
              unbinding
            </span>
          )}
        </div>
      );
    })}
  </>
);
