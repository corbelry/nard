import React from 'react';
export function Switch({ on = false, onChange, label }) {
  return (
    <button role="switch" aria-checked={on} aria-label={label} onClick={() => onChange && onChange(!on)} style={{ width: 48, height: 28, border: 0, padding: 0, borderRadius: 999, position: 'relative', background: on ? 'var(--accent)' : 'rgba(243,235,221,.14)', cursor: 'pointer', transition: 'background var(--dur-fast) var(--ease-standard)' }}>
      <span style={{ position: 'absolute', top: 3, left: on ? 23 : 3, width: 22, height: 22, borderRadius: '50%', background: on ? 'var(--bg)' : 'var(--ivory-100)', transition: 'left var(--dur-fast) var(--ease-standard)' }} />
    </button>
  );
}
