import { CSSProperties } from 'react';
export interface SegmentedControlProps { options: string[]; value: string; onChange?: (v: string) => void; style?: CSSProperties; }
export declare function SegmentedControl(props: SegmentedControlProps): JSX.Element;
