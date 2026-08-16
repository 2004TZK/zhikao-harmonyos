import { ThemeColors } from '../constants/ThemeColors';

/**
 * 全局状态（T1.7）：AppStorage 封装。
 * 职责（任务书 2.2/3.1 store 层）：
 *  - 当前用户（userId/username/nickname/userType）
 *  - 登录态
 *  - 全局主题（浅色/深色）
 * 不使用 LocalStorage 持久化业务数据（任务书 v1.3 修正）。
 */
export class AppStore {
  private static readonly KEY_USER_ID: string = 'app_user_id';
  private static readonly KEY_USERNAME: string = 'app_username';
  private static readonly KEY_NICKNAME: string = 'app_nickname';
  private static readonly KEY_USER_TYPE: string = 'app_user_type';
  private static readonly KEY_IS_LOGIN: string = 'app_is_login';
  private static readonly KEY_THEME: string = 'app_theme';
  private static readonly KEY_PRIMARY_COLOR: string = 'app_primary_color';

  static initDefaults(): void {
    if (!AppStorage.has(AppStore.KEY_IS_LOGIN)) {
      AppStorage.setOrCreate(AppStore.KEY_IS_LOGIN, false);
    }
    if (!AppStorage.has(AppStore.KEY_USER_ID)) {
      AppStorage.setOrCreate(AppStore.KEY_USER_ID, 0);
    }
    if (!AppStorage.has(AppStore.KEY_USERNAME)) {
      AppStorage.setOrCreate(AppStore.KEY_USERNAME, '');
    }
    if (!AppStorage.has(AppStore.KEY_NICKNAME)) {
      AppStorage.setOrCreate(AppStore.KEY_NICKNAME, '');
    }
    if (!AppStorage.has(AppStore.KEY_USER_TYPE)) {
      AppStorage.setOrCreate(AppStore.KEY_USER_TYPE, 1);
    }
    if (!AppStorage.has(AppStore.KEY_THEME)) {
      AppStorage.setOrCreate(AppStore.KEY_THEME, 'light');
    }
    if (!AppStorage.has(AppStore.KEY_PRIMARY_COLOR)) {
      AppStorage.setOrCreate(AppStore.KEY_PRIMARY_COLOR, ThemeColors.PRIMARY);
    }
  }

  /** 登录成功：写入用户信息与登录态 */
  static setLogin(userId: number, username: string, nickname: string, userType: number): void {
    AppStorage.setOrCreate(AppStore.KEY_USER_ID, userId);
    AppStorage.setOrCreate(AppStore.KEY_USERNAME, username);
    AppStorage.setOrCreate(AppStore.KEY_NICKNAME, nickname);
    AppStorage.setOrCreate(AppStore.KEY_USER_TYPE, userType);
    AppStorage.setOrCreate(AppStore.KEY_IS_LOGIN, true);
  }

  /** 登出/Token 失效：清空登录态（不删除主题） */
  static setLogout(): void {
    AppStorage.setOrCreate(AppStore.KEY_USER_ID, 0);
    AppStorage.setOrCreate(AppStore.KEY_USERNAME, '');
    AppStorage.setOrCreate(AppStore.KEY_NICKNAME, '');
    AppStorage.setOrCreate(AppStore.KEY_USER_TYPE, 1);
    AppStorage.setOrCreate(AppStore.KEY_IS_LOGIN, false);
  }

  static isLoggedIn(): boolean {
    return AppStorage.get<boolean>(AppStore.KEY_IS_LOGIN) ?? false;
  }

  static getUserId(): number {
    return AppStorage.get<number>(AppStore.KEY_USER_ID) ?? 0;
  }

  static getUsername(): string {
    return AppStorage.get<string>(AppStore.KEY_USERNAME) ?? '';
  }

  static getNickname(): string {
    return AppStorage.get<string>(AppStore.KEY_NICKNAME) ?? '';
  }

  static getUserType(): number {
    return AppStorage.get<number>(AppStore.KEY_USER_TYPE) ?? 1;
  }

  /** 主题切换（light/dark），页面通过 @StorageProp('app_theme') 订阅 */
  static setTheme(theme: string): void {
    AppStorage.setOrCreate(AppStore.KEY_THEME, theme);
  }

  static getTheme(): string {
    return AppStorage.get<string>(AppStore.KEY_THEME) ?? 'light';
  }

  /** 主题色（页面通过 @StorageProp('app_primary_color') 订阅，修改后 1 帧内刷新） */
  static setPrimaryColor(color: string): void {
    AppStorage.setOrCreate(AppStore.KEY_PRIMARY_COLOR, color);
  }

  static getPrimaryColor(): string {
    return AppStorage.get<string>(AppStore.KEY_PRIMARY_COLOR) ?? ThemeColors.PRIMARY;
  }
}
