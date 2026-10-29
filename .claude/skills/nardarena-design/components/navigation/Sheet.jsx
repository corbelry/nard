import React from 'react';
export function Sheet({ title, children, scrim = true }) {
  return (
    <div style={{ position: 'relative' }}>
      {scrim && <div style={{ position: 'absolute', inset: 0, background: 'var(--scrim)' }} />}
      <div style={{ position: 'relative', margin: 8, padding: '12px 20px 30px', borderRadius: '24px 24px 42px 42px', background: 'var(--surface-raised)', boxShadow: 'var(--ring-line), var(--elev-2)', display: 'flex', flexDirection: 'column', gap: 14 }}>
        <span style={{ width: 40, height: 4, borderRadius: 2, background: 'rgba(243,235,221,.25)', alignSelf: 'center' }} />
        {title && <span style={{ font: 'var(--type-display-l)', fontSize: 22, lineHeight: '28px' }}>{title}</span>}
        {children}
      </div>
    </div>
  );
}
