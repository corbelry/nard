import { ReactNode, CSSProperties, ButtonHTMLAttributes } from 'react';
/** @startingPoint section="Core" subtitle="Primary / secondary / ghost / danger buttons" viewport="700x260" */
export interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'ghost' | 'danger' | 'outline';
  size?: 'l' | 'm' | 's';
  disabled?: boolean;
  pressed?: boolean;
  /** Secondary inline text, e.g. "0 / 2" move counter */
  sub?: ReactNode;
  children?: ReactNode;
  style?: CSSProperties;
}
export declare function Button(props: ButtonProps): JSX.Element;
