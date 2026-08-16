/**
 * 网络与接口常量（T1.5）。
 * 契约来源：任务书 6.1 统一约定。
 */
export class HttpConstants {
  /** 统一前缀 */
  static readonly API_PREFIX: string = '/api/v1';

  /** 后端地址（开发环境；真机联调改为局域网 IP，如 http://192.168.x.x:8080） */
  static readonly BASE_URL: string = 'http://127.0.0.1:8080' + HttpConstants.API_PREFIX;

  /** 请求超时（毫秒） */
  static readonly TIMEOUT_MS: number = 10000;

  /** 认证 Header */
  static readonly AUTH_HEADER: string = 'Authorization';
  static readonly BEARER_PREFIX: string = 'Bearer ';
}

/** 统一响应结构（契约 6.1：{ code, message, data }） */
export class ApiResponse<T> {
  code: number = 0;
  message: string = '';
  data: T | null = null;
}

/** 认证相关接口路径 */
export class AuthApi {
  static readonly REFRESH: string = '/auth/refresh';
  static readonly LOGIN: string = '/auth/login';
  static readonly GUEST: string = '/auth/guest';
}
