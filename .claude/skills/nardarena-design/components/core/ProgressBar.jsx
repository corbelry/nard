import React from 'react';
const T = { accent: 'var(--accent)', success: 'var(--success-text)', danger: 'var(--danger-text)', platinum: 'linear-gradient(90deg,#6aa9a5,#d6f1ee)' };
export function ProgressBar({ value = 0, tone = 'accent', height = 4, style }) {
  return <div style={{ height, borderRadius: height / 2, background: 'rgba(243,235,221,.12)', overflow: 'hidden', ...style }}><div style={{ width: Math.max(0, Math.min(1, value)) * 100 + '%', height: '100%', borderRadius: height / 2, background: T[tone] || tone }} /></div>;
}
