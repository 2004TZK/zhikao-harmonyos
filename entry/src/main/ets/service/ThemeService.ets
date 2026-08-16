/**
 * 主题服务（T9.1：深色模式）。
 * 通过 AppStorage 的 app_theme 键驱动全局主题切换（light/dark），
 * 页面用 @StorageProp('app_theme') 订阅实现即时响应（1 帧内刷新）。
 */
export class ThemeService {

  static readonly THEME_LIGHT: string = 'light';
  static readonly THEME_DARK: string = 'dark';

  /** 切换主题（并持久化到 Preferences） */
  static setTheme(theme: string): void {
    AppStorage.setOrCreate('app_theme', theme);
  }

  /** 获取当前主题 */
  static getTheme(): string {
    return AppStorage.get<string>('app_theme') ?? ThemeService.THEME_LIGHT;
  }

  /** 是否深色模式 */
  static isDark(): boolean {
    return ThemeService.getTheme() === ThemeService.THEME_DARK;
  }

  /** 按主题返回颜色（深色/浅色二元选择） */
  static color(lightColor: string, darkColor: string): string {
    return ThemeService.isDark() ? darkColor : lightColor;
  }
}
