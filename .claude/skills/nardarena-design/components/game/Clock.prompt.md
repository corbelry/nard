Game clock: reserve time + delay bar. `active` inverts (ivory pill), `low` (< 10 s) turns garnet with glow + haptic tick.
```jsx
<Clock time="3:24" delay={0.7} state="active"/><Clock time="0:09" delay={0} state="low"/>
```
