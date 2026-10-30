import React from 'react';
export function SegmentedControl({ options = [], value, onChange, style }) {
  return (
    <div style={{ display: 'flex', padding: 4, borderRadius: 14, background: 'var(--surface-sunken)', boxShadow: 'inset 0 0 0 1px var(--line-soft)', ...style }}>
      {options.map(o => {
        const on = o === value;
        return <button key={o} onClick={() => onChange && onChange(o)} style={{ flex: 1, height: 40, border: 0, borderRadius: 10, background: on ? 'var(--ivory-100)' : 'transparent', color: on ? 'var(--walnut-900)' : 'var(--text-dim)', font: 'var(--type-label-m)', fontSize: 14, cursor: 'pointer' }}>{o}</button>;
      })}
    </div>
  );
}
