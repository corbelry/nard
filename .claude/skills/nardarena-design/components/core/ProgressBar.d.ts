import { CSSProperties } from 'react';
export interface ProgressBarProps { /** 0..1 */ value: number; tone?: 'accent' | 'success' | 'danger' | 'platinum' | string; height?: number; style?: CSSProperties; }
export declare function ProgressBar(props: ProgressBarProps): JSX.Element;
