export interface TabBarProps { active?: 'home' | 'tour' | 'clan' | 'store' | 'profile'; onChange?: (tab: string) => void; }
export declare function TabBar(props: TabBarProps): JSX.Element;
