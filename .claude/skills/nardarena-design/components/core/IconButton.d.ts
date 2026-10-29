import { ReactNode, CSSProperties, ButtonHTMLAttributes } from 'react';
export interface IconButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  /** Accessible name (required) */
  label: string;
  /** Small caption under the icon (in-game controls: "Geri al", "İkiqat") */
  caption?: string;
  round?: boolean;
  tone?: 'default' | 'accent' | 'danger';
  size?: number;
  children?: ReactNode;
  style?: CSSProperties;
}
export declare function IconButton(props: IconButtonProps): JSX.Element;
