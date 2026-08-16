import { ReviewRepository, ReviewItem } from '../repository/ReviewRepository';
import { NavigationService } from '../service/NavigationService';
import { RouteConstants } from '../constants/RouteConstants';
import { ThemeColors } from '../constants/ThemeColors';
import { LoadingView } from '../components/LoadingView';
import { ErrorView } from '../components/ErrorView';

/**
 * 复习过程页（T7.4）：回忆式复习（先看题→自答→揭示结果→提交）。
 */
@Entry
@Component
struct ReviewSessionPage {
  @State items: ReviewItem[] = [];
  @State currentIndex: number = 0;
  @State revealed: boolean = false;
  @State loading: boolean = true;
  @State loadError: boolean = false;
  @State submitting: boolean = false;

  aboutToAppear(): void {
    this.load();
  }

  async load(): Promise<void> {
    this.loading = true;
    this.loadError = false;
    const response = await ReviewRepository.createSession();
    if (response.code === 0 && response.data !== null) {
      this.items = response.data;
    } else {
      this.loadError = true;
    }
    this.loading = false;
  }

  /** 揭示答案（回忆式复习第二步） */
  reveal(): void {
    this.revealed = true;
  }

  /** 提交结果并进入下一项 */
  async submitAndNext(isCorrect: boolean): Promise<void> {
    if (this.submitting) {
      return;
    }
    this.submitting = true;
    const item = this.items[this.currentIndex];
    await ReviewRepository.submitItem(item.targetType, item.targetId, isCorrect);
    this.submitting = false;

    this.revealed = false;
    if (this.currentIndex < this.items.length - 1) {
      this.currentIndex++;
    } else {
      // 复习完成
      NavigationService.back();
    }
  }

  build() {
    Column() {
      if (this.loading) {
        LoadingView()
      } else if (this.loadError) {
        ErrorView({ onRetry: () => this.load() })
      } else if (this.items.length === 0) {
        Text('今日无需复习')
          .fontSize(16)
          .fontColor(ThemeColors.TEXT_SECONDARY)
          .margin({ top: 80 })
      } else {
        Column() {
          // 进度
          Text(`第 ${this.currentIndex + 1}/${this.items.length} 项`)
            .fontSize(14)
            .fontColor(ThemeColors.TEXT_SECONDARY)
            .width('100%')
            .padding({ left: 16, right: 16 })
          Progress({ value: this.currentIndex + 1, total: this.items.length })
            .width('100%')
            .height(4)
            .color(ThemeColors.PRIMARY)
            .margin({ top: 8 })

          Scroll() {
            Column() {
              // 标题（回忆式：先展示标题/词，用户自答后揭示内容）
              Text(this.items[this.currentIndex].title)
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(ThemeColors.PRIMARY)
                .width('100%')
                .padding({ left: 16, right: 16, top: 24 })

              Text('回忆：默背这个知识点/成语的要点')
                .fontSize(13)
                .fontColor(ThemeColors.TEXT_TERTIARY)
                .width('100%')
                .padding({ left: 16, right: 16, top: 8 })

              if (this.revealed) {
                Column() {
                  Text(this.items[this.currentIndex].content)
                    .fontSize(16)
                    .lineHeight(24)
                    .fontColor(ThemeColors.TEXT_PRIMARY)
                    .width('100%')
                  if (this.items[this.currentIndex].reviewStage > 0) {
                    Text(`当前复习阶段：${this.items[this.currentIndex].reviewStage}`)
                      .fontSize(12)
                      .fontColor(ThemeColors.TEXT_TERTIARY)
                      .width('100%')
                      .margin({ top: 12 })
                  }
                }
                .width('100%')
                .padding(16)
                .margin({ left: 16, right: 16, top: 16 })
                .borderRadius(10)
                .backgroundColor('#E8F0FE')
              }
            }
            .width('100%')
          }
          .layoutWeight(1)

          // 底部操作
          if (!this.revealed) {
            Button('查看答案')
              .width('88%')
              .height(46)
              .margin({ top: 8, bottom: 16 })
              .backgroundColor(ThemeColors.PRIMARY)
              .onClick(() => {
                this.reveal();
              })
          } else {
            Row() {
              Button('没记住')
                .layoutWeight(1)
                .height(46)
                .backgroundColor(ThemeColors.DANGER)
                .enabled(!this.submitting)
                .onClick(() => {
                  this.submitAndNext(false);
                })
              Button('记住了')
                .layoutWeight(1)
                .height(46)
                .margin({ left: 12 })
                .backgroundColor(ThemeColors.SUCCESS)
                .enabled(!this.submitting)
                .onClick(() => {
                  this.submitAndNext(true);
                })
            }
            .width('88%')
            .padding({ top: 8, bottom: 16 })
          }
        }
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.BACKGROUND)
  }
}
