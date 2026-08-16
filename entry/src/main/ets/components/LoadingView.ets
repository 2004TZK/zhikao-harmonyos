import { ThemeColors } from '../constants/ThemeColors';

/**
 * 加载态组件（T1.8）。
 * 页面请求期间展示，避免白屏。
 */
@Component
export struct LoadingView {
  /** 提示文案 */
  @Prop loadingText: string = '加载中...';

  build() {
    Column() {
      LoadingProgress()
        .width(48)
        .height(48)
        .color(ThemeColors.PRIMARY)
      Text(this.loadingText)
        .fontSize(14)
        .fontColor(ThemeColors.TEXT_TERTIARY)
        .margin({ top: 12 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor(ThemeColors.BACKGROUND)
  }
}
