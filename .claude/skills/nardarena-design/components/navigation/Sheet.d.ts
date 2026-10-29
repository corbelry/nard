import { ReactNode } from 'react';
export interface SheetProps { title?: string; children?: ReactNode; scrim?: boolean; }
export declare function Sheet(props: SheetProps): JSX.Element;
