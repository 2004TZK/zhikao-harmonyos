/**
 * 路由管理器（T1.3）。
 *
 * <p>持有全局唯一 NavPathStack（由 Navigation 容器在 aboutToAppear 时注入），
 * 对业务层暴露统一的路由操作。业务页面禁止直接调用底层路由 API（任务书 2.2）。
 */
export class RouterManager {
  private static instance: RouterManager = new RouterManager();
  private stack: NavPathStack | undefined = undefined;

  private constructor() {
  }

  static getInstance(): RouterManager {
    return RouterManager.instance;
  }

  /** 由 Navigation 容器注入 NavPathStack（Index.ets aboutToAppear 调用） */
  setStack(stack: NavPathStack): void {
    this.stack = stack;
  }

  /** 压栈跳转（携带可选参数） */
  push(name: string, param?: Object): void {
    this.stack?.pushPath(new NavPathInfo(name, param));
  }

  /** 压栈跳转（带 onPop 回调） */
  pushWithCallback(name: string, onPop: (result: PopInfo) => void, param?: Object): void {
    this.stack?.pushPath(new NavPathInfo(name, param, onPop));
  }

  /** 替换当前页面（不回退） */
  replace(name: string, param?: Object): void {
    this.stack?.replacePath(new NavPathInfo(name, param));
  }

  /** 返回上一页 */
  back(): void {
    this.stack?.pop();
  }

  /** 清空栈并跳转到指定页面（登录/退出登录后使用） */
  clearTo(name: string, param?: Object): void {
    this.stack?.clear();
    this.stack?.pushPath(new NavPathInfo(name, param));
  }

  /** 获取当前栈深度 */
  getStackSize(): number {
    return this.stack?.size() ?? 0;
  }

  /** 按页面名获取其路由参数（NavPathStack.getParamByName） */
  getParamByName(name: string): Object | undefined {
    return this.stack?.getParamByName(name) as Object | undefined;
  }
}
