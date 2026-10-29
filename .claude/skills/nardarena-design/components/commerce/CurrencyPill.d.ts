export interface CurrencyPillProps { kind?: 'coin' | 'gem'; /** pre-formatted, e.g. "12 450" (space as thousands separator) */ amount: string | number; }
export declare function CurrencyPill(props: CurrencyPillProps): JSX.Element;
