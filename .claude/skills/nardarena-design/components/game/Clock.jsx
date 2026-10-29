import React from 'react';
export function Clock({ time = '3:24', delay = 1, delaySeconds, state = 'idle', style }) {
  const low = state === 'low', act = state === 'active';
  const bg = low ? 'var(--danger)' : act ? 'var(--clock-active-bg)' : 'var(--surface)';
  const fg = low ? '#FBEFEF' : act ? 'var(--clock-active-text)' : 'var(--text-dim)';
  return (
    <div style={{ minWidth: 74, padding: '6px 10px 7px', borderRadius: 10, background: bg, color: fg, display: 'inline-flex', flexDirection: 'column', alignItems: 'flex-end', gap: 4, boxShadow: low ? 'var(--glow-danger)' : 'none', boxSizing: 'border-box', ...style }}>
      <span style={{ font: 'var(--type-clock)', fontVariantNumeric: 'tabular-nums' }}>{time}{delaySeconds != null && <span style={{ font: 'var(--type-micro)', opacity: .75, marginLeft: 6 }}>+{delaySeconds}s</span>}</span>
      <div style={{ width: '100%', height: 3, borderRadius: 2, background: low ? 'rgba(255,255,255,.25)' : act ? 'rgba(0,0,0,.15)' : 'rgba(255,255,255,.08)', overflow: 'hidden' }}><div style={{ width: delay * 100 + '%', height: '100%', background: fg }} /></div>
    </div>
  );
}
