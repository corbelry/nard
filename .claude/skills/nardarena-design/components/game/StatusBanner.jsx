import React from 'react';
const TONE = { brass: 'var(--accent)', dim: '#8f877b', danger: 'var(--danger-text)', ok: 'var(--success-text)' };
export function StatusBanner({ title, sub, tone = 'brass', ornament = true }) {
  const c = TONE[tone];
  const D = <span style={{ width: 5, height: 5, transform: 'rotate(45deg)', background: 'var(--accent)', opacity: .7 }} />;
  const L = <span style={{ width: 28, height: 1, background: 'var(--line)' }} />;
  return (
    <div style={{ height: 26, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10, font: 'var(--type-body-s)' }}>
      {ornament && <span style={{ display: 'flex', alignItems: 'center', gap: 5 }}>{L}{D}</span>}
      <span style={{ width: 7, height: 7, borderRadius: '50%', background: c, boxShadow: `0 0 8px ${c}` }} />
      <span style={{ fontWeight: 600, color: tone === 'dim' ? 'var(--text)' : c, textTransform: 'var(--label-case)', letterSpacing: 'var(--label-tracking)' }}>{title}</span>
      {sub && <span style={{ color: 'var(--text-dim)' }}>{sub}</span>}
      {ornament && <span style={{ display: 'flex', alignItems: 'center', gap: 5 }}>{D}{L}</span>}
    </div>
  );
}
