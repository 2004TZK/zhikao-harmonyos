import { ThemeColors } from '../constants/ThemeColors';

/**
 * 空态组件（T1.8）。
 * 列表/页面无数据时展示。
 */
@Component
export struct EmptyView {
  /** 空态提示文案 */
  @Prop emptyText: string = '暂无数据';

  build() {
    Column() {
      Text('📭')
        .fontSize(48)
      Text(this.emptyText)
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
