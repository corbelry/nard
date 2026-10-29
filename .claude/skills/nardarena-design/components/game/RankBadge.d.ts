export interface RankBadgeProps { tier: 'bronze' | 'silver' | 'gold' | 'platinum' | 'diamond' | 'master' | 'grandmaster'; /** I, II, III */ sub?: 'I' | 'II' | 'III'; size?: number; showLabel?: boolean; }
export declare function RankBadge(props: RankBadgeProps): JSX.Element;
