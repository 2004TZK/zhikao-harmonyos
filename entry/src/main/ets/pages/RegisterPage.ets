import { NavigationService } from '../service/NavigationService';

/**
 * 注册页（T1.3 占位版，完整表单校验与后端对接 T4.2 实现）。
 */
@Entry
@Component
struct RegisterPage {
  @State username: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';

  /** 模拟注册（T1.3 占位；T4.2 改为调用 /auth/register） */
  doRegister(): void {
    // mock：注册成功后回到登录页
    NavigationService.back();
  }

  build() {
    Column() {
      Text('注册')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A73E8')
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
        .margin({ bottom: 32 })
        .type(InputType.Password)
        .onChange((value: string) => {
          this.confirmPassword = value;
        })

      Button('注册')
        .width('80%')
        .height(48)
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
