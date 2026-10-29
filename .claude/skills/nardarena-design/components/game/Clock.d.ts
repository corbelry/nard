import { CSSProperties } from 'react';
export interface ClockProps { /** reserve time m:ss */ time: string; /** remaining delay fraction 0..1 */ delay?: number; delaySeconds?: number; state?: 'idle' | 'active' | 'low'; style?: CSSProperties; }
export declare function Clock(props: ClockProps): JSX.Element;
