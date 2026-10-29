import React from 'react';
import { Clock } from './Clock.jsx';
import { RankBadge } from './RankBadge.jsx';
const FLAGS = { az: 'linear-gradient(180deg,#00B5E2 0 33.3%,#EF3340 33.3% 66.6%,#509E2F 66.6%)', tr: 'radial-gradient(circle at 42% 50%, #fff 0 22%, transparent 23%), #E30A17', ru: 'linear-gradient(180deg,#fff 0 33.3%,#1C3578 33.3% 66.6%,#E4181C 66.6%)' };
export function PlayerCard({ name, initials, flag = 'az', rating, rank = 'Platin II', tier = 'platinum', pip, clock, delay = 1, active = false, low = false, offline = false, trailing }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '10px 12px', borderRadius: 'var(--radius-card)', background: active ? 'var(--surface)' : 'transparent', boxShadow: active ? 'var(--ring-line)' : 'none', color: 'var(--text)' }}>
      <div style={{ width: 46, height: 46, flex: 'none', borderRadius: '50%', padding: 3, boxSizing: 'border-box', background: 'conic-gradient(from 210deg,#8a6a22,#E8C468,#a07c30,#E8C468,#8a6a22)', boxShadow: active ? '0 0 16px rgba(201,162,74,.4)' : 'none', opacity: offline ? .45 : 1, filter: offline ? 'grayscale(1)' : 'none' }}>
        <div style={{ width: '100%', height: '100%', borderRadius: '50%', background: 'linear-gradient(150deg,#2f4a52,#162428)', display: 'flex', alignItems: 'center', justifyContent: 'center', font: '600 18px var(--font-display)', color: '#F3EBDD' }}>{initials || (name || '?')[0]}</div>
      </div>
      <div style={{ flex: 1, minWidth: 0, display: 'flex', flexDirection: 'column', gap: 5, opacity: offline ? .45 : 1 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 7 }}><span style={{ font: 'var(--type-label-m)', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{name}</span><span style={{ width: 18, height: 12, flex: 'none', borderRadius: 2, background: FLAGS[flag] }} /></div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 7, font: 'var(--type-caption)', color: 'var(--text-dim)', fontVariantNumeric: 'tabular-nums', whiteSpace: 'nowrap' }}><RankBadge tier={tier} size={14} /><span style={{ color: 'var(--text)' }}>{rating}</span><span>{rank}</span><span style={{ opacity: .5 }}>·</span><span>Pip {pip}</span></div>
      </div>
      {offline && <span style={{ font: 'var(--type-micro)', fontWeight: 600, color: 'var(--danger-text)', padding: '4px 8px', borderRadius: 999, background: 'rgba(224,86,108,.14)' }}>Oflayn</span>}
      {trailing}
      {clock && <Clock time={clock} delay={delay} state={low ? 'low' : active ? 'active' : 'idle'} />}
    </div>
  );
}
