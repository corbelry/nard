export interface StatusBannerProps { title: string; sub?: string; tone?: 'brass' | 'dim' | 'danger' | 'ok'; /** diamond + hairline flourish (off in komur theme) */ ornament?: boolean; }
export declare function StatusBanner(props: StatusBannerProps): JSX.Element;
