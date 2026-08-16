import { NavigationService } from '../service/NavigationService';
import { HttpClient } from '../service/HttpClient';
import { TokenService } from '../service/TokenService';
import { AppStore } from '../store/AppStore';
import { ThemeColors } from '../constants/ThemeColors';
import { LoginResponseData } from './LoginPage';

/**
 * 注册页（T4.2：对接 /auth/register）。
 * 成功：自动登录（保存 Token）→ 回登录流程进主页。
 */
@Entry
@Component
struct RegisterPage {
  @State username: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State loading: boolean = false;
  @State errorMsg: string = '';

  async doRegister(): Promise<void> {
    // 表单校验
    if (!/^[a-zA-Z0-9_]{3,20}$/.test(this.username)) {
      this.errorMsg = '用户名需为 3~20 位字母/数字/下划线';
      return;
    }
    if (this.password.length < 6 || this.password.length > 32) {
      this.errorMsg = '密码长度需在 6~32 位之间';
      return;
    }
    if (this.password !== this.confirmPassword) {
      this.errorMsg = '两次输入的密码不一致';
      return;
    }
    this.loading = true;
    this.errorMsg = '';

    const body = new RegisterRequestBody();
    body.username = this.username.trim();
    body.password = this.password;

    const response = await HttpClient.post<LoginResponseData>('/auth/register', body);
    if (response.code === 0 && response.data !== null) {
      const data = response.data;
      await TokenService.saveTokens(data.accessToken, data.refreshToken);
      await TokenService.saveUserInfo(data.userId, data.username, data.nickname, data.userType);
      AppStore.setLogin(data.userId, data.username, data.nickname, data.userType);
      NavigationService.setLoggedIn(true);
      // 注册即登录：清空栈进主容器
      NavigationService.resetToMain();
    } else {
      this.errorMsg = response.message;
    }
    this.loading = false;
  }

  build() {
    Column() {
      Text('注册')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.PRIMARY)
        .margin({ top: 60, bottom: 32 })

      TextInput({ placeholder: '用户名（3~20 位字母/数字/下划线）', text: this.username })
        .width('80%')
        .height(48)
        .margin({ bottom: 16 })
        .onChange((value: string) => {
          this.username = value;
        })

      TextInput({ placeholder: '密码（6~32 位）', text: this.password })
        .width('80%')
        .height(48)
        .margin({ bottom: 16 })
        .type(InputType.Password)
        .onChange((value: string) => {
          this.password = value;
        })

      TextInput({ placeholder: '确认密码', text: this.confirmPassword })
        .width('80%')
        .height(48)
        .margin({ bottom: 8 })
        .type(InputType.Password)
        .onChange((value: string) => {
          this.confirmPassword = value;
        })

      if (this.errorMsg !== '') {
        Text(this.errorMsg)
          .fontSize(13)
          .fontColor(ThemeColors.DANGER)
          .margin({ top: 4, bottom: 4 })
      }

      Button(this.loading ? '注册中...' : '注册')
        .width('80%')
        .height(48)
        .margin({ top: 16 })
        .enabled(!this.loading)
        .onClick(() => {
          this.doRegister();
        })
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(Color.White)
  }
}

/** 注册请求（契约 6.2 POST /auth/register） */
export class RegisterRequestBody {
  username: string = '';
  password: string = '';
  nickname: string = '';
}
