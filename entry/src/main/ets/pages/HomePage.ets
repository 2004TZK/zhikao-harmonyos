import { HttpClient } from '../service/HttpClient';
import { AppStore } from '../store/AppStore';
import { NavigationService } from '../service/NavigationService';
import { RouteConstants } from '../constants/RouteConstants';
import { ThemeColors } from '../constants/ThemeColors';
import { LoadingView } from '../components/LoadingView';
import { ErrorView } from '../components/ErrorView';
import { EmptyView } from '../components/EmptyView';
import { RouteParamObject } from '../types/RouteParamObject';

/**
 * 首页（T4.5：对接 /home/overview + /home/recommend）。
 * 展示：用户信息、连续天数、今日完成度、任务卡片（建议复习 X 个还有 Y 个）、推荐区。
 */
@Component
export struct HomePage {
  @State loading: boolean = true;
  @State loadError: boolean = false;
  @State streakDays: number = 0;
  @State todayCompleted: number = 0;
  @State todayTarget: number = 0;
  @State todayMinutes: number = 0;
  @State reviewPending: number = 0;
  @State reviewSuggested: number = 0;
  @State tasks: TaskItem[] = [];
  @State knowledgeRecs: RecItem[] = [];
  @State idiomRecs: RecItem[] = [];

  aboutToAppear(): void {
    this.loadHome();
  }

  async loadHome(): Promise<void> {
    this.loading = true;
    this.loadError = false;
    const overview = await HttpClient.get<OverviewData>('/home/overview');
    if (overview.code === 0 && overview.data !== null) {
      this.streakDays = overview.data.streakDays;
      this.todayCompleted = overview.data.todayCompleted;
      this.todayTarget = overview.data.todayTarget;
      this.todayMinutes = overview.data.todayStudyMinutes;
      this.reviewPending = overview.data.reviewPendingTotal;
      this.reviewSuggested = overview.data.reviewSuggestedCount;
      this.tasks = overview.data.tasks;
    } else {
      this.loadError = true;
    }
    // 推荐区（失败不阻塞首页主体）
    const rec = await HttpClient.get<RecommendData>('/home/recommend');
    if (rec.code === 0 && rec.data !== null) {
      this.knowledgeRecs = rec.data.knowledgeList;
      this.idiomRecs = rec.data.idiomList;
    }
    this.loading = false;
  }

  taskName(type: number): string {
    if (type === 1) {
      return '常识积累';
    }
    if (type === 2) {
      return '成语训练';
    }
    return '今日复习';
  }

  @Builder
  TaskRow(item: TaskItem) {
    Row() {
      Column() {
        Text(this.taskName(item.taskType))
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
        Text(`${item.doneCount}/${item.targetCount}`)
          .fontSize(12)
          .fontColor(ThemeColors.TEXT_TERTIARY)
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      if (item.status === 1) {
        Text('已完成')
          .fontSize(12)
          .fontColor(ThemeColors.SUCCESS)
      } else {
        Progress({ value: item.doneCount, total: item.targetCount > 0 ? item.targetCount : 1 })
          .width(90)
          .color(ThemeColors.PRIMARY)
      }
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
  }

  build() {
    Column() {
      if (this.loading) {
        LoadingView()
      } else if (this.loadError) {
        ErrorView({ onRetry: () => this.loadHome() })
      } else {
        Scroll() {
          Column() {
            // 用户信息 + 连续天数
            Row() {
              Column() {
                Text('Hi，' + AppStore.getNickname())
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                Text('坚持学习，每天进步一点')
                  .fontSize(12)
                  .fontColor(ThemeColors.TEXT_TERTIARY)
                  .margin({ top: 4 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Column() {
                Text(String(this.streakDays))
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(ThemeColors.PRIMARY)
                Text('连续天数')
                  .fontSize(11)
                  .fontColor(ThemeColors.TEXT_TERTIARY)
              }
            }
            .width('100%')
            .padding(16)

            // 今日完成度卡片
            Column() {
              Row() {
                Text('今日学习')
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                Blank()
                Text(`${this.todayMinutes} 分钟`)
                  .fontSize(13)
                  .fontColor(ThemeColors.TEXT_TERTIARY)
              }
              .width('100%')

              Row() {
                Text(String(this.todayCompleted))
                  .fontSize(32)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(ThemeColors.PRIMARY)
                Text(' / ' + String(this.todayTarget))
                  .fontSize(16)
                  .fontColor(ThemeColors.TEXT_TERTIARY)
                Blank()
                Text('今日任务完成度')
                  .fontSize(12)
                  .fontColor(ThemeColors.TEXT_TERTIARY)
              }
              .width('100%')
              .margin({ top: 8 })

              Progress({ value: this.todayCompleted, total: this.todayTarget > 0 ? this.todayTarget : 1 })
                .width('100%')
                .height(6)
                .color(ThemeColors.PRIMARY)
                .margin({ top: 8 })
            }
            .width('100%')
            .padding(16)
            .margin({ left: 16, right: 16 })
            .borderRadius(12)
            .backgroundColor(ThemeColors.CARD_BACKGROUND)

            // 今日任务卡片
            Column() {
              Text('今日任务')
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .width('100%')

              ForEach(this.tasks, (item: TaskItem) => {
                this.TaskRow(item)
              }, (item: TaskItem) => item.taskType.toString())

              // 复习积压提示（7.3：建议 X 个，还有 Y 个待复习）
              if (this.reviewSuggested > 0) {
                Row() {
                  Text(`建议复习 ${this.reviewSuggested} 个`)
                    .fontSize(12)
                    .fontColor(ThemeColors.WARNING)
                  Text(`，还有 ${this.reviewPending} 个待复习`)
                    .fontSize(12)
                    .fontColor(ThemeColors.TEXT_TERTIARY)
                }
                .width('100%')
                .margin({ top: 8 })
              }
            }
            .width('100%')
            .padding(16)
            .margin({ left: 16, right: 16, top: 12 })
            .borderRadius(12)
            .backgroundColor(ThemeColors.CARD_BACKGROUND)

            // 推荐区
            Column() {
              Text('今日推荐')
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .width('100%')
                .margin({ bottom: 8 })

              if (this.knowledgeRecs.length === 0 && this.idiomRecs.length === 0) {
                EmptyView({ emptyText: '暂无推荐内容' })
                  .height(100)
              } else {
                ForEach(this.knowledgeRecs, (item: RecItem) => {
                  Row() {
                    Text('知')
                      .fontSize(12)
                      .fontColor(Color.White)
                      .backgroundColor(ThemeColors.PRIMARY)
                      .borderRadius(4)
                      .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                    Text(item.name)
                      .fontSize(13)
                      .margin({ left: 8 })
                    Blank()
                    Text('去学习 >')
                      .fontSize(12)
                      .fontColor(ThemeColors.PRIMARY)
                  }
                  .width('100%')
                  .padding({ top: 6, bottom: 6 })
                  .onClick(() => {
                    const param = new RouteParamObject();
                    param.knowledgeId = item.id;
                    NavigationService.push(RouteConstants.KNOWLEDGE_DETAIL, param);
                  })
                }, (item: RecItem) => item.id.toString())

                ForEach(this.idiomRecs, (item: RecItem) => {
                  Row() {
                    Text('成')
                      .fontSize(12)
                      .fontColor(Color.White)
                      .backgroundColor(ThemeColors.SUCCESS)
                      .borderRadius(4)
                      .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                    Text(item.name)
                      .fontSize(13)
                      .margin({ left: 8 })
                    Blank()
                    Text('去学习 >')
                      .fontSize(12)
                      .fontColor(ThemeColors.PRIMARY)
                  }
                  .width('100%')
                  .padding({ top: 6, bottom: 6 })
                  .onClick(() => {
                    const param = new RouteParamObject();
                    param.idiomId = item.id;
                    NavigationService.push(RouteConstants.IDIOM_DETAIL, param);
                  })
                }, (item: RecItem) => item.id.toString())
              }
            }
            .width('100%')
            .padding(16)
            .margin({ left: 16, right: 16, top: 12, bottom: 16 })
            .borderRadius(12)
            .backgroundColor(ThemeColors.CARD_BACKGROUND)
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
}

/** 任务项（契约 6.13 overview.tasks） */
export class TaskItem {
  taskType: number = 0;
  taskName: string = '';
  targetCount: number = 0;
  doneCount: number = 0;
  status: number = 0;
}

/** overview 响应 data */
export class OverviewData {
  streakDays: number = 0;
  todayCompleted: number = 0;
  todayTarget: number = 0;
  todayStudyMinutes: number = 0;
  reviewPendingTotal: number = 0;
  reviewSuggestedCount: number = 0;
  tasks: TaskItem[] = [];
}

/** 推荐项 */
export class RecItem {
  id: number = 0;
  name: string = '';
}

/** recommend 响应 data */
export class RecommendData {
  knowledgeList: RecItem[] = [];
  idiomList: RecItem[] = [];
}
