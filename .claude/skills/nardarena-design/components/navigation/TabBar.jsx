import React from 'react';
const TABS = [['home', 'Əsas', 'M4 11l8-7 8 7v9h-5v-6h-6v6H4z'], ['tour', 'Turnirlər', 'M8 4h8v5a4 4 0 0 1-8 0zM8 6H5a3 3 0 0 0 3 4M16 6h3a3 3 0 0 1-3 4M12 13v4M8 20h8'], ['clan', 'Klan', 'M12 3l7 3v5c0 4.5-3 8.5-7 10-4-1.5-7-5.5-7-10V6z'], ['store', 'Mağaza', 'M5 8h14l-1 12H6zM9 8V6a3 3 0 0 1 6 0v2'], ['profile', 'Profil', 'M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8zM4 21c1-4 4.5-6 8-6s7 2 8 6']];
export function TabBar({ active = 'home', onChange }) {
  return (
    <nav style={{ display: 'flex', padding: '8px 8px 26px', background: 'linear-gradient(180deg, transparent, var(--bg-deep) 30%)', borderTop: '1px solid var(--line-soft)' }}>
      {TABS.map(([k, l, d]) => { const on = k === active; return (
        <button key={k} onClick={() => onChange && onChange(k)} style={{ flex: 1, height: 52, border: 0, background: 'transparent', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 4, color: on ? 'var(--accent-hi)' : 'var(--text-dim)', cursor: 'pointer' }}>
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d={d} /></svg>
          <span style={{ font: 'var(--type-micro)', fontWeight: on ? 600 : 500 }}>{l}</span>
        </button>); })}
    </nav>
  );
}
