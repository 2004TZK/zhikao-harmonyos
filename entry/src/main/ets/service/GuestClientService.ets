import { GuestIdService } from './GuestIdService';
import { HttpClient } from './HttpClient';
import { TokenService } from './TokenService';
import { AppStore } from '../store/AppStore';
import { NavigationService } from './NavigationService';

/**
 * 游客模式客户端服务（T4.3）。
 * 流程：UUID（Preferences 持久化）→ /auth/guest 换 Token → 保存登录态 → 主容器。
 * 9001（额度用尽）时展示登录引导（由调用方处理）。
 */
export class GuestClientService {

  /** 游客身份换取 Token 并进入主容器（幂等：同设备复用同一游客账号） */
  static async loginAsGuest(): Promise<number> {
    const guestUuid = await GuestIdService.getOrCreateGuestUuid();
    const body = new GuestRequestBody();
    body.guestUuid = guestUuid;

    const response = await HttpClient.postPublic<GuestResponseData>('/auth/guest', body);
    if (response.code === 0 && response.data !== null) {
      const data = response.data;
      await TokenService.saveTokens(data.accessToken, data.refreshToken);
      await TokenService.saveUserInfo(data.userId, data.username, data.nickname, data.userType);
      AppStore.setLogin(data.userId, data.username, data.nickname, data.userType);
      NavigationService.setLoggedIn(true);
      NavigationService.resetToMain();
      return 0;
    }
    return response.code;
  }
}

/** 游客换取 Token 请求（契约 6.1/6.2） */
export class GuestRequestBody {
  guestUuid: string = '';
}

/** 游客换取 Token 响应 data */
export class GuestResponseData {
  accessToken: string = '';
  refreshToken: string = '';
  expiresIn: number = 0;
  userId: number = 0;
  username: string = '';
  nickname: string = '';
  userType: number = 0;
}
