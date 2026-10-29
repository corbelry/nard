import { CSSProperties } from 'react';
export interface DieProps { value: 1 | 2 | 3 | 4 | 5 | 6; /** default 44 (board die) */ size?: number; state?: 'idle' | 'rolling' | 'used'; style?: CSSProperties; }
export declare function Die(props: DieProps): JSX.Element;
