import { ThemeColors } from '../constants/ThemeColors';

/**
 * 错误态组件（T1.8）：含重试按钮。
 * 页面请求失败时展示，点击重试重新触发加载。
 */
@Component
export struct ErrorView {
  /** 错误提示文案 */
  @Prop errorText: string = '加载失败，请稍后重试';
  /** 重试回调（由父页面注入） */
  onRetry: () => void = () => {
  };

  build() {
    Column() {
      Text('⚠️')
        .fontSize(48)
      Text(this.errorText)
        .fontSize(14)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .margin({ top: 12 })
      Button('重试')
        .width(120)
        .height(40)
        .margin({ top: 24 })
        .backgroundColor(ThemeColors.PRIMARY)
        .onClick(() => {
          this.onRetry();
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor(ThemeColors.BACKGROUND)
  }
}
