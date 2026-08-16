import { NavigationService } from '../service/NavigationService';
import { RouteConstants } from '../constants/RouteConstants';

/**
 * 登录页（T1.3 占位版，完整表单校验与后端对接 T4.2 实现）。
 * 演示：登录成功后回跳受保护目标页（pushAuth 链路）。
 */
@Entry
@Component
struct LoginPage {
  @State username: string = '';
  @State password: string = '';
  @State loading: boolean = false;

  /** 模拟登录（T1.3：本地置为已登录；T4.2 改为调用 /auth/login） */
  doLogin(): void {
    this.loading = true;
    setTimeout(() => {
      NavigationService.setLoggedIn(true);
      this.loading = false;
      // 返回上一页（Splash/受保护页面），由 onPop 回调继续跳转
      NavigationService.back();
    }, 300);
  }

  build() {
    Column() {
      Text('知考')
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A73E8')
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
        .margin({ bottom: 32 })
        .type(InputType.Password)
        .onChange((value: string) => {
          this.password = value;
        })

      Button(this.loading ? '登录中...' : '登录')
        .width('80%')
        .height(48)
        .enabled(!this.loading)
        .onClick(() => {
          this.doLogin();
        })

      Row() {
        Text('没有账号？')
          .fontSize(14)
          .fontColor('#666666')
        Text('去注册')
          .fontSize(14)
          .fontColor('#1A73E8')
          .onClick(() => {
            NavigationService.push(RouteConstants.REGISTER);
          })
      }
      .margin({ top: 24 })
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(Color.White)
  }
}
