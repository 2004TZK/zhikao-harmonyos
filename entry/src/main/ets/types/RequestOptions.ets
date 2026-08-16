/**
 * 请求选项（HttpClient 统一请求参数）。
 */
export class RequestOptions {
  /** 请求方法，默认 GET */
  method: string = 'GET';
  /** 请求体（对象，将自动 JSON 序列化） */
  body: Object | null = null;
  /** 附加 Header（业务自定义） */
  headers: Record<string, string> = {};
  /** 是否附加 Token，默认 true */
  needAuth: boolean = true;
  /** 请求超时（毫秒），默认 10s */
  timeout: number = 10000;
}
