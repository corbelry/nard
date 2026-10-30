import React from 'react';
export function IconButton({ label, caption, round = false, tone = 'default', size = 44, children, style, ...rest }) {
  return (
    <button aria-label={label} {...rest} style={{ width: caption ? 66 : size, height: caption ? 60 : size, border: 0, borderRadius: round ? '50%' : 'var(--radius-m)', background: 'transparent', boxShadow: 'var(--ring-line)', color: tone === 'accent' ? 'var(--accent)' : tone === 'danger' ? 'var(--danger-text)' : 'var(--text)', display: 'inline-flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 4, cursor: 'pointer', ...style }}>
      {children}
      {caption && <span style={{ font: 'var(--type-micro)', color: 'var(--text-dim)' }}>{caption}</span>}
    </button>
  );
}
