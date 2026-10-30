import React from 'react';
export function Chip({ selected = false, children, style, ...rest }) {
  return <span {...rest} style={{ height: 34, padding: '0 14px', borderRadius: 'var(--radius-pill)', display: 'inline-flex', alignItems: 'center', font: 'var(--type-caption)', fontSize: 13, fontWeight: selected ? 600 : 500, background: selected ? 'rgba(201,162,74,.18)' : 'transparent', color: selected ? 'var(--accent-hi)' : 'var(--text)', boxShadow: selected ? 'var(--ring-accent)' : 'var(--ring-line)', cursor: 'pointer', ...style }}>{children}</span>;
}
