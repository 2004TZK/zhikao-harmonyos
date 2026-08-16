import { NavigationService } from '../service/NavigationService';
import { RouteConstants } from '../constants/RouteConstants';
import { HttpClient } from '../service/HttpClient';
import { TokenService } from '../service/TokenService';
import { AppStore } from '../store/AppStore';
import { ThemeColors } from '../constants/ThemeColors';
import { GuestClientService } from '../service/GuestClientService';

/**
 * 登录页（T4.2：对接 /auth/login）。
 * 成功：保存双 Token 与用户信息 → 标记登录态 → 返回（onPop 触发 pushAuth 继续跳转）。
 */
@Entry
@Component
struct LoginPage {
  @State username: string = '';
  @State password: string = '';
  @State loading: boolean = false;
  @State errorMsg: string = '';

  async doLogin(): Promise<void> {
    if (this.username.trim() === '' || this.password === '') {
      this.errorMsg = '请输入用户名和密码';
      return;
    }
    this.loading = true;
    this.errorMsg = '';

    const body = new LoginRequestBody();
    body.username = this.username.trim();
    body.password = this.password;

    const response = await HttpClient.post<LoginResponseData>('/auth/login', body);
    if (response.code === 0 && response.data !== null) {
      const data = response.data;
      // 保存 Token 与用户信息
      await TokenService.saveTokens(data.accessToken, data.refreshToken);
      await TokenService.saveUserInfo(data.userId, data.username, data.nickname, data.userType);
      // 全局 store
      AppStore.setLogin(data.userId, data.username, data.nickname, data.userType);
      NavigationService.setLoggedIn(true);
      // 返回上一页（由 pushAuth 的 onPop 回调继续跳转目标页）
      NavigationService.back();
    } else {
      this.errorMsg = response.message;
    }
    this.loading = false;
  }

  /** 游客体验：UUID 换 Token 进主容器（每日限额，超限 9001 引导登录） */
  async enterAsGuest(): Promise<void> {
    this.loading = true;
    this.errorMsg = '';
    const code = await GuestClientService.loginAsGuest();
    if (code === 9001) {
      this.errorMsg = '今日体验额度已用完，请登录后继续';
    }
    this.loading = false;
  }

  build() {
    Column() {
      Text('知考')
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.PRIMARY)
        .margin({ top: 80, bottom: 40 })

      TextInput({ placeholder: '用户名', text: this.username })
        .width('80%')
        .height(48)
        .margin({ bottom: 16 })
        .onChange((value: string) => {
          this.username = value;
        })

      TextInput({ placeholder: '密码', text: this.password })
        .width('80%')
        .height(48)
        .margin({ bottom: 8 })
        .type(InputType.Password)
        .onChange((value: string) => {
          this.password = value;
        })

      if (this.errorMsg !== '') {
        Text(this.errorMsg)
          .fontSize(13)
          .fontColor(ThemeColors.DANGER)
          .margin({ top: 4, bottom: 4 })
      }

      Button(this.loading ? '登录中...' : '登录')
        .width('80%')
        .height(48)
        .margin({ top: 16 })
        .enabled(!this.loading)
        .onClick(() => {
          this.doLogin();
        })

      Row() {
        Text('没有账号？')
          .fontSize(14)
          .fontColor(ThemeColors.TEXT_SECONDARY)
        Text('去注册')
          .fontSize(14)
          .fontColor(ThemeColors.PRIMARY)
          .onClick(() => {
            NavigationService.push(RouteConstants.REGISTER);
          })
      }
      .margin({ top: 24 })

      Text('游客体验（每日限 5 个详情 + 5 道题）')
        .fontSize(14)
        .fontColor(ThemeColors.TEXT_TERTIARY)
        .margin({ top: 32 })
        .onClick(() => {
          this.enterAsGuest();
        })
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(Color.White)
  }
}

/** 登录请求（契约 6.2） */
export class LoginRequestBody {
  username: string = '';
  password: string = '';
}

/** 登录响应 data（契约 6.2） */
export class LoginResponseData {
  accessToken: string = '';
  refreshToken: string = '';
  expiresIn: number = 0;
  userId: number = 0;
  username: string = '';
  nickname: string = '';
  userType: number = 0;
}
