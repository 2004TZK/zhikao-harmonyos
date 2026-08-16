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
  private bootstrapped: boolean = false;

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
      // 冷启动优化（T9.7）：容器就绪后立即跳转启动页（消除冗余延迟）
      RouterManager.getInstance().clearTo(RouteConstants.SPLASH);
      this.bootstrapped = true;
    })
    .onNavBarStateChange((isShown: boolean) => {
      // 导航栈被清空（返回键 pop 出全部页面）时兜底跳转启动页，避免白屏（T1.4 修复）
      // 仅兜底运行期清空，跳过启动阶段的首次 NavBar 显示
      if (isShown && this.bootstrapped) {
        RouterManager.getInstance().clearTo(RouteConstants.SPLASH);
      }
    })
  }
}
