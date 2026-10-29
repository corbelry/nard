import React from 'react';
const R = { common: ['--rarity-common', 'Adi'], rare: ['--rarity-rare', 'Nadir'], epic: ['--rarity-epic', 'Epik'], legendary: ['--rarity-legendary', 'Əfsanəvi'], seasonal: ['--rarity-seasonal', 'Mövsümi'] };
export function RarityFrame({ rarity = 'common', name, status, equipped = false, locked = false, children, width = 104 }) {
  const [v, label] = R[rarity];
  const c = `var(${v})`;
  return (
    <div style={{ width, borderRadius: 14, padding: 6, boxSizing: 'border-box', background: 'rgba(243,235,221,.04)', boxShadow: `inset 0 0 0 ${equipped ? 2 : 1}px ${equipped ? 'var(--accent-hi)' : c}${rarity === 'legendary' ? ', 0 0 18px color-mix(in oklch, ' + c + ' 35%, transparent)' : ''}`, display: 'flex', flexDirection: 'column', gap: 6, position: 'relative' }}>
      <div style={{ height: 64, borderRadius: 9, overflow: 'hidden', background: 'var(--placeholder-stripes)', opacity: locked ? .55 : 1 }}>{children}</div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 2, padding: '0 3px 3px' }}>
        <span style={{ font: 'var(--type-caption)', fontWeight: 600, color: 'var(--text)', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{name}</span>
        <span style={{ font: 'var(--type-micro)', color: locked ? 'var(--text-dim)' : c }}>{status || label}</span>
      </div>
      {equipped && <span style={{ position: 'absolute', top: 10, right: 10, width: 20, height: 20, borderRadius: '50%', background: 'var(--accent)', color: 'var(--on-accent)', display: 'flex', alignItems: 'center', justifyContent: 'center', font: '700 11px var(--font-ui)' }}>✓</span>}
    </div>
  );
}
