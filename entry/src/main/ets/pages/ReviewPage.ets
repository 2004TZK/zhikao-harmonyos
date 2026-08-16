import { ReviewRepository, ReviewTodayData } from '../repository/ReviewRepository';
import { NavigationService } from '../service/NavigationService';
import { RouteConstants } from '../constants/RouteConstants';
import { ThemeColors } from '../constants/ThemeColors';
import { LoadingView } from '../components/LoadingView';
import { ErrorView } from '../components/ErrorView';
import { EmptyView } from '../components/EmptyView';

/**
 * 复习入口页（T7.3）：待复习总数/建议复习数/积压提示/三组分组。
 */
@Component
export struct ReviewPage {
  @State data: ReviewTodayData = new ReviewTodayData();
  @State loading: boolean = true;
  @State loadError: boolean = false;

  aboutToAppear(): void {
    this.load();
  }

  async load(): Promise<void> {
    this.loading = true;
    this.loadError = false;
    const response = await ReviewRepository.today();
    if (response.code === 0 && response.data !== null) {
      this.data = response.data;
    } else {
      this.loadError = true;
    }
    this.loading = false;
  }

  startReview(): void {
    NavigationService.push(RouteConstants.REVIEW_SESSION);
  }

  build() {
      Column() {
        Text('复习')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .padding({ left: 16, top: 12 })
  
        if (this.loading) {
          LoadingView()
        } else if (this.loadError) {
          ErrorView({ onRetry: () => this.load() })
        } else if (this.data.pendingTotal === 0) {
          EmptyView({ emptyText: '今日无待复习内容' })
        } else {
          Scroll() {
            Column() {
              // 待复习总数卡片
              Column() {
                Text(String(this.data.pendingTotal))
                  .fontSize(44)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(ThemeColors.PRIMARY)
                Text('个待复习知识点/成语')
                  .fontSize(14)
                  .fontColor(ThemeColors.TEXT_SECONDARY)
                  .margin({ top: 4 })
              }
              .width('100%')
              .padding(20)
              .margin({ left: 16, right: 16, top: 16 })
              .borderRadius(12)
              .backgroundColor('#E8F0FE')
  
              // 建议复习提示（7.3：建议 X 个，还有 Y 个待复习）
              Column() {
                Row() {
                  Text(`建议复习 ${this.data.suggestedCount} 个`)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(ThemeColors.WARNING)
                  Text(`，还有 ${this.data.pendingTotal} 个待复习`)
                    .fontSize(14)
                    .fontColor(ThemeColors.TEXT_TERTIARY)
                    .margin({ left: 8 })
                }
                .width('100%')
                Text('每天完成建议量即可，积压会逐步消化')
                  .fontSize(12)
                  .fontColor(ThemeColors.TEXT_TERTIARY)
                  .width('100%')
                  .margin({ top: 6 })
              }
              .width('100%')
              .padding(14)
              .margin({ left: 16, right: 16, top: 12 })
              .borderRadius(10)
              .backgroundColor('#FEF7E0')
  
              // 分组卡片
              Column() {
                this.GroupRow('即将遗忘', this.data.groups.forgetting, ThemeColors.DANGER)
                this.GroupRow('普通复习', this.data.groups.normal, ThemeColors.PRIMARY)
                this.GroupRow('错题强化', this.data.groups.wrongReinforce, ThemeColors.WARNING)
              }
              .width('100%')
              .padding(14)
              .margin({ left: 16, right: 16, top: 12 })
              .borderRadius(10)
              .backgroundColor(ThemeColors.CARD_BACKGROUND)
  
              // 开始复习按钮
              Button('开始复习')
                .width('88%')
                .height(48)
                .margin({ top: 24, bottom: 20 })
                .backgroundColor(ThemeColors.PRIMARY)
                .onClick(() => {
                  this.startReview();
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

  @Builder
  GroupRow(name: string, count: number, color: string) {
    Row() {
      Text(name)
        .fontSize(14)
      Text(String(count))
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
        .margin({ left: 8 })
      Blank()
    }
    .width('100%')
    .padding({ top: 6, bottom: 6 })
  }
}

/** 系统路由表入口 */
@Builder
export function ReviewPageBuilder() {
  ReviewPage()
}
