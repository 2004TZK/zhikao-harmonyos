import { PracticeRepository, SessionResultData, WrongQuestionSummary } from '../repository/PracticeRepository';
import { RouterManager } from '../service/RouterManager';
import { NavigationService } from '../service/NavigationService';
import { RouteConstants } from '../constants/RouteConstants';
import { RouteParamObject } from '../types/RouteParamObject';
import { ThemeColors } from '../constants/ThemeColors';
import { LoadingView } from '../components/LoadingView';
import { ErrorView } from '../components/ErrorView';

/**
 * 练习结果页（T6.4）：正确率/用时/错题清单。
 */
@Component
export struct AnswerResultPage {
  @State sessionId: number = 0;
  @State loading: boolean = true;
  @State loadError: boolean = false;
  @State result: SessionResultData = new SessionResultData();

  aboutToAppear(): void {
    // 参数在 NavDestination onReady 中获取（系统路由表下 aboutToAppear 时参数未注入）
    const param = RouterManager.getInstance().getParamByName(RouteConstants.ANSWER_RESULT) as RouteParamObject;
    if (param !== undefined && param !== null) {
      this.sessionId = param.sessionId;
    }
  }

  async load(): Promise<void> {
    this.loading = true;
    this.loadError = false;
    const response = await PracticeRepository.sessionResult(this.sessionId);
    if (response.code === 0 && response.data !== null) {
      this.result = response.data;
    } else {
      this.loadError = true;
    }
    this.loading = false;
  }

  build() {
  NavDestination() {
      Column() {
        if (this.loading) {
          LoadingView()
        } else if (this.loadError) {
          ErrorView({ onRetry: () => this.load() })
        } else {
          Scroll() {
            Column() {
              // 正确率
              Column() {
                Text(`${this.result.accuracy}%`)
                  .fontSize(48)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.result.accuracy >= 60 ? ThemeColors.SUCCESS : ThemeColors.WARNING)
                Text(`答对 ${this.result.correctCount} / 共 ${this.result.totalCount} 题`)
                  .fontSize(14)
                  .fontColor(ThemeColors.TEXT_SECONDARY)
                  .margin({ top: 8 })
              }
              .width('100%')
              .padding({ top: 32, bottom: 24 })
  
              // 错题清单
              Text('错题清单')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .width('100%')
                .padding({ left: 16 })
  
              if (this.result.wrongQuestions.length === 0) {
                Text('全部答对，太棒了！')
                  .fontSize(14)
                  .fontColor(ThemeColors.SUCCESS)
                  .margin({ top: 24 })
              } else {
                ForEach(this.result.wrongQuestions, (item: WrongQuestionSummary) => {
                  Column() {
                    Text(item.content)
                      .fontSize(14)
                      .lineHeight(22)
                      .width('100%')
                  }
                  .width('100%')
                  .padding(14)
                  .margin({ left: 16, right: 16, top: 10 })
                  .borderRadius(10)
                  .backgroundColor(ThemeColors.CARD_BACKGROUND)
                }, (item: WrongQuestionSummary) => item.questionId.toString())
              }
  
              Button('返回练习首页')
                .width('88%')
                .height(46)
                .margin({ top: 24, bottom: 20 })
                .backgroundColor(ThemeColors.PRIMARY)
                .onClick(() => {
                  NavigationService.back();
                })
            }
            .width('100%')
          }
          .layoutWeight(1)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(ThemeColors.BACKGROUND)
    }
    .onReady((context: NavDestinationContext) => {
      // 系统路由表模式下：优先用 onReady 的 context.pathInfo.param 取参数（官方推荐）
      const pathParam = context.pathInfo.param as RouteParamObject;
      if (pathParam !== undefined && pathParam !== null && pathParam.sessionId > 0) {
        this.sessionId = pathParam.sessionId;
      } else {
        const param = RouterManager.getInstance().getParamByName(RouteConstants.ANSWER_RESULT) as RouteParamObject;
        if (param !== undefined && param !== null && param.sessionId > 0) {
          this.sessionId = param.sessionId;
        }
      }
      this.load();
    })
  }
}

/** 系统路由表入口 */
@Builder
export function AnswerResultPageBuilder() {
  AnswerResultPage()
}
