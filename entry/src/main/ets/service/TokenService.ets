import { PreferencesService } from './PreferencesService';

/**
 * Token 服务（T1.6 完整版）。
 * 职责：Access/Refresh Token、用户信息与登录态的本地存取（Preferences）。
 * 验收：冷启动可读取登录态；登出后本地 Token 清空。
 */
export class TokenService {
  private static readonly KEY_ACCESS_TOKEN: string = 'access_token';
  private static readonly KEY_REFRESH_TOKEN: string = 'refresh_token';
  private static readonly KEY_USER_ID: string = 'user_id';
  private static readonly KEY_USERNAME: string = 'username';
  private static readonly KEY_NICKNAME: string = 'nickname';
  private static readonly KEY_USER_TYPE: string = 'user_type';
  private static readonly KEY_IS_LOGIN: string = 'is_login';

  static async getAccessToken(): Promise<string> {
    return PreferencesService.getInstance().getString(TokenService.KEY_ACCESS_TOKEN);
  }

  static async getRefreshToken(): Promise<string> {
    return PreferencesService.getInstance().getString(TokenService.KEY_REFRESH_TOKEN);
  }

  /** 保存双 Token */
  static async saveTokens(accessToken: string, refreshToken: string): Promise<void> {
    const pref = PreferencesService.getInstance();
    await pref.putString(TokenService.KEY_ACCESS_TOKEN, accessToken);
    await pref.putString(TokenService.KEY_REFRESH_TOKEN, refreshToken);
  }

  /** 保存用户信息并标记已登录 */
  static async saveUserInfo(userId: number, username: string, nickname: string, userType: number): Promise<void> {
    const pref = PreferencesService.getInstance();
    await pref.putNumber(TokenService.KEY_USER_ID, userId);
    await pref.putString(TokenService.KEY_USERNAME, username);
    await pref.putString(TokenService.KEY_NICKNAME, nickname);
    await pref.putNumber(TokenService.KEY_USER_TYPE, userType);
    await pref.putBoolean(TokenService.KEY_IS_LOGIN, true);
  }

  static async getUserId(): Promise<number> {
    return PreferencesService.getInstance().getNumber(TokenService.KEY_USER_ID);
  }

  static async getUsername(): Promise<string> {
    return PreferencesService.getInstance().getString(TokenService.KEY_USERNAME);
  }

  static async getNickname(): Promise<string> {
    return PreferencesService.getInstance().getString(TokenService.KEY_NICKNAME);
  }

  static async getUserType(): Promise<number> {
    return PreferencesService.getInstance().getNumber(TokenService.KEY_USER_TYPE);
  }

  /** 冷启动读取登录态（有 Access Token 且标记已登录） */
  static async isLoggedIn(): Promise<boolean> {
    const isLogin = await PreferencesService.getInstance().getBoolean(TokenService.KEY_IS_LOGIN);
    if (!isLogin) {
      return false;
    }
    const accessToken = await TokenService.getAccessToken();
    return accessToken !== '';
  }

  /** 登出：清空 Token 与登录态（本地清空即可，任务书 2.3 不做 JWT 黑名单） */
  static async clear(): Promise<void> {
    const pref = PreferencesService.getInstance();
    await pref.remove(TokenService.KEY_ACCESS_TOKEN);
    await pref.remove(TokenService.KEY_REFRESH_TOKEN);
    await pref.remove(TokenService.KEY_USER_ID);
    await pref.remove(TokenService.KEY_USERNAME);
    await pref.remove(TokenService.KEY_NICKNAME);
    await pref.remove(TokenService.KEY_USER_TYPE);
    await pref.putBoolean(TokenService.KEY_IS_LOGIN, false);
  }
}
