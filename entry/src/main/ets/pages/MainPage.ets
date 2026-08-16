import { RouteConstants } from '../constants/RouteConstants';
import { NavigationService } from '../service/NavigationService';

/**
 * 主容器（T1.3 占位版，完整 TabBar 结构 T1.4 实现）。
 * 演示受保护页面：未登录访问会先跳登录页。
 */
@Entry
@Component
struct MainPage {
  @State currentTab: number = 0;

  build() {
    Column() {
      Text('主容器（TabBar 占位，T1.4 完成）')
        .fontSize(16)
        .fontColor('#333333')
        .margin({ top: 60 })

      Text('首页 | 学习 | 练习 | 复习 | 我的')
        .fontSize(13)
        .fontColor('#999999')
        .margin({ top: 16 })

      Button('访问受保护页面：常识分类（演示登录守卫）')
        .width('80%')
        .margin({ top: 40 })
        .onClick(() => {
          // 未登录时 pushAuth 会先跳登录页，登录后自动继续跳转
          NavigationService.pushAuth(RouteConstants.KNOWLEDGE_CATEGORY);
        })

      Button('退出登录')
        .width('80%')
        .margin({ top: 16 })
        .backgroundColor('#E53935')
        .onClick(() => {
          NavigationService.setLoggedIn(false);
          NavigationService.resetToLogin();
        })
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(Color.White)
  }
}
