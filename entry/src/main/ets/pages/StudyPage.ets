import { RouteConstants } from '../constants/RouteConstants';
import { NavigationService } from '../service/NavigationService';

/**
 * 学习入口（T1.4 占位版，完整内容 T5 实现）。
 * 常识 / 成语双入口。
 */
@Component
export struct StudyPage {
  build() {
    Column() {
      Text('学习')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 40 })
      Text('常识 / 成语学习入口（T5 完成）')
        .fontSize(13)
        .fontColor('#999999')
        .margin({ top: 12 })

      Row() {
        Button('常识')
          .width(120)
          .onClick(() => {
            NavigationService.push(RouteConstants.KNOWLEDGE_CATEGORY);
          })
        Button('成语')
          .width(120)
          .margin({ left: 16 })
          .onClick(() => {
            NavigationService.push(RouteConstants.IDIOM_CATEGORY);
          })
      }
      .margin({ top: 40 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}
