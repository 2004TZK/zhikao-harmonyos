import { AppStore } from '../store/AppStore';
import { NavigationService } from '../service/NavigationService';
import { RouteConstants } from '../constants/RouteConstants';
import { ThemeColors } from '../constants/ThemeColors';
import { TokenService } from '../service/TokenService';

/**
 * 我的页（T8.3）：个人信息/统计摘要/功能入口。
 */
@Entry
@Component
struct MinePage {
  @State nickname: string = '';

  aboutToAppear(): void {
    this.nickname = AppStore.getNickname();
  }

  async logout(): Promise<void> {
    await TokenService.clear();
    AppStore.setLogout();
    NavigationService.setLoggedIn(false);
    NavigationService.resetToLogin();
  }

  build() {
    Column() {
      // 用户信息区
      Column() {
        Text('👤')
          .fontSize(48)
        Text(this.nickname)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 8 })
        Text(AppStore.getUserType() === 2 ? '游客模式' : '正式用户')
          .fontSize(12)
          .fontColor(ThemeColors.TEXT_TERTIARY)
          .margin({ top: 4 })
      }
      .width('100%')
      .padding({ top: 32, bottom: 24 })

      // 功能入口
      Column() {
        this.EntryRow('学习统计', () => {
          NavigationService.push(RouteConstants.STATS);
        })
        this.EntryRow('学习记录', () => {
          NavigationService.push(RouteConstants.STUDY_RECORD);
        })
        this.EntryRow('我的收藏', () => {
          NavigationService.push(RouteConstants.FAVORITE);
        })
        this.EntryRow('错题本', () => {
          NavigationService.push(RouteConstants.WRONG_QUESTION);
        })
        this.EntryRow('设置', () => {
          NavigationService.push(RouteConstants.SETTINGS);
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
      .margin({ top: 8 })

      Button('退出登录')
        .width('88%')
        .height(46)
        .margin({ top: 24 })
        .backgroundColor(ThemeColors.DANGER)
        .onClick(() => {
          this.logout();
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.BACKGROUND)
  }

  @Builder
  EntryRow(title: string, action: () => void) {
    Row() {
      Text(title)
        .fontSize(15)
        .layoutWeight(1)
      Text('>')
        .fontSize(14)
        .fontColor(ThemeColors.TEXT_TERTIARY)
    }
    .width('100%')
    .padding(14)
    .margin({ top: 8 })
    .borderRadius(10)
    .backgroundColor(ThemeColors.CARD_BACKGROUND)
    .onClick(() => {
      action();
    })
  }
}
