import { NavigationService } from '../service/NavigationService';
import { RouteConstants } from '../constants/RouteConstants';
import { TokenService } from '../service/TokenService';
import { AppStore } from '../store/AppStore';
import { HttpClient } from '../service/HttpClient';

/**
 * 启动页（T4.1：Token 校验 → 主页/登录页分流）。
 * 逻辑：
 *  1. 读取本地登录态（Preferences 中 Access Token）
 *  2. 无 Token → 清本地态进登录页
 *  3. 有 Token → 调 /auth/profile 校验（HttpClient 内部处理 2001 自动刷新；
 *     refresh 失败（2002）时 HttpClient 已清除本地态并跳登录页）
 *  4. 校验通过 → 进主容器
 */
@Entry
@Component
struct SplashPage {
  @State title: string = '知考';

  aboutToAppear(): void {
    this.checkTokenAndRoute();
  }

  /** Token 校验与路由分发 */
  async checkTokenAndRoute(): Promise<void> {
    // 展示 500ms 启动页后开始校验（避免闪屏）
    await this.delay(500);

    const loggedIn = await TokenService.isLoggedIn();
    if (!loggedIn) {
      // 无登录态：确保本地干净，进登录页
      NavigationService.setLoggedIn(false);
      NavigationService.resetToLogin();
      return;
    }

    // 有 Token：调 profile 校验有效性（2001 自动刷新，2002 内部已清态跳登录）
    const response = await HttpClient.get<Object>('/auth/profile');
    if (response.code === 0) {
      // 校验通过：同步 store 登录态，进主容器
      const userId = await TokenService.getUserId();
      const username = await TokenService.getUsername();
      const nickname = await TokenService.getNickname();
      const userType = await TokenService.getUserType();
      AppStore.setLogin(userId, username, nickname, userType);
      NavigationService.setLoggedIn(true);
      NavigationService.resetToMain();
    } else {
      // 校验失败（非 2001/2002 场景，如网络异常）：仍允许进入登录页
      NavigationService.setLoggedIn(false);
      NavigationService.resetToLogin();
    }
  }

  delay(ms: number): Promise<void> {
    return new Promise<void>((resolve) => {
      setTimeout(() => {
        resolve();
      }, ms);
    });
  }

  build() {
    Column() {
      Text(this.title)
        .fontSize(36)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A73E8')
      Text('公务员常识与成语学习')
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 8 })
      LoadingProgress()
        .width(40)
        .height(40)
        .margin({ top: 32 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Color.White)
  }
}
