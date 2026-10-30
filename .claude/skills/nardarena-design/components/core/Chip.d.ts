import { ReactNode, CSSProperties, HTMLAttributes } from 'react';
export interface ChipProps extends HTMLAttributes<HTMLSpanElement> { selected?: boolean; children?: ReactNode; style?: CSSProperties; }
export declare function Chip(props: ChipProps): JSX.Element;
