import { http } from '@kit.NetworkKit';
import { HttpConstants, AuthApi, ApiResponse } from '../constants/HttpConstants';
import { TokenService } from './TokenService';
import { NavigationService } from './NavigationService';
import { RequestOptions } from '../types/RequestOptions';
import { RouteConstants } from '../constants/RouteConstants';

/**
 * 网络请求封装（T1.5）。
 * 职责（任务书 T1.5）：
 *  - baseURL / 超时
 *  - Token 注入（Authorization: Bearer）
 *  - 2001 触发 refresh 静默续期一次后重试
 *  - refresh 失败（2002）清除本地态并跳登录页
 *  - 统一错误码映射（契约 6.1）
 */
export class HttpClient {

  /** 统一 GET（自动附加 Token） */
  static async get<T>(path: string): Promise<ApiResponse<T>> {
    return HttpClient.request<T>(path, new RequestOptions());
  }

  /** 统一 POST JSON */
  static async post<T>(path: string, body: Object): Promise<ApiResponse<T>> {
    const options = new RequestOptions();
    options.method = 'POST';
    options.body = body;
    return HttpClient.request<T>(path, options);
  }

  /**
   * 公开接口 POST（登录/注册/游客等无需 Token 的接口）。
   * 避免携带旧 Access Token 导致服务端按无效凭证拒绝（T4.2 修复）。
   */
  static async postPublic<T>(path: string, body: Object): Promise<ApiResponse<T>> {
    const options = new RequestOptions();
    options.method = 'POST';
    options.body = body;
    options.needAuth = false;
    return HttpClient.request<T>(path, options);
  }

  /** 统一 PUT JSON */
  static async put<T>(path: string, body: Object): Promise<ApiResponse<T>> {
    const options = new RequestOptions();
    options.method = 'PUT';
    options.body = body;
    return HttpClient.request<T>(path, options);
  }

  /** 统一 DELETE */
  static async delete<T>(path: string): Promise<ApiResponse<T>> {
    const options = new RequestOptions();
    options.method = 'DELETE';
    return HttpClient.request<T>(path, options);
  }

  /** 核心请求：注入 Token → 发送 → 2001 时 refresh 后重试一次 */
  private static async request<T>(path: string, options: RequestOptions): Promise<ApiResponse<T>> {
    // 第一次请求（带当前 Token）
    let response = await HttpClient.send<T>(path, options, true);
    if (response.code === 2001) {
      // Access Token 过期：尝试静默续期
      const refreshed = await HttpClient.tryRefresh();
      if (refreshed) {
        // 续期成功：重试原请求（新 Token）
        response = await HttpClient.send<T>(path, options, true);
      } else {
        // 续期失败（2002）：清除本地态跳登录
        await TokenService.clear();
        NavigationService.setLoggedIn(false);
        NavigationService.resetToLogin();
      }
    }
    return response;
  }

  /** 发送单次请求（needAuth 控制是否携带 Token，用于 refresh 请求本身） */
  private static async send<T>(path: string, options: RequestOptions, useToken: boolean): Promise<ApiResponse<T>> {
    const httpRequest = http.createHttp();
    try {
      const headers: Record<string, string> = { 'Content-Type': 'application/json' };
      if (options.headers) {
        for (const key of Object.keys(options.headers)) {
          headers[key] = options.headers[key];
        }
      }
      if (useToken && options.needAuth) {
        const token = await TokenService.getAccessToken();
        if (token !== '') {
          headers[HttpConstants.AUTH_HEADER] = HttpConstants.BEARER_PREFIX + token;
        }
      }

      const requestOptions: http.HttpRequestOptions = {
        method: options.method as http.RequestMethod,
        header: headers,
        connectTimeout: options.timeout,
        readTimeout: options.timeout
      };
      if (options.body !== null && options.body !== undefined) {
        requestOptions.extraData = JSON.stringify(options.body);
      }

      const url = HttpConstants.BASE_URL + path;
      const rawResponse: http.HttpResponse = await httpRequest.request(url, requestOptions);

      const text = rawResponse.result as string;
      return HttpClient.parseResponse<T>(text);
    } catch (e) {
      // 网络异常（断网/超时/连接失败）：返回 5000 兜底，避免页面崩溃（T9.4）
      const apiResponse = new ApiResponse<T>();
      apiResponse.code = 5000;
      apiResponse.message = '网络异常，请检查网络连接';
      return apiResponse;
    } finally {
      httpRequest.destroy();
    }
  }

  /** 解析统一响应 JSON；解析失败视为 5000 */
  private static parseResponse<T>(text: string): ApiResponse<T> {
    const apiResponse = new ApiResponse<T>();
    if (text === '' || text === undefined) {
      apiResponse.code = 5000;
      apiResponse.message = '服务器内部错误';
      return apiResponse;
    }
    try {
      const obj = JSON.parse(text) as ApiResponse<T>;
      apiResponse.code = obj.code;
      apiResponse.message = obj.message;
      apiResponse.data = obj.data;
      return apiResponse;
    } catch (e) {
      // 非 JSON（网关/网络异常等）按 5000 处理，message 兜底
      apiResponse.code = 5000;
      apiResponse.message = '服务器内部错误';
      return apiResponse;
    }
  }

  /** 尝试用 Refresh Token 换取新 Access Token */
  private static async tryRefresh(): Promise<boolean> {
    const refreshToken = await TokenService.getRefreshToken();
    if (refreshToken === '') {
      return false;
    }
    const options = new RequestOptions();
    options.method = 'POST';
    options.needAuth = false;
    const body = new RefreshRequest();
    body.refreshToken = refreshToken;
    options.body = body;
    const response = await HttpClient.send<Object>(AuthApi.REFRESH, options, false);
    if (response.code === 0 && response.data !== null) {
      const data = response.data as RefreshTokenResponse;
      await TokenService.saveTokens(data.accessToken, data.refreshToken);
      return true;
    }
    return false;
  }
}

/** refresh 接口返回结构（契约 6.2） */
export class RefreshTokenResponse {
  accessToken: string = '';
  refreshToken: string = '';
  expiresIn: number = 0;
  userId: number = 0;
  username: string = '';
  userType: number = 0;
}

/** refresh 请求结构（契约 6.2 POST /auth/refresh） */
export class RefreshRequest {
  refreshToken: string = '';
}
