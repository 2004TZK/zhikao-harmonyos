import { RouteConstants } from '../constants/RouteConstants';
import { NavigationService } from '../service/NavigationService';

/**
 * 我的（T1.4 占位版，完整内容 T8.3 实现）。
 */
@Component
export struct MinePage {
  build() {
    Column() {
      Text('我的')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 40 })
      Text('个人信息 / 统计摘要 / 设置入口（T8.3 完成）')
        .fontSize(13)
        .fontColor('#999999')
        .margin({ top: 12 })

      Button('设置')
        .width(120)
        .margin({ top: 40 })
        .onClick(() => {
          NavigationService.push(RouteConstants.SETTINGS);
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}
