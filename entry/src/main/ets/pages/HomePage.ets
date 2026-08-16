import { RouteConstants } from '../constants/RouteConstants';
import { NavigationService } from '../service/NavigationService';

/**
 * 首页（T1.4 占位版，完整内容 T4.5 实现）。
 */
@Component
export struct HomePage {
  build() {
    Column() {
      Text('首页')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 40 })
      Text('今日任务 / 连续天数 / 推荐内容（T4.5 完成）')
        .fontSize(13)
        .fontColor('#999999')
        .margin({ top: 12 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}
