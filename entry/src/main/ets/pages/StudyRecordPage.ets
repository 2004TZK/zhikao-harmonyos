import { StatsRepository, StudyRecordItem } from '../repository/StatsRepository';
import { ThemeColors } from '../constants/ThemeColors';
import { LoadingView } from '../components/LoadingView';
import { ErrorView } from '../components/ErrorView';
import { EmptyView } from '../components/EmptyView';

/**
 * 学习记录页（T8.3）：时间线记录。
 */
@Component
export struct StudyRecordPage {
  @State items: StudyRecordItem[] = [];
  @State loading: boolean = true;
  @State loadError: boolean = false;

  aboutToAppear(): void {
    this.load();
  }

  async load(): Promise<void> {
    this.loading = true;
    this.loadError = false;
    const response = await StatsRepository.records(1, 50);
    if (response.code === 0 && response.data !== null) {
      this.items = response.data.records;
    } else {
      this.loadError = true;
    }
    this.loading = false;
  }

  recordTypeName(type: number): string {
    if (type === 1) {
      return '学习知识点';
    }
    if (type === 2) {
      return '学习成语';
    }
    if (type === 3) {
      return '练习';
    }
    return '复习';
  }

  formatTime(time: string): string {
    if (time === '') {
      return '';
    }
    return time.substring(0, 16).replace('T', ' ');
  }

  build() {
  NavDestination() {
      Column() {
        Text('学习记录')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .padding({ left: 16, top: 12 })
  
        if (this.loading) {
          LoadingView()
        } else if (this.loadError) {
          ErrorView({ onRetry: () => this.load() })
        } else if (this.items.length === 0) {
          EmptyView({ emptyText: '暂无学习记录' })
        } else {
          List() {
            ForEach(this.items, (item: StudyRecordItem) => {
              ListItem() {
                Row() {
                  Text(this.recordTypeName(item.recordType))
                    .fontSize(14)
                    .fontColor(ThemeColors.PRIMARY)
                  Text(` · ${Math.round(item.durationSeconds / 60)} 分钟`)
                    .fontSize(13)
                    .fontColor(ThemeColors.TEXT_SECONDARY)
                    .margin({ left: 8 })
                  Blank()
                  Text(this.formatTime(item.createdAt))
                    .fontSize(12)
                    .fontColor(ThemeColors.TEXT_TERTIARY)
                }
                .width('100%')
                .padding(14)
                .margin({ left: 16, right: 16, top: 8 })
                .borderRadius(10)
                .backgroundColor(ThemeColors.CARD_BACKGROUND)
              }
            }, (item: StudyRecordItem) => item.id.toString())
          }
          .layoutWeight(1)
          .width('100%')
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(ThemeColors.BACKGROUND)
  }
}
}

/** 系统路由表入口 */
@Builder
export function StudyRecordPageBuilder() {
  StudyRecordPage()
}
