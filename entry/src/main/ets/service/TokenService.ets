import { PreferencesService } from './PreferencesService';

/**
 * Token 服务（T1.5 骨架，T1.6 完整验收）。
 * 职责：Access/Refresh Token 与用户登录态的本地存取。
 */
export class TokenService {
  private static readonly KEY_ACCESS_TOKEN: string = 'access_token';
  private static readonly KEY_REFRESH_TOKEN: string = 'refresh_token';
  private static readonly KEY_USER_ID: string = 'user_id';
  private static readonly KEY_USER_TYPE: string = 'user_type';
  private static readonly KEY_IS_LOGIN: string = 'is_login';

  static async getAccessToken(): Promise<string> {
    return PreferencesService.getInstance().getString(TokenService.KEY_ACCESS_TOKEN);
  }

  static async getRefreshToken(): Promise<string> {
    return PreferencesService.getInstance().getString(TokenService.KEY_REFRESH_TOKEN);
  }

  static async saveTokens(accessToken: string, refreshToken: string): Promise<void> {
    await PreferencesService.getInstance().putString(TokenService.KEY_ACCESS_TOKEN, accessToken);
    await PreferencesService.getInstance().putString(TokenService.KEY_REFRESH_TOKEN, refreshToken);
  }

  static async saveUserInfo(userId: number, userType: number): Promise<void> {
    await PreferencesService.getInstance().putNumber(TokenService.KEY_USER_ID, userId);
    await PreferencesService.getInstance().putNumber(TokenService.KEY_USER_TYPE, userType);
  }

  static async getUserId(): Promise<number> {
    return PreferencesService.getInstance().getNumber(TokenService.KEY_USER_ID);
  }

  static async isLoggedIn(): Promise<boolean> {
    return PreferencesService.getInstance().getBoolean(TokenService.KEY_IS_LOGIN);
  }

  static async setLoggedIn(value: boolean): Promise<void> {
    await PreferencesService.getInstance().putBoolean(TokenService.KEY_IS_LOGIN, value);
  }

  /** 清空本地 Token 与登录态（登出时调用） */
  static async clear(): Promise<void> {
    const pref = PreferencesService.getInstance();
    await pref.remove(TokenService.KEY_ACCESS_TOKEN);
    await pref.remove(TokenService.KEY_REFRESH_TOKEN);
    await pref.remove(TokenService.KEY_USER_ID);
    await pref.remove(TokenService.KEY_USER_TYPE);
    await pref.putBoolean(TokenService.KEY_IS_LOGIN, false);
  }
}
