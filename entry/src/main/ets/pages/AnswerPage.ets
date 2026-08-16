import { PracticeRepository, PracticeQuestion, PracticeOption, AnswerResultData, PracticeSessionData } from '../repository/PracticeRepository';
import { RouterManager } from '../service/RouterManager';
import { NavigationService } from '../service/NavigationService';
import { RouteConstants } from '../constants/RouteConstants';
import { RouteParamObject } from '../types/RouteParamObject';
import { ThemeColors } from '../constants/ThemeColors';
import { LoadingView } from '../components/LoadingView';
import { ErrorView } from '../components/ErrorView';
import { ApiResponse } from '../constants/HttpConstants';

/**
 * 答题页（T6.3）：题号进度/选项单选/提交/即时判分/解析/关联知识点跳转。
 * 支持 mode：1 每日挑战 2 专项 3 随机 5 错题重练。
 */
@Component
export struct AnswerPage {
  @State mode: number = 1;
  @State sessionId: number = 0;
  @State questions: PracticeQuestion[] = [];
  @State currentIndex: number = 0;
  @State selectedOptionId: number = 0;
  @State submitted: boolean = false;
  @State result: AnswerResultData = new AnswerResultData();
  @State loading: boolean = true;
  @State loadError: boolean = false;
  @State correctCount: number = 0;
  @State answerCount: number = 0;

  aboutToAppear(): void {
    // 参数在 NavDestination onReady 中获取（系统路由表下 aboutToAppear 时参数未注入）
    const param = RouterManager.getInstance().getParamByName(RouteConstants.ANSWER) as RouteParamObject;
    if (param !== undefined && param !== null && param.targetType > 0) {
      this.mode = param.targetType;
    }
  }

  async createAndLoad(): Promise<void> {
    this.loading = true;
    this.loadError = false;
    let response: ApiResponse<PracticeSessionData> = new ApiResponse<PracticeSessionData>();
    if (this.mode === 5) {
      // 错题重练
      response = await PracticeRepository.wrongPractice(10);
    } else {
      response = await PracticeRepository.createSession(this.mode, 0, 0, 10);
    }
    if (response.code === 0 && response.data !== null) {
      this.sessionId = response.data.sessionId;
      this.questions = response.data.questions;
    } else {
      this.loadError = true;
    }
    this.loading = false;
  }

  selectOption(optionId: number): void {
    if (this.submitted) {
      return;
    }
    this.selectedOptionId = optionId;
  }

  async submit(): Promise<void> {
    if (this.selectedOptionId === 0 || this.submitted) {
      return;
    }
    const question = this.questions[this.currentIndex];
    const response = await PracticeRepository.submitAnswer(this.sessionId, question.questionId, this.selectedOptionId);
    if (response.code === 0 && response.data !== null) {
      this.result = response.data;
      this.submitted = true;
      if (response.data.correct) {
        this.correctCount++;
      }
      this.answerCount++;
    }
  }

  nextQuestion(): void {
    this.submitted = false;
    this.selectedOptionId = 0;
    if (this.currentIndex < this.questions.length - 1) {
      this.currentIndex++;
    } else {
      // 答题完成 → 结果页
      const param = new RouteParamObject();
      param.sessionId = this.sessionId;
      NavigationService.push(RouteConstants.ANSWER_RESULT, param);
    }
  }

  jumpToRelated(): void {
    const question = this.questions[this.currentIndex];
    const param = new RouteParamObject();
    if (question.knowledgeId > 0) {
      param.knowledgeId = question.knowledgeId;
      NavigationService.push(RouteConstants.KNOWLEDGE_DETAIL, param);
    } else if (question.idiomId > 0) {
      param.idiomId = question.idiomId;
      NavigationService.push(RouteConstants.IDIOM_DETAIL, param);
    }
  }

  build() {
  NavDestination() {
      Column() {
        if (this.loading) {
          LoadingView()
        } else if (this.loadError) {
          ErrorView({ onRetry: () => this.createAndLoad() })
        } else if (this.questions.length > 0) {
          Column() {
            // 进度
            Text(`第 ${this.currentIndex + 1}/${this.questions.length} 题`)
              .fontSize(14)
              .fontColor(ThemeColors.TEXT_SECONDARY)
              .width('100%')
              .padding({ left: 16, right: 16 })
            Progress({ value: this.currentIndex + 1, total: this.questions.length })
              .width('100%')
              .height(4)
              .color(ThemeColors.PRIMARY)
              .margin({ top: 8 })
  
            // 题干
            Scroll() {
              Column() {
                Text(this.questions[this.currentIndex].content)
                  .fontSize(17)
                  .lineHeight(26)
                  .fontColor(ThemeColors.TEXT_PRIMARY)
                  .width('100%')
                  .padding({ left: 16, right: 16, top: 16 })
  
                // 选项
                ForEach(this.questions[this.currentIndex].options, (option: PracticeOption) => {
                  Row() {
                    Text(option.label)
                      .fontSize(15)
                      .fontWeight(FontWeight.Bold)
                      .width(28)
                      .height(28)
                      .textAlign(TextAlign.Center)
                      .borderRadius(14)
                      .backgroundColor(this.selectedOptionId === option.optionId ? ThemeColors.PRIMARY : ThemeColors.CARD_BACKGROUND)
                      .fontColor(this.selectedOptionId === option.optionId ? Color.White : ThemeColors.TEXT_SECONDARY)
                    Text(option.content)
                      .fontSize(15)
                      .fontColor(ThemeColors.TEXT_PRIMARY)
                      .margin({ left: 12 })
                      .layoutWeight(1)
                  }
                  .width('90%')
                  .padding(12)
                  .margin({ top: 12 })
                  .borderRadius(10)
                  .backgroundColor(this.selectedOptionId === option.optionId ? '#E8F0FE' : Color.White)
                  .border({ width: 1, color: this.selectedOptionId === option.optionId ? ThemeColors.PRIMARY : ThemeColors.DIVIDER })
                  .onClick(() => {
                    this.selectOption(option.optionId);
                  })
                }, (option: PracticeOption) => option.optionId.toString())
  
                // 判分结果区
                if (this.submitted) {
                  Column() {
                    Row() {
                      Text(this.result.correct ? '✓ 回答正确' : `✗ 回答错误，正确答案 ${this.result.correctOptionLabel}`)
                        .fontSize(15)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(this.result.correct ? ThemeColors.SUCCESS : ThemeColors.DANGER)
                    }
                    .width('100%')
  
                    Text('解析：' + this.result.analysis)
                      .fontSize(14)
                      .lineHeight(22)
                      .fontColor(ThemeColors.TEXT_SECONDARY)
                      .width('100%')
                      .margin({ top: 8 })
  
                    if (this.result.knowledgeId > 0 || this.result.idiomId > 0) {
                      Text(this.result.knowledgeId > 0 ? '查看关联知识点 >' : '查看关联成语 >')
                        .fontSize(13)
                        .fontColor(ThemeColors.PRIMARY)
                        .width('100%')
                        .margin({ top: 8 })
                        .onClick(() => {
                          this.jumpToRelated();
                        })
                    }
                  }
                  .width('100%')
                  .padding(14)
                  .margin({ left: 16, right: 16, top: 16 })
                  .borderRadius(10)
                  .backgroundColor(this.result.correct ? '#E6F4EA' : '#FDECEA')
                  .transition(TransitionEffect.OPACITY.animation({ duration: 200, curve: Curve.EaseOut }))
                }
              }
              .width('100%')
            }
            .layoutWeight(1)
  
            // 底部按钮
            Row() {
              if (!this.submitted) {
                Button('提交答案')
                  .width('88%')
                  .height(46)
                  .backgroundColor(ThemeColors.PRIMARY)
                  .enabled(this.selectedOptionId !== 0)
                  .onClick(() => {
                    this.submit();
                  })
              } else {
                Button(this.currentIndex < this.questions.length - 1 ? '下一题' : '查看结果')
                  .width('88%')
                  .height(46)
                  .backgroundColor(ThemeColors.SUCCESS)
                  .onClick(() => {
                    this.nextQuestion();
                  })
              }
            }
            .width('100%')
            .padding({ top: 8, bottom: 16 })
            .justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .height('100%')
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(ThemeColors.BACKGROUND)
    }
    .onReady((context: NavDestinationContext) => {
      // 系统路由表模式下：优先用 onReady 的 context.pathInfo.param 取参数（官方推荐）
      const pathParam = context.pathInfo.param as RouteParamObject;
      if (pathParam !== undefined && pathParam !== null && pathParam.targetType > 0) {
        this.mode = pathParam.targetType;
      } else {
        const param = RouterManager.getInstance().getParamByName(RouteConstants.ANSWER) as RouteParamObject;
        if (param !== undefined && param !== null && param.targetType > 0) {
          this.mode = param.targetType;
        }
      }
      this.createAndLoad();
    })
  }
}

/** 系统路由表入口 */
@Builder
export function AnswerPageBuilder() {
  AnswerPage()
}
