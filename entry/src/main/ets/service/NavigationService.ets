import { RouterManager } from './RouterManager';
import { RouteConstants } from '../constants/RouteConstants';

/**
 * 统一路由服务（T1.3）。
 *
 * <p>业务页面跳转的唯一入口：内部封装 RouterManager 与登录守卫。
 *  - push：压栈跳转
 *  - pushAuth：访问受保护页面，未登录时跳转登录页（登录成功后返回原页面）
 *  - replace / back / resetToMain 等基础操作
 *
 * <p>登录态判断暂时使用 mock（T1.3 阶段），T1.7 全局 store 落地后接入 AppStorage。
 */
export class NavigationService {

  /** mock：当前是否已登录（T1.3 占位，T1.7 接入真实 store） */
  private static loggedIn: boolean = false;

  /** 注入登录态（由登录页/启动页在真实流程中调用，T1.7 后由 store 驱动） */
  static setLoggedIn(value: boolean): void {
    NavigationService.loggedIn = value;
  }

  static isLoggedIn(): boolean {
    return NavigationService.loggedIn;
  }

  /** 普通跳转 */
  static push(name: string, param?: Object): void {
    RouterManager.getInstance().push(name, param);
  }

  /** 带回调跳转 */
  static pushWithCallback(name: string, onPop: (result: PopInfo) => void, param?: Object): void {
    RouterManager.getInstance().pushWithCallback(name, onPop, param);
  }

  /**
   * 访问受保护页面：未登录先跳登录页，登录成功后继续跳转目标页。
   * 目标页地址通过回调参数传递，避免依赖全局变量。
   */
  static pushAuth(name: string, param?: Object): void {
    if (NavigationService.isLoggedIn()) {
      RouterManager.getInstance().push(name, param);
    } else {
      const target: AuthTarget = new AuthTarget(name, param);
      RouterManager.getInstance().pushWithCallback(
        RouteConstants.LOGIN, (popInfo: PopInfo) => {
          const result = popInfo.result as LoginResult;
          if (result.loggedIn) {
            RouterManager.getInstance().push(target.targetName, target.targetParam);
          }
        }, target);
    }
  }

  /** 替换当前页面 */
  static replace(name: string, param?: Object): void {
    RouterManager.getInstance().replace(name, param);
  }

  /** 返回上一页 */
  static back(): void {
    RouterManager.getInstance().back();
  }

  /** 清空栈并跳转主容器（登录成功后使用） */
  static resetToMain(): void {
    RouterManager.getInstance().clearTo(RouteConstants.MAIN);
  }

  /** 清空栈并跳转登录页（退出登录后使用） */
  static resetToLogin(): void {
    RouterManager.getInstance().clearTo(RouteConstants.LOGIN);
  }
}

/** 登录页 onPop 回调结果约定 */
export class LoginResult {
  loggedIn: boolean = false;
}

/** pushAuth 未登录时携带的目标页信息 */
export class AuthTarget {
  targetName: string = '';
  targetParam: Object | undefined = undefined;

  constructor(name: string, param?: Object) {
    this.targetName = name;
    this.targetParam = param;
  }
}
