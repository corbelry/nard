import React from 'react';
const TIERS = { bronze: ['--rank-bronze', '#f0c9a6', 'Bürünc'], silver: ['--rank-silver', '#e6e9ec', 'Gümüş'], gold: ['--rank-gold', '#f4dc8e', 'Qızıl'], platinum: ['--rank-platinum', '#d6f1ee', 'Platin'], diamond: ['--rank-diamond', '#cfe6ff', 'Almaz'], master: ['--rank-master', '#e6d2ff', 'Master'], grandmaster: ['--rank-grandmaster', '#F3EBDD', 'Qrossmeyster'] };
const HEX = 'polygon(50% 0,100% 25%,100% 75%,50% 100%,0 75%,0 25%)';
export function RankBadge({ tier = 'platinum', sub = 'II', size = 46, showLabel = false }) {
  const [v, ink, label] = TIERS[tier];
  const h = size * 52 / 46;
  return (
    <div style={{ display: 'inline-flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
      <div style={{ width: size, height: h, clipPath: HEX, background: `var(${v})`, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        {size >= 24 && <div style={{ width: size * .74, height: h * .75, clipPath: HEX, background: 'rgba(20,12,8,.55)', display: 'flex', alignItems: 'center', justifyContent: 'center', font: `600 ${Math.round(size * .3)}px var(--font-display)`, color: ink }}>{sub}</div>}
      </div>
      {showLabel && <span style={{ font: 'var(--type-micro)', color: 'var(--text)' }}>{label} {sub}</span>}
    </div>
  );
}
