import { RouterManager } from '../service/RouterManager';
import { RouteConstants } from '../constants/RouteConstants';
import { AppStore } from '../store/AppStore';

/**
 * 应用入口：Navigation 容器（T1.3 路由基建）。
 * 注入全局 NavPathStack 到 RouterManager，初始化全局 store，启动即跳转 SplashPage。
 */
@Entry
@Component
struct Index {
  pathStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    RouterManager.getInstance().setStack(this.pathStack);
    AppStore.initDefaults();
  }

  build() {
    Navigation(this.pathStack) {
      // 容器空内容，启动后由 SplashPage 承担分发
    }
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .onAppear(() => {
      // 延迟到页面容器就绪后跳转启动页
      setTimeout(() => {
        RouterManager.getInstance().clearTo(RouteConstants.SPLASH);
      }, 0);
    })
  }
}
