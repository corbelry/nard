import { ReactNode } from 'react';
/** @startingPoint section="Game" subtitle="In-game player row with rank, pip count and clock" viewport="700x300" */
export interface PlayerCardProps { name: string; initials?: string; flag?: 'az' | 'tr' | 'ru'; rating: number; rank?: string; tier?: 'bronze' | 'silver' | 'gold' | 'platinum' | 'diamond' | 'master' | 'grandmaster'; pip: number; clock?: string; delay?: number; active?: boolean; low?: boolean; offline?: boolean; /** e.g. emote button */ trailing?: ReactNode; }
export declare function PlayerCard(props: PlayerCardProps): JSX.Element;
