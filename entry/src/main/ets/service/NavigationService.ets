import { RouterManager } from './RouterManager';
import { RouteConstants } from '../constants/RouteConstants';
import { AppStore } from '../store/AppStore';

/**
 * 统一路由服务（T1.3/T4.1）。
 *
 * <p>业务页面跳转的唯一入口：内部封装 RouterManager 与登录守卫。
 *  - push：压栈跳转
 *  - pushAuth：访问受保护页面，未登录时跳转登录页（登录成功后返回原页面）
 *  - replace / back / resetToMain 等基础操作
 *
 * <p>登录态以 AppStore（AppStorage）为准，setLoggedIn 同步写入 store。
 */
export class NavigationService {

  /** 注入登录态（登录/登出时调用，同步 AppStore） */
  static setLoggedIn(value: boolean): void {
    if (value) {
      // 已由调用方写入用户信息，仅确保标记
    } else {
      AppStore.setLogout();
    }
  }

  static isLoggedIn(): boolean {
    return AppStore.isLoggedIn();
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
