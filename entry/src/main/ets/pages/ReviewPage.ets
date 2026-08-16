import { RouteConstants } from '../constants/RouteConstants';
import { NavigationService } from '../service/NavigationService';

/**
 * 复习入口（T1.4 占位版，完整内容 T7.3 实现）。
 * 待复习总数 / 建议复习数 / 分组。
 */
@Component
export struct ReviewPage {
  build() {
    Column() {
      Text('复习')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 40 })
      Text('今日复习 / 错题强化（T7.3 完成）')
        .fontSize(13)
        .fontColor('#999999')
        .margin({ top: 12 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}
