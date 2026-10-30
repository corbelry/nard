import { CSSProperties } from 'react';
export interface CheckerProps { side?: 'ivory' | 'onyx'; size?: number; selected?: boolean; /** adds ring (ivory) / dot (onyx) shape cue */ colorBlind?: boolean; /** stack count label when compressed */ count?: number; style?: CSSProperties; }
export declare function Checker(props: CheckerProps): JSX.Element;
