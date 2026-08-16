import { NavigationService } from '../service/NavigationService';
import { RouteConstants } from '../constants/RouteConstants';
import { TokenService } from '../service/TokenService';
import { AppStore } from '../store/AppStore';
import { HttpClient } from '../service/HttpClient';
import { AgreementService } from '../service/AgreementService';
import { PreferencesService } from '../service/PreferencesService';
import { ThemeColors } from '../constants/ThemeColors';
import { promptAction } from '@kit.ArkUI';

/**
 * 启动页（T4.1/T4.2：隐私协议弹窗 + Token 校验 → 主页/登录页分流）。
 * 流程：
 *  1. 首次启动展示隐私政策+用户协议弹窗（未同意不初始化网络，任务书 8）
 *  2. 同意后读取本地登录态
 *  3. 有 Token → /auth/profile 校验（2001 自动刷新、2002 清态跳登录）
 *  4. 校验通过 → 主容器；无 Token → 登录页
 */
@Component
export struct SplashPage {
  @State title: string = '知考';
  @State showAgreementDialog: boolean = false;

  aboutToAppear(): void {
    this.initFlow();
  }

  /** 启动流程：先协议弹窗（首次），再 Token 校验 */
  async initFlow(): Promise<void> {
    await this.delay(400);
    // 等待本地存储初始化完成（T1.6 修复：避免与 EntryAbility 异步 init 竞态）
    try {
      await PreferencesService.getInstance().whenReady();
    } catch (e) {
      // 存储未初始化时按未同意协议处理，走弹窗流程
    }
    const agreed = await AgreementService.hasAgreed();
    if (!agreed) {
      // 首次启动：展示协议弹窗，未同意不继续（不初始化网络）
      this.showAgreementDialog = true;
      return;
    }
    this.checkTokenAndRoute();
  }

  /** 用户同意协议：记录同意，继续 Token 校验 */
  async onAgree(): Promise<void> {
    await AgreementService.setAgreed();
    this.showAgreementDialog = false;
    this.checkTokenAndRoute();
  }

  /** 用户拒绝协议：退出提示（正式版引导退出应用） */
  onDisagree(): void {
    this.showAgreementDialog = false;
    promptAction.showToast({ message: '需同意协议后才能使用本应用', duration: 2000 });
  }

  /** Token 校验与路由分发 */
  async checkTokenAndRoute(): Promise<void> {
    const loggedIn = await TokenService.isLoggedIn();
    if (!loggedIn) {
      NavigationService.setLoggedIn(false);
      NavigationService.resetToLogin();
      return;
    }

    // 有 Token：调 profile 校验有效性（2001 自动刷新，2002 内部已清态跳登录）
    const response = await HttpClient.get<Object>('/auth/profile');
    if (response.code === 0) {
      const userId = await TokenService.getUserId();
      const username = await TokenService.getUsername();
      const nickname = await TokenService.getNickname();
      const userType = await TokenService.getUserType();
      AppStore.setLogin(userId, username, nickname, userType);
      NavigationService.setLoggedIn(true);
      NavigationService.resetToMain();
    } else {
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

  @Builder
  AgreementDialog() {
    Column() {
      Text('用户协议与隐私政策')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 12 })

      Text('欢迎使用知考！在使用前，请仔细阅读《用户协议》与《隐私政策》。\n' +
        '我们将仅收集为提供学习服务所必需的信息，并承诺不向第三方出售您的个人数据。')
        .fontSize(14)
        .lineHeight(22)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .padding({ left: 20, right: 20 })

      Row() {
        Text('《用户协议》')
          .fontSize(14)
          .fontColor(ThemeColors.PRIMARY)
          .onClick(() => {
            NavigationService.push(RouteConstants.AGREEMENT);
          })
        Text(' 与 ')
          .fontSize(14)
          .fontColor(ThemeColors.TEXT_TERTIARY)
        Text('《隐私政策》')
          .fontSize(14)
          .fontColor(ThemeColors.PRIMARY)
          .onClick(() => {
            NavigationService.push(RouteConstants.AGREEMENT);
          })
      }
      .margin({ top: 12, bottom: 16 })

      Row() {
        Button('拒绝')
          .layoutWeight(1)
          .height(44)
          .backgroundColor(Color.White)
          .fontColor(ThemeColors.TEXT_SECONDARY)
          .onClick(() => {
            this.onDisagree();
          })
        Button('同意并继续')
          .layoutWeight(1)
          .height(44)
          .margin({ left: 12 })
          .backgroundColor(ThemeColors.PRIMARY)
          .onClick(() => {
            this.onAgree();
          })
      }
      .padding({ left: 20, right: 20, bottom: 20 })
    }
    .width('88%')
    .borderRadius(16)
    .backgroundColor(Color.White)
  }

  build() {
    NavDestination() {
      Stack() {
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

        if (this.showAgreementDialog) {
          Column() {
            this.AgreementDialog()
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#66000000')
        }
      }
      .width('100%')
      .height('100%')
    }
    .title('知考')
    .hideTitleBar(true)
  }
}

/** 系统路由表入口（T1.3 路由基建修复：Navigation 字符串路由需 buildFunction 导出） */
@Builder
export function SplashPageBuilder() {
  SplashPage()
}
