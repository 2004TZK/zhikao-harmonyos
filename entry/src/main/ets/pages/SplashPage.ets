import { NavigationService } from '../service/NavigationService';
import { RouteConstants } from '../constants/RouteConstants';

/**
 * 启动页（T1.3 占位版，完整逻辑 T4.1 实现）。
 * 职责：登录态检查与路由分发。
 * T1.3 阶段登录态使用 mock（NavigationService.loggedIn），
 * T1.7 store 落地后改为读取 AppStorage。
 */
@Entry
@Component
struct SplashPage {
  @State title: string = '知考';

  aboutToAppear(): void {
    // mock 登录态检查（T1.3 演示：默认未登录 → 跳登录页）
    // T4.1 改为：Token 校验 → 主页/登录页分流
    setTimeout(() => {
      if (NavigationService.isLoggedIn()) {
        NavigationService.resetToMain();
      } else {
        NavigationService.resetToLogin();
      }
    }, 500);
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
