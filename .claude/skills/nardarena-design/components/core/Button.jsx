import React from 'react';
const V = {
  primary: { background: 'var(--primary-fill)', color: 'var(--primary-text)', boxShadow: 'var(--primary-shadow)' },
  secondary: { background: 'transparent', color: 'var(--accent)', boxShadow: 'var(--ring-accent)' },
  ghost: { background: 'transparent', color: 'var(--text)', boxShadow: 'none' },
  danger: { background: 'var(--danger)', color: '#FBEFEF', boxShadow: 'none' },
  outline: { background: 'transparent', color: 'var(--text)', boxShadow: 'var(--ring-line)' }
};
export function Button({ variant = 'primary', size = 'l', disabled = false, pressed = false, sub, children, style, ...rest }) {
  const h = size === 'l' ? 56 : size === 'm' ? 48 : 40;
  const v = disabled ? { background: 'var(--surface)', color: 'var(--text-faint)', boxShadow: 'var(--ring-line)' } : V[variant];
  return (
    <button disabled={disabled} {...rest} style={{ height: h, padding: '0 20px', border: 0, borderRadius: 'var(--radius-button)', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 10, font: size === 's' ? 'var(--type-label-m)' : 'var(--type-label-l)', fontFamily: 'var(--font-button)', textTransform: 'var(--label-case)', letterSpacing: 'var(--label-tracking)', cursor: disabled ? 'default' : 'pointer', transform: pressed ? 'scale(var(--press-scale))' : 'none', transition: 'transform var(--dur-press) var(--ease-standard)', ...v, ...style }}>
      <span>{children}</span>
      {sub != null && <span style={{ font: 'var(--type-body-s)', opacity: 0.75, fontVariantNumeric: 'tabular-nums' }}>{sub}</span>}
    </button>
  );
}
