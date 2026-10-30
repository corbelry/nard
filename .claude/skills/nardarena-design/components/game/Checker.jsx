import React from 'react';
const FILL = {
  ivory: 'repeating-radial-gradient(circle, rgba(0,0,0,0) 0 5px, rgba(110,85,50,.17) 5px 6px), radial-gradient(circle at 38% 30%, #fffbf2 0%, #efe4cf 42%, #d4c3a2 78%, #b3a07c 100%)',
  onyx: 'repeating-radial-gradient(circle, rgba(0,0,0,0) 0 5px, rgba(255,255,255,.055) 5px 6px), radial-gradient(circle at 38% 30%, #5d564f 0%, #2b2724 40%, #151312 80%, #0a0909 100%)'
};
const SH = { ivory: '0 2px 2px rgba(0,0,0,.35), 0 4px 8px rgba(0,0,0,.25), inset 0 -2px 3px rgba(80,55,25,.35), inset 0 1px 1px rgba(255,255,255,.9)', onyx: '0 2px 2px rgba(0,0,0,.45), 0 4px 8px rgba(0,0,0,.3), inset 0 -2px 3px rgba(0,0,0,.6), inset 0 1px 1px rgba(255,255,255,.18)' };
export function Checker({ side = 'ivory', size = 38, selected = false, colorBlind = false, count, style }) {
  let bg = FILL[side];
  if (colorBlind) bg = (side === 'ivory' ? 'radial-gradient(circle, transparent 0 24%, #2B1D14 24% 32%, transparent 32%), ' : 'radial-gradient(circle, #E8C468 0 18%, transparent 19%), ') + bg;
  return <div style={{ width: size, height: size, borderRadius: '50%', flex: 'none', background: bg, boxShadow: SH[side] + (selected ? ', var(--glow-legal)' : ''), display: 'flex', alignItems: 'center', justifyContent: 'center', font: '700 15px var(--font-ui)', color: side === 'ivory' ? '#4a3620' : '#efe4cf', ...style }}>{count}</div>;
}
