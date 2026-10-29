import { ReactNode } from 'react';
export interface RarityFrameProps { rarity?: 'common' | 'rare' | 'epic' | 'legendary' | 'seasonal'; name: string; /** "Taxılıb", "1 200", "Sezon · Səv. 30" */ status?: string; equipped?: boolean; locked?: boolean; /** item thumbnail */ children?: ReactNode; width?: number; }
export declare function RarityFrame(props: RarityFrameProps): JSX.Element;
