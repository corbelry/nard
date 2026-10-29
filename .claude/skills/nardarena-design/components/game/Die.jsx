import React from 'react';
const PIPS = { 1: [4], 2: [2, 6], 3: [2, 4, 6], 4: [0, 2, 6, 8], 5: [0, 2, 4, 6, 8], 6: [0, 2, 3, 5, 6, 8] };
export function Die({ value = 1, size = 44, state = 'idle', style }) {
  const k = size / 44;
  return (
    <div style={{ width: size, height: size, borderRadius: 9 * k, position: 'relative', flex: 'none', background: 'linear-gradient(145deg,#fffaf0,#e4d6b8)', boxShadow: '0 4px 6px rgba(0,0,0,.45), inset 0 -3px 4px rgba(0,0,0,.18), inset 0 2px 2px rgba(255,255,255,.8)', opacity: state === 'used' ? 0.4 : 1, filter: state === 'rolling' ? 'blur(.8px)' : 'none', transform: state === 'rolling' ? 'rotate(-22deg)' : 'none', ...style }}>
      {(PIPS[value] || []).map(i => <span key={i} style={{ position: 'absolute', left: (8 + (i % 3) * 10.5) * k, top: (8 + Math.floor(i / 3) * 10.5) * k, width: 7.5 * k, height: 7.5 * k, borderRadius: '50%', background: 'radial-gradient(circle at 40% 35%, #3a2a1e, #0d0806)' }} />)}
    </div>
  );
}
