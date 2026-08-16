/**
 * 主题色常量（T1.7）。
 * 契约来源：任务书 1.x 产品定位 / 2.2 主题（浅色/深色 token 见 theme/）。
 */
export class ThemeColors {
  /** 品牌主色 */
  static readonly PRIMARY: string = '#1A73E8';
  /** 页面背景 */
  static readonly BACKGROUND: string = '#FFFFFF';
  /** 内容卡片背景 */
  static readonly CARD_BACKGROUND: string = '#F5F6FA';
  /** 主文字 */
  static readonly TEXT_PRIMARY: string = '#1A1A1A';
  /** 次要文字 */
  static readonly TEXT_SECONDARY: string = '#666666';
  /** 弱化文字 */
  static readonly TEXT_TERTIARY: string = '#999999';
  /** 分割线 */
  static readonly DIVIDER: string = '#EEEEEE';
  /** 成功（答对/完成） */
  static readonly SUCCESS: string = '#34A853';
  /** 警示（答错/待复习） */
  static readonly WARNING: string = '#FBBC04';
  /** 错误（错题） */
  static readonly DANGER: string = '#E53935';
}
