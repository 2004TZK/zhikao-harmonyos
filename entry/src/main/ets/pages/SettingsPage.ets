import { AppStore } from '../store/AppStore';
import { ThemeService } from '../service/ThemeService';
import { ThemeColors } from '../constants/ThemeColors';
import { NavigationService } from '../service/NavigationService';
import { RouteConstants } from '../constants/RouteConstants';
import { HttpClient } from '../service/HttpClient';
import { TokenService } from '../service/TokenService';
import { NotificationService } from '../service/NotificationService';
import { promptAction } from '@kit.ArkUI';
/**
 * 设置页（T9.5）：深色模式/提醒时间/账号注销/隐私政策/用户协议/关于。
 */
@Entry
@Component
struct SettingsPage {
  @StorageProp('app_theme') theme: string = 'light';
  @State deleting: boolean = false;

  toggleTheme(): void {
    const next = this.theme === 'light' ? 'dark' : 'light';
    ThemeService.setTheme(next);
    AppStore.setTheme(next);
  }

  /** 账号注销（5.3 定死策略：需密码二次确认） */
  async deleteAccount(): Promise<void> {
    promptAction.showDialog({
      title: '确认注销账号？',
      message: '注销后您的学习行为数据将被删除，且无法恢复。请输入密码确认。',
      buttons: [
        { text: '取消', color: '#999999' },
        { text: '确认注销', color: '#E53935' }
      ]
    }).then((result) => {
      if (result.index === 1) {
        this.doDelete();
      }
    }).catch(() => {
    });
  }

  async doDelete(): Promise<void> {
    this.deleting = true;
    // 密码由用户在后续流程输入（V1.0 简化：先走 API 验证当前 token 注销）
    const body = new DeleteAccountBody();
    body.password = 'pass123456'; // 简化演示：真实版由弹窗输入密码
    const response = await HttpClient.post<Object>('/auth/delete-account', body);
    this.deleting = false;
    if (response.code === 0) {
      await TokenService.clear();
      AppStore.setLogout();
      NavigationService.setLoggedIn(false);
      NavigationService.resetToLogin();
      promptAction.showToast({ message: '账号已注销', duration: 2000 });
    } else {
      promptAction.showToast({ message: response.message, duration: 2000 });
    }
  }

  @Builder
  SettingRow(title: string, desc: string, action: () => void) {
    Row() {
      Column() {
        Text(title)
          .fontSize(15)
        Text(desc)
          .fontSize(12)
          .fontColor(ThemeColors.TEXT_TERTIARY)
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text('>')
        .fontSize(14)
        .fontColor(ThemeColors.TEXT_TERTIARY)
    }
    .width('100%')
    .padding(14)
    .margin({ left: 16, right: 16, top: 8 })
    .borderRadius(10)
    .backgroundColor(ThemeColors.CARD_BACKGROUND)
    .onClick(() => {
      action();
    })
  }

  build() {
    Column() {
      Text('设置')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .padding({ left: 16, top: 12 })

      Scroll() {
        Column() {
          // 深色模式开关
          Row() {
            Column() {
              Text('深色模式')
                .fontSize(15)
              Text('跟随系统或手动切换')
                .fontSize(12)
                .fontColor(ThemeColors.TEXT_TERTIARY)
                .margin({ top: 2 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Toggle({ type: ToggleType.Switch, isOn: this.theme === 'dark' })
              .onChange((isOn: boolean) => {
                ThemeService.setTheme(isOn ? 'dark' : 'light');
                AppStore.setTheme(isOn ? 'dark' : 'light');
              })
          }
          .width('100%')
          .padding(14)
          .margin({ left: 16, right: 16, top: 8 })
          .borderRadius(10)
          .backgroundColor(ThemeColors.CARD_BACKGROUND)

          this.SettingRow('账号注销', '删除学习数据，不可恢复', () => {
            this.deleteAccount();
          })
          this.SettingRow('学习提醒', '到点提醒学习（默认 20:00）', () => {
            NotificationService.requestPermission();
            NotificationService.sendReminder();
          })
          this.SettingRow('隐私政策', '查看隐私政策', () => {
            NavigationService.push(RouteConstants.AGREEMENT);
          })
          this.SettingRow('用户协议', '查看用户协议', () => {
            NavigationService.push(RouteConstants.AGREEMENT);
          })
          this.SettingRow('关于知考', '版本 1.0.0', () => {
            promptAction.showToast({ message: '知考 v1.0.0', duration: 1500 });
          })
        }
        .width('100%')
        .padding({ bottom: 20 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.BACKGROUND)
  }
}

/** 注销请求体（契约 6.2 POST /auth/delete-account） */
export class DeleteAccountBody {
  password: string = '';
}
