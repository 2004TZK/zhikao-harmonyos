import { RouteConstants } from '../constants/RouteConstants';
import { NavigationService } from '../service/NavigationService';

/**
 * 练习入口（T1.4 占位版，完整内容 T6.2 实现）。
 * 每日挑战 / 专项训练 / 随机训练。
 */
@Component
export struct PracticePage {
  build() {
    Column() {
      Text('练习')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 40 })
      Text('每日挑战 / 专项训练 / 随机训练（T6.2 完成）')
        .fontSize(13)
        .fontColor('#999999')
        .margin({ top: 12 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}
