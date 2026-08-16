import { NavigationService } from '../service/NavigationService';
import { RouteConstants } from '../constants/RouteConstants';
import { RouteParamObject } from '../types/RouteParamObject';
import { ThemeColors } from '../constants/ThemeColors';

/**
 * 练习入口页（T6.2）：每日挑战/专项训练/随机训练。
 */
@Component
export struct PracticePage {
  @State currentTab: number = 0;

  startPractice(mode: number): void {
    const param = new RouteParamObject();
    param.targetType = mode;
    NavigationService.push(RouteConstants.ANSWER, param);
  }

  build() {
      Column() {
        Text('练习')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .padding({ left: 16, top: 12 })
  
        // 每日挑战卡
        Column() {
          Row() {
            Text('每日挑战')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(ThemeColors.PRIMARY)
            Blank()
            Text('每天 10 题，保持手感 >')
              .fontSize(13)
              .fontColor(ThemeColors.TEXT_TERTIARY)
          }
          .width('100%')
          Text('混合知识点与成语，检验当日学习效果')
            .fontSize(13)
            .fontColor(ThemeColors.TEXT_SECONDARY)
            .width('100%')
            .margin({ top: 8 })
        }
        .width('100%')
        .padding(16)
        .margin({ left: 16, right: 16, top: 16 })
        .borderRadius(12)
        .backgroundColor('#E8F0FE')
        .onClick(() => {
          this.startPractice(1);
        })
  
        // 专项训练卡
        Column() {
          Row() {
            Text('专项训练')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(ThemeColors.SUCCESS)
            Blank()
            Text('按知识点/成语巩固 >')
              .fontSize(13)
              .fontColor(ThemeColors.TEXT_TERTIARY)
          }
          .width('100%')
          Text('针对薄弱知识点集中练习')
            .fontSize(13)
            .fontColor(ThemeColors.TEXT_SECONDARY)
            .width('100%')
            .margin({ top: 8 })
        }
        .width('100%')
        .padding(16)
        .margin({ left: 16, right: 16, top: 12 })
        .borderRadius(12)
        .backgroundColor('#E6F4EA')
        .onClick(() => {
          this.startPractice(2);
        })
  
        // 随机训练卡
        Column() {
          Row() {
            Text('随机训练')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(ThemeColors.WARNING)
            Blank()
            Text('随机 10 题热身 >')
              .fontSize(13)
              .fontColor(ThemeColors.TEXT_TERTIARY)
          }
          .width('100%')
          Text('随机抽取已上架题目')
            .fontSize(13)
            .fontColor(ThemeColors.TEXT_SECONDARY)
            .width('100%')
            .margin({ top: 8 })
        }
        .width('100%')
        .padding(16)
        .margin({ left: 16, right: 16, top: 12 })
        .borderRadius(12)
        .backgroundColor('#FEF7E0')
        .onClick(() => {
          this.startPractice(3);
        })
  
        // 错题重练入口
        Column() {
          Row() {
            Text('错题重练')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(ThemeColors.DANGER)
            Blank()
            Text('针对错题强化 >')
              .fontSize(13)
              .fontColor(ThemeColors.TEXT_TERTIARY)
          }
          .width('100%')
          Text('从错题本组卷重练')
            .fontSize(13)
            .fontColor(ThemeColors.TEXT_SECONDARY)
            .width('100%')
            .margin({ top: 8 })
        }
        .width('100%')
        .padding(16)
        .margin({ left: 16, right: 16, top: 12 })
        .borderRadius(12)
        .backgroundColor('#FDECEA')
        .onClick(() => {
          this.startPractice(5);
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(ThemeColors.BACKGROUND)
  }
}

/** 系统路由表入口 */
@Builder
export function PracticePageBuilder() {
  PracticePage()
}
