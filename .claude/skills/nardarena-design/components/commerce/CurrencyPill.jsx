import React from 'react';
export function CurrencyPill({ kind = 'coin', amount }) {
  const icon = kind === 'coin'
    ? <span style={{ width: 20, height: 20, borderRadius: '50%', background: 'radial-gradient(circle at 35% 30%,#fbe7a6,#c9a24a 60%,#8a6a22)' }} />
    : <span style={{ width: 14, height: 14, margin: '0 3px', transform: 'rotate(45deg)', background: 'linear-gradient(135deg,#ff9fb0,#9E1B32)' }} />;
  return <span style={{ height: 32, padding: '0 12px 0 6px', borderRadius: 999, background: 'var(--surface)', boxShadow: 'var(--ring-line)', display: 'inline-flex', alignItems: 'center', gap: 7, font: 'var(--type-label-m)', fontSize: 13, fontVariantNumeric: 'tabular-nums', color: 'var(--text)' }}>{icon}{amount}</span>;
}
