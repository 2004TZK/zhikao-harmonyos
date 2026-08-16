import { StatsRepository, StatsOverviewData, TrendPoint } from '../repository/StatsRepository';
import { ThemeColors } from '../constants/ThemeColors';
import { LoadingView } from '../components/LoadingView';
import { ErrorView } from '../components/ErrorView';

/**
 * 学习统计页（T8.2）：数据卡片 + 近 7 天趋势图（柱状）。
 */
@Entry
@Component
struct StatsPage {
  @State overview: StatsOverviewData = new StatsOverviewData();
  @State trend: TrendPoint[] = [];
  @State loading: boolean = true;
  @State loadError: boolean = false;

  aboutToAppear(): void {
    this.load();
  }

  async load(): Promise<void> {
    this.loading = true;
    this.loadError = false;
    const ov = await StatsRepository.overview();
    const tr = await StatsRepository.trend(7);
    if (ov.code === 0 && ov.data !== null) {
      this.overview = ov.data;
    } else {
      this.loadError = true;
    }
    if (tr.code === 0 && tr.data !== null) {
      this.trend = tr.data;
    }
    this.loading = false;
  }

  @Builder
  StatCard(label: string, value: string, color: string) {
    Column() {
      Text(value)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
      Text(label)
        .fontSize(11)
        .fontColor(ThemeColors.TEXT_TERTIARY)
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .padding({ top: 12, bottom: 12 })
    .borderRadius(10)
    .backgroundColor(ThemeColors.CARD_BACKGROUND)
  }

  build() {
    Column() {
      Text('学习统计')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .padding({ left: 16, top: 12 })

      if (this.loading) {
        LoadingView()
      } else if (this.loadError) {
        ErrorView({ onRetry: () => this.load() })
      } else {
        Scroll() {
          Column() {
            // 数据卡片行 1
            Row() {
              this.StatCard('连续天数', String(this.overview.streakDays), ThemeColors.PRIMARY)
              this.StatCard('学习天数', String(this.overview.studyDays), ThemeColors.SUCCESS)
              this.StatCard('累计时长(分)', String(this.overview.totalStudyMinutes), ThemeColors.WARNING)
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 16 })
            .alignItems(VerticalAlign.Top)

            // 数据卡片行 2
            Row() {
              this.StatCard('答题量', String(this.overview.totalAnswers), ThemeColors.PRIMARY)
              this.StatCard('正确率', `${this.overview.accuracy}%`, ThemeColors.SUCCESS)
              this.StatCard('已掌握', String(this.overview.knowledgeMastered + this.overview.idiomMastered), ThemeColors.WARNING)
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 12 })
            .alignItems(VerticalAlign.Top)

            // 趋势图（近 7 天时长柱状）
            Column() {
              Text('近 7 天学习时长（分钟）')
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .width('100%')
                .margin({ bottom: 12 })

              Row() {
                ForEach(this.trend, (point: TrendPoint) => {
                  Column() {
                    Text(String(point.studyMinutes))
                      .fontSize(10)
                      .fontColor(ThemeColors.TEXT_SECONDARY)
                    // 柱条
                    Blank()
                    Column() {
                      Text('')
                        .width(18)
                        .height(Math.max(2, point.studyMinutes * 2))
                        .backgroundColor(ThemeColors.PRIMARY)
                        .borderRadius(4)
                    }
                    .width(18)
                    .justifyContent(FlexAlign.End)
                    .layoutWeight(1)
                    Text(this.shortDate(point.date))
                      .fontSize(10)
                      .fontColor(ThemeColors.TEXT_TERTIARY)
                      .margin({ top: 4 })
                  }
                  .layoutWeight(1)
                  .height(160)
                  .justifyContent(FlexAlign.Center)
                }, (point: TrendPoint) => point.date)
              }
              .width('100%')
              .padding({ top: 8 })
            }
            .width('100%')
            .padding(14)
            .margin({ left: 16, right: 16, top: 12, bottom: 16 })
            .borderRadius(10)
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

  shortDate(date: string): string {
    if (date.length < 10) {
      return date;
    }
    return date.substring(5).replace('-', '/');
  }
}
