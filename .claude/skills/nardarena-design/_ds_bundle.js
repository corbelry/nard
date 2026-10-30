/* @ds-bundle: {"format":4,"namespace":"DesignSystem_67b15d","components":[{"name":"CurrencyPill","sourcePath":"components/commerce/CurrencyPill.jsx"},{"name":"RarityFrame","sourcePath":"components/commerce/RarityFrame.jsx"},{"name":"Button","sourcePath":"components/core/Button.jsx"},{"name":"Chip","sourcePath":"components/core/Chip.jsx"},{"name":"IconButton","sourcePath":"components/core/IconButton.jsx"},{"name":"ProgressBar","sourcePath":"components/core/ProgressBar.jsx"},{"name":"SegmentedControl","sourcePath":"components/core/SegmentedControl.jsx"},{"name":"Switch","sourcePath":"components/core/Switch.jsx"},{"name":"Checker","sourcePath":"components/game/Checker.jsx"},{"name":"Clock","sourcePath":"components/game/Clock.jsx"},{"name":"Die","sourcePath":"components/game/Die.jsx"},{"name":"PlayerCard","sourcePath":"components/game/PlayerCard.jsx"},{"name":"RankBadge","sourcePath":"components/game/RankBadge.jsx"},{"name":"StatusBanner","sourcePath":"components/game/StatusBanner.jsx"},{"name":"Sheet","sourcePath":"components/navigation/Sheet.jsx"},{"name":"TabBar","sourcePath":"components/navigation/TabBar.jsx"}],"sourceHashes":{"components/commerce/CurrencyPill.jsx":"011323b84726","components/commerce/RarityFrame.jsx":"00f9c6b505d9","components/core/Button.jsx":"827364772f11","components/core/Chip.jsx":"5a65b79793a0","components/core/IconButton.jsx":"d65147e56a22","components/core/ProgressBar.jsx":"775c6201a771","components/core/SegmentedControl.jsx":"182578b825fe","components/core/Switch.jsx":"342ba575d8bd","components/game/Checker.jsx":"34a4eb0fb58c","components/game/Clock.jsx":"ec356c0da436","components/game/Die.jsx":"b8759cf2787a","components/game/PlayerCard.jsx":"f755c55d8c8a","components/game/RankBadge.jsx":"a3e63983c1d3","components/game/StatusBanner.jsx":"ebba49b3dd9e","components/navigation/Sheet.jsx":"2edb5f920160","components/navigation/TabBar.jsx":"40c2687bd5b6"},"inlinedExternals":[],"unexposedExports":[]} */

(() => {

const __ds_ns = (window.DesignSystem_67b15d = window.DesignSystem_67b15d || {});

const __ds_scope = {};

(__ds_ns.__errors = __ds_ns.__errors || []);

// components/commerce/CurrencyPill.jsx
try { (() => {
function CurrencyPill({
  kind = 'coin',
  amount
}) {
  const icon = kind === 'coin' ? /*#__PURE__*/React.createElement("span", {
    style: {
      width: 20,
      height: 20,
      borderRadius: '50%',
      background: 'radial-gradient(circle at 35% 30%,#fbe7a6,#c9a24a 60%,#8a6a22)'
    }
  }) : /*#__PURE__*/React.createElement("span", {
    style: {
      width: 14,
      height: 14,
      margin: '0 3px',
      transform: 'rotate(45deg)',
      background: 'linear-gradient(135deg,#ff9fb0,#9E1B32)'
    }
  });
  return /*#__PURE__*/React.createElement("span", {
    style: {
      height: 32,
      padding: '0 12px 0 6px',
      borderRadius: 999,
      background: 'var(--surface)',
      boxShadow: 'var(--ring-line)',
      display: 'inline-flex',
      alignItems: 'center',
      gap: 7,
      font: 'var(--type-label-m)',
      fontSize: 13,
      fontVariantNumeric: 'tabular-nums',
      color: 'var(--text)'
    }
  }, icon, amount);
}
Object.assign(__ds_scope, { CurrencyPill });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/commerce/CurrencyPill.jsx", error: String((e && e.message) || e) }); }

// components/commerce/RarityFrame.jsx
try { (() => {
const R = {
  common: ['--rarity-common', 'Adi'],
  rare: ['--rarity-rare', 'Nadir'],
  epic: ['--rarity-epic', 'Epik'],
  legendary: ['--rarity-legendary', 'Əfsanəvi'],
  seasonal: ['--rarity-seasonal', 'Mövsümi']
};
function RarityFrame({
  rarity = 'common',
  name,
  status,
  equipped = false,
  locked = false,
  children,
  width = 104
}) {
  const [v, label] = R[rarity];
  const c = `var(${v})`;
  return /*#__PURE__*/React.createElement("div", {
    style: {
      width,
      borderRadius: 14,
      padding: 6,
      boxSizing: 'border-box',
      background: 'rgba(243,235,221,.04)',
      boxShadow: `inset 0 0 0 ${equipped ? 2 : 1}px ${equipped ? 'var(--accent-hi)' : c}${rarity === 'legendary' ? ', 0 0 18px color-mix(in oklch, ' + c + ' 35%, transparent)' : ''}`,
      display: 'flex',
      flexDirection: 'column',
      gap: 6,
      position: 'relative'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      height: 64,
      borderRadius: 9,
      overflow: 'hidden',
      background: 'var(--placeholder-stripes)',
      opacity: locked ? .55 : 1
    }
  }, children), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 2,
      padding: '0 3px 3px'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--type-caption)',
      fontWeight: 600,
      color: 'var(--text)',
      whiteSpace: 'nowrap',
      overflow: 'hidden',
      textOverflow: 'ellipsis'
    }
  }, name), /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--type-micro)',
      color: locked ? 'var(--text-dim)' : c
    }
  }, status || label)), equipped && /*#__PURE__*/React.createElement("span", {
    style: {
      position: 'absolute',
      top: 10,
      right: 10,
      width: 20,
      height: 20,
      borderRadius: '50%',
      background: 'var(--accent)',
      color: 'var(--on-accent)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      font: '700 11px var(--font-ui)'
    }
  }, "\u2713"));
}
Object.assign(__ds_scope, { RarityFrame });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/commerce/RarityFrame.jsx", error: String((e && e.message) || e) }); }

// components/core/Button.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
const V = {
  primary: {
    background: 'var(--primary-fill)',
    color: 'var(--primary-text)',
    boxShadow: 'var(--primary-shadow)'
  },
  secondary: {
    background: 'transparent',
    color: 'var(--accent)',
    boxShadow: 'var(--ring-accent)'
  },
  ghost: {
    background: 'transparent',
    color: 'var(--text)',
    boxShadow: 'none'
  },
  danger: {
    background: 'var(--danger)',
    color: '#FBEFEF',
    boxShadow: 'none'
  },
  outline: {
    background: 'transparent',
    color: 'var(--text)',
    boxShadow: 'var(--ring-line)'
  }
};
function Button({
  variant = 'primary',
  size = 'l',
  disabled = false,
  pressed = false,
  sub,
  children,
  style,
  ...rest
}) {
  const h = size === 'l' ? 56 : size === 'm' ? 48 : 40;
  const v = disabled ? {
    background: 'var(--surface)',
    color: 'var(--text-faint)',
    boxShadow: 'var(--ring-line)'
  } : V[variant];
  return /*#__PURE__*/React.createElement("button", _extends({
    disabled: disabled
  }, rest, {
    style: {
      height: h,
      padding: '0 20px',
      border: 0,
      borderRadius: 'var(--radius-button)',
      display: 'inline-flex',
      alignItems: 'center',
      justifyContent: 'center',
      gap: 10,
      font: size === 's' ? 'var(--type-label-m)' : 'var(--type-label-l)',
      fontFamily: 'var(--font-button)',
      textTransform: 'var(--label-case)',
      letterSpacing: 'var(--label-tracking)',
      cursor: disabled ? 'default' : 'pointer',
      transform: pressed ? 'scale(var(--press-scale))' : 'none',
      transition: 'transform var(--dur-press) var(--ease-standard)',
      ...v,
      ...style
    }
  }), /*#__PURE__*/React.createElement("span", null, children), sub != null && /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--type-body-s)',
      opacity: 0.75,
      fontVariantNumeric: 'tabular-nums'
    }
  }, sub));
}
Object.assign(__ds_scope, { Button });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Button.jsx", error: String((e && e.message) || e) }); }

// components/core/Chip.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function Chip({
  selected = false,
  children,
  style,
  ...rest
}) {
  return /*#__PURE__*/React.createElement("span", _extends({}, rest, {
    style: {
      height: 34,
      padding: '0 14px',
      borderRadius: 'var(--radius-pill)',
      display: 'inline-flex',
      alignItems: 'center',
      font: 'var(--type-caption)',
      fontSize: 13,
      fontWeight: selected ? 600 : 500,
      background: selected ? 'rgba(201,162,74,.18)' : 'transparent',
      color: selected ? 'var(--accent-hi)' : 'var(--text)',
      boxShadow: selected ? 'var(--ring-accent)' : 'var(--ring-line)',
      cursor: 'pointer',
      ...style
    }
  }), children);
}
Object.assign(__ds_scope, { Chip });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Chip.jsx", error: String((e && e.message) || e) }); }

// components/core/IconButton.jsx
try { (() => {
function _extends() { return _extends = Object.assign ? Object.assign.bind() : function (n) { for (var e = 1; e < arguments.length; e++) { var t = arguments[e]; for (var r in t) ({}).hasOwnProperty.call(t, r) && (n[r] = t[r]); } return n; }, _extends.apply(null, arguments); }
function IconButton({
  label,
  caption,
  round = false,
  tone = 'default',
  size = 44,
  children,
  style,
  ...rest
}) {
  return /*#__PURE__*/React.createElement("button", _extends({
    "aria-label": label
  }, rest, {
    style: {
      width: caption ? 66 : size,
      height: caption ? 60 : size,
      border: 0,
      borderRadius: round ? '50%' : 'var(--radius-m)',
      background: 'transparent',
      boxShadow: 'var(--ring-line)',
      color: tone === 'accent' ? 'var(--accent)' : tone === 'danger' ? 'var(--danger-text)' : 'var(--text)',
      display: 'inline-flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      gap: 4,
      cursor: 'pointer',
      ...style
    }
  }), children, caption && /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--type-micro)',
      color: 'var(--text-dim)'
    }
  }, caption));
}
Object.assign(__ds_scope, { IconButton });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/IconButton.jsx", error: String((e && e.message) || e) }); }

// components/core/ProgressBar.jsx
try { (() => {
const T = {
  accent: 'var(--accent)',
  success: 'var(--success-text)',
  danger: 'var(--danger-text)',
  platinum: 'linear-gradient(90deg,#6aa9a5,#d6f1ee)'
};
function ProgressBar({
  value = 0,
  tone = 'accent',
  height = 4,
  style
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      height,
      borderRadius: height / 2,
      background: 'rgba(243,235,221,.12)',
      overflow: 'hidden',
      ...style
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: Math.max(0, Math.min(1, value)) * 100 + '%',
      height: '100%',
      borderRadius: height / 2,
      background: T[tone] || tone
    }
  }));
}
Object.assign(__ds_scope, { ProgressBar });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/ProgressBar.jsx", error: String((e && e.message) || e) }); }

// components/core/SegmentedControl.jsx
try { (() => {
function SegmentedControl({
  options = [],
  value,
  onChange,
  style
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      padding: 4,
      borderRadius: 14,
      background: 'var(--surface-sunken)',
      boxShadow: 'inset 0 0 0 1px var(--line-soft)',
      ...style
    }
  }, options.map(o => {
    const on = o === value;
    return /*#__PURE__*/React.createElement("button", {
      key: o,
      onClick: () => onChange && onChange(o),
      style: {
        flex: 1,
        height: 40,
        border: 0,
        borderRadius: 10,
        background: on ? 'var(--ivory-100)' : 'transparent',
        color: on ? 'var(--walnut-900)' : 'var(--text-dim)',
        font: 'var(--type-label-m)',
        fontSize: 14,
        cursor: 'pointer'
      }
    }, o);
  }));
}
Object.assign(__ds_scope, { SegmentedControl });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/SegmentedControl.jsx", error: String((e && e.message) || e) }); }

// components/core/Switch.jsx
try { (() => {
function Switch({
  on = false,
  onChange,
  label
}) {
  return /*#__PURE__*/React.createElement("button", {
    role: "switch",
    "aria-checked": on,
    "aria-label": label,
    onClick: () => onChange && onChange(!on),
    style: {
      width: 48,
      height: 28,
      border: 0,
      padding: 0,
      borderRadius: 999,
      position: 'relative',
      background: on ? 'var(--accent)' : 'rgba(243,235,221,.14)',
      cursor: 'pointer',
      transition: 'background var(--dur-fast) var(--ease-standard)'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      position: 'absolute',
      top: 3,
      left: on ? 23 : 3,
      width: 22,
      height: 22,
      borderRadius: '50%',
      background: on ? 'var(--bg)' : 'var(--ivory-100)',
      transition: 'left var(--dur-fast) var(--ease-standard)'
    }
  }));
}
Object.assign(__ds_scope, { Switch });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Switch.jsx", error: String((e && e.message) || e) }); }

// components/game/Checker.jsx
try { (() => {
const FILL = {
  ivory: 'repeating-radial-gradient(circle, rgba(0,0,0,0) 0 5px, rgba(110,85,50,.17) 5px 6px), radial-gradient(circle at 38% 30%, #fffbf2 0%, #efe4cf 42%, #d4c3a2 78%, #b3a07c 100%)',
  onyx: 'repeating-radial-gradient(circle, rgba(0,0,0,0) 0 5px, rgba(255,255,255,.055) 5px 6px), radial-gradient(circle at 38% 30%, #5d564f 0%, #2b2724 40%, #151312 80%, #0a0909 100%)'
};
const SH = {
  ivory: '0 2px 2px rgba(0,0,0,.35), 0 4px 8px rgba(0,0,0,.25), inset 0 -2px 3px rgba(80,55,25,.35), inset 0 1px 1px rgba(255,255,255,.9)',
  onyx: '0 2px 2px rgba(0,0,0,.45), 0 4px 8px rgba(0,0,0,.3), inset 0 -2px 3px rgba(0,0,0,.6), inset 0 1px 1px rgba(255,255,255,.18)'
};
function Checker({
  side = 'ivory',
  size = 38,
  selected = false,
  colorBlind = false,
  count,
  style
}) {
  let bg = FILL[side];
  if (colorBlind) bg = (side === 'ivory' ? 'radial-gradient(circle, transparent 0 24%, #2B1D14 24% 32%, transparent 32%), ' : 'radial-gradient(circle, #E8C468 0 18%, transparent 19%), ') + bg;
  return /*#__PURE__*/React.createElement("div", {
    style: {
      width: size,
      height: size,
      borderRadius: '50%',
      flex: 'none',
      background: bg,
      boxShadow: SH[side] + (selected ? ', var(--glow-legal)' : ''),
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      font: '700 15px var(--font-ui)',
      color: side === 'ivory' ? '#4a3620' : '#efe4cf',
      ...style
    }
  }, count);
}
Object.assign(__ds_scope, { Checker });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/game/Checker.jsx", error: String((e && e.message) || e) }); }

// components/game/Clock.jsx
try { (() => {
function Clock({
  time = '3:24',
  delay = 1,
  delaySeconds,
  state = 'idle',
  style
}) {
  const low = state === 'low',
    act = state === 'active';
  const bg = low ? 'var(--danger)' : act ? 'var(--clock-active-bg)' : 'var(--surface)';
  const fg = low ? '#FBEFEF' : act ? 'var(--clock-active-text)' : 'var(--text-dim)';
  return /*#__PURE__*/React.createElement("div", {
    style: {
      minWidth: 74,
      padding: '6px 10px 7px',
      borderRadius: 10,
      background: bg,
      color: fg,
      display: 'inline-flex',
      flexDirection: 'column',
      alignItems: 'flex-end',
      gap: 4,
      boxShadow: low ? 'var(--glow-danger)' : 'none',
      boxSizing: 'border-box',
      ...style
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--type-clock)',
      fontVariantNumeric: 'tabular-nums'
    }
  }, time, delaySeconds != null && /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--type-micro)',
      opacity: .75,
      marginLeft: 6
    }
  }, "+", delaySeconds, "s")), /*#__PURE__*/React.createElement("div", {
    style: {
      width: '100%',
      height: 3,
      borderRadius: 2,
      background: low ? 'rgba(255,255,255,.25)' : act ? 'rgba(0,0,0,.15)' : 'rgba(255,255,255,.08)',
      overflow: 'hidden'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: delay * 100 + '%',
      height: '100%',
      background: fg
    }
  })));
}
Object.assign(__ds_scope, { Clock });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/game/Clock.jsx", error: String((e && e.message) || e) }); }

// components/game/Die.jsx
try { (() => {
const PIPS = {
  1: [4],
  2: [2, 6],
  3: [2, 4, 6],
  4: [0, 2, 6, 8],
  5: [0, 2, 4, 6, 8],
  6: [0, 2, 3, 5, 6, 8]
};
function Die({
  value = 1,
  size = 44,
  state = 'idle',
  style
}) {
  const k = size / 44;
  return /*#__PURE__*/React.createElement("div", {
    style: {
      width: size,
      height: size,
      borderRadius: 9 * k,
      position: 'relative',
      flex: 'none',
      background: 'linear-gradient(145deg,#fffaf0,#e4d6b8)',
      boxShadow: '0 4px 6px rgba(0,0,0,.45), inset 0 -3px 4px rgba(0,0,0,.18), inset 0 2px 2px rgba(255,255,255,.8)',
      opacity: state === 'used' ? 0.4 : 1,
      filter: state === 'rolling' ? 'blur(.8px)' : 'none',
      transform: state === 'rolling' ? 'rotate(-22deg)' : 'none',
      ...style
    }
  }, (PIPS[value] || []).map(i => /*#__PURE__*/React.createElement("span", {
    key: i,
    style: {
      position: 'absolute',
      left: (8 + i % 3 * 10.5) * k,
      top: (8 + Math.floor(i / 3) * 10.5) * k,
      width: 7.5 * k,
      height: 7.5 * k,
      borderRadius: '50%',
      background: 'radial-gradient(circle at 40% 35%, #3a2a1e, #0d0806)'
    }
  })));
}
Object.assign(__ds_scope, { Die });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/game/Die.jsx", error: String((e && e.message) || e) }); }

// components/game/RankBadge.jsx
try { (() => {
const TIERS = {
  bronze: ['--rank-bronze', '#f0c9a6', 'Bürünc'],
  silver: ['--rank-silver', '#e6e9ec', 'Gümüş'],
  gold: ['--rank-gold', '#f4dc8e', 'Qızıl'],
  platinum: ['--rank-platinum', '#d6f1ee', 'Platin'],
  diamond: ['--rank-diamond', '#cfe6ff', 'Almaz'],
  master: ['--rank-master', '#e6d2ff', 'Master'],
  grandmaster: ['--rank-grandmaster', '#F3EBDD', 'Qrossmeyster']
};
const HEX = 'polygon(50% 0,100% 25%,100% 75%,50% 100%,0 75%,0 25%)';
function RankBadge({
  tier = 'platinum',
  sub = 'II',
  size = 46,
  showLabel = false
}) {
  const [v, ink, label] = TIERS[tier];
  const h = size * 52 / 46;
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'inline-flex',
      flexDirection: 'column',
      alignItems: 'center',
      gap: 8
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: size,
      height: h,
      clipPath: HEX,
      background: `var(${v})`,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center'
    }
  }, size >= 24 && /*#__PURE__*/React.createElement("div", {
    style: {
      width: size * .74,
      height: h * .75,
      clipPath: HEX,
      background: 'rgba(20,12,8,.55)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      font: `600 ${Math.round(size * .3)}px var(--font-display)`,
      color: ink
    }
  }, sub)), showLabel && /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--type-micro)',
      color: 'var(--text)'
    }
  }, label, " ", sub));
}
Object.assign(__ds_scope, { RankBadge });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/game/RankBadge.jsx", error: String((e && e.message) || e) }); }

// components/game/PlayerCard.jsx
try { (() => {
const FLAGS = {
  az: 'linear-gradient(180deg,#00B5E2 0 33.3%,#EF3340 33.3% 66.6%,#509E2F 66.6%)',
  tr: 'radial-gradient(circle at 42% 50%, #fff 0 22%, transparent 23%), #E30A17',
  ru: 'linear-gradient(180deg,#fff 0 33.3%,#1C3578 33.3% 66.6%,#E4181C 66.6%)'
};
function PlayerCard({
  name,
  initials,
  flag = 'az',
  rating,
  rank = 'Platin II',
  tier = 'platinum',
  pip,
  clock,
  delay = 1,
  active = false,
  low = false,
  offline = false,
  trailing
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 12,
      padding: '10px 12px',
      borderRadius: 'var(--radius-card)',
      background: active ? 'var(--surface)' : 'transparent',
      boxShadow: active ? 'var(--ring-line)' : 'none',
      color: 'var(--text)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: 46,
      height: 46,
      flex: 'none',
      borderRadius: '50%',
      padding: 3,
      boxSizing: 'border-box',
      background: 'conic-gradient(from 210deg,#8a6a22,#E8C468,#a07c30,#E8C468,#8a6a22)',
      boxShadow: active ? '0 0 16px rgba(201,162,74,.4)' : 'none',
      opacity: offline ? .45 : 1,
      filter: offline ? 'grayscale(1)' : 'none'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: '100%',
      height: '100%',
      borderRadius: '50%',
      background: 'linear-gradient(150deg,#2f4a52,#162428)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      font: '600 18px var(--font-display)',
      color: '#F3EBDD'
    }
  }, initials || (name || '?')[0])), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minWidth: 0,
      display: 'flex',
      flexDirection: 'column',
      gap: 5,
      opacity: offline ? .45 : 1
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 7
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--type-label-m)',
      whiteSpace: 'nowrap',
      overflow: 'hidden',
      textOverflow: 'ellipsis'
    }
  }, name), /*#__PURE__*/React.createElement("span", {
    style: {
      width: 18,
      height: 12,
      flex: 'none',
      borderRadius: 2,
      background: FLAGS[flag]
    }
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 7,
      font: 'var(--type-caption)',
      color: 'var(--text-dim)',
      fontVariantNumeric: 'tabular-nums',
      whiteSpace: 'nowrap'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.RankBadge, {
    tier: tier,
    size: 14
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      color: 'var(--text)'
    }
  }, rating), /*#__PURE__*/React.createElement("span", null, rank), /*#__PURE__*/React.createElement("span", {
    style: {
      opacity: .5
    }
  }, "\xB7"), /*#__PURE__*/React.createElement("span", null, "Pip ", pip))), offline && /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--type-micro)',
      fontWeight: 600,
      color: 'var(--danger-text)',
      padding: '4px 8px',
      borderRadius: 999,
      background: 'rgba(224,86,108,.14)'
    }
  }, "Oflayn"), trailing, clock && /*#__PURE__*/React.createElement(__ds_scope.Clock, {
    time: clock,
    delay: delay,
    state: low ? 'low' : active ? 'active' : 'idle'
  }));
}
Object.assign(__ds_scope, { PlayerCard });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/game/PlayerCard.jsx", error: String((e && e.message) || e) }); }

// components/game/StatusBanner.jsx
try { (() => {
const TONE = {
  brass: 'var(--accent)',
  dim: '#8f877b',
  danger: 'var(--danger-text)',
  ok: 'var(--success-text)'
};
function StatusBanner({
  title,
  sub,
  tone = 'brass',
  ornament = true
}) {
  const c = TONE[tone];
  const D = /*#__PURE__*/React.createElement("span", {
    style: {
      width: 5,
      height: 5,
      transform: 'rotate(45deg)',
      background: 'var(--accent)',
      opacity: .7
    }
  });
  const L = /*#__PURE__*/React.createElement("span", {
    style: {
      width: 28,
      height: 1,
      background: 'var(--line)'
    }
  });
  return /*#__PURE__*/React.createElement("div", {
    style: {
      height: 26,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      gap: 10,
      font: 'var(--type-body-s)'
    }
  }, ornament && /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 5
    }
  }, L, D), /*#__PURE__*/React.createElement("span", {
    style: {
      width: 7,
      height: 7,
      borderRadius: '50%',
      background: c,
      boxShadow: `0 0 8px ${c}`
    }
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      fontWeight: 600,
      color: tone === 'dim' ? 'var(--text)' : c,
      textTransform: 'var(--label-case)',
      letterSpacing: 'var(--label-tracking)'
    }
  }, title), sub && /*#__PURE__*/React.createElement("span", {
    style: {
      color: 'var(--text-dim)'
    }
  }, sub), ornament && /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 5
    }
  }, D, L));
}
Object.assign(__ds_scope, { StatusBanner });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/game/StatusBanner.jsx", error: String((e && e.message) || e) }); }

// components/navigation/Sheet.jsx
try { (() => {
function Sheet({
  title,
  children,
  scrim = true
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'relative'
    }
  }, scrim && /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: 0,
      background: 'var(--scrim)'
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'relative',
      margin: 8,
      padding: '12px 20px 30px',
      borderRadius: '24px 24px 42px 42px',
      background: 'var(--surface-raised)',
      boxShadow: 'var(--ring-line), var(--elev-2)',
      display: 'flex',
      flexDirection: 'column',
      gap: 14
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 40,
      height: 4,
      borderRadius: 2,
      background: 'rgba(243,235,221,.25)',
      alignSelf: 'center'
    }
  }), title && /*#__PURE__*/React.createElement("span", {
    style: {
      font: 'var(--type-display-l)',
      fontSize: 22,
      lineHeight: '28px'
    }
  }, title), children));
}
Object.assign(__ds_scope, { Sheet });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/navigation/Sheet.jsx", error: String((e && e.message) || e) }); }

// components/navigation/TabBar.jsx
try { (() => {
const TABS = [['home', 'Əsas', 'M4 11l8-7 8 7v9h-5v-6h-6v6H4z'], ['tour', 'Turnirlər', 'M8 4h8v5a4 4 0 0 1-8 0zM8 6H5a3 3 0 0 0 3 4M16 6h3a3 3 0 0 1-3 4M12 13v4M8 20h8'], ['clan', 'Klan', 'M12 3l7 3v5c0 4.5-3 8.5-7 10-4-1.5-7-5.5-7-10V6z'], ['store', 'Mağaza', 'M5 8h14l-1 12H6zM9 8V6a3 3 0 0 1 6 0v2'], ['profile', 'Profil', 'M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8zM4 21c1-4 4.5-6 8-6s7 2 8 6']];
function TabBar({
  active = 'home',
  onChange
}) {
  return /*#__PURE__*/React.createElement("nav", {
    style: {
      display: 'flex',
      padding: '8px 8px 26px',
      background: 'linear-gradient(180deg, transparent, var(--bg-deep) 30%)',
      borderTop: '1px solid var(--line-soft)'
    }
  }, TABS.map(([k, l, d]) => {
    const on = k === active;
    return /*#__PURE__*/React.createElement("button", {
      key: k,
      onClick: () => onChange && onChange(k),
      style: {
        flex: 1,
        height: 52,
        border: 0,
        background: 'transparent',
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        gap: 4,
        color: on ? 'var(--accent-hi)' : 'var(--text-dim)',
        cursor: 'pointer'
      }
    }, /*#__PURE__*/React.createElement("svg", {
      width: "22",
      height: "22",
      viewBox: "0 0 24 24",
      fill: "none",
      stroke: "currentColor",
      strokeWidth: "2",
      strokeLinecap: "round",
      strokeLinejoin: "round"
    }, /*#__PURE__*/React.createElement("path", {
      d: d
    })), /*#__PURE__*/React.createElement("span", {
      style: {
        font: 'var(--type-micro)',
        fontWeight: on ? 600 : 500
      }
    }, l));
  }));
}
Object.assign(__ds_scope, { TabBar });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/navigation/TabBar.jsx", error: String((e && e.message) || e) }); }

__ds_ns.CurrencyPill = __ds_scope.CurrencyPill;

__ds_ns.RarityFrame = __ds_scope.RarityFrame;

__ds_ns.Button = __ds_scope.Button;

__ds_ns.Chip = __ds_scope.Chip;

__ds_ns.IconButton = __ds_scope.IconButton;

__ds_ns.ProgressBar = __ds_scope.ProgressBar;

__ds_ns.SegmentedControl = __ds_scope.SegmentedControl;

__ds_ns.Switch = __ds_scope.Switch;

__ds_ns.Checker = __ds_scope.Checker;

__ds_ns.Clock = __ds_scope.Clock;

__ds_ns.Die = __ds_scope.Die;

__ds_ns.PlayerCard = __ds_scope.PlayerCard;

__ds_ns.RankBadge = __ds_scope.RankBadge;

__ds_ns.StatusBanner = __ds_scope.StatusBanner;

__ds_ns.Sheet = __ds_scope.Sheet;

__ds_ns.TabBar = __ds_scope.TabBar;

})();
