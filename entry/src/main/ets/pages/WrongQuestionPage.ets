import { HttpClient } from '../service/HttpClient';
import { PracticeRepository, WrongItem, PracticeSessionData } from '../repository/PracticeRepository';
import { NavigationService } from '../service/NavigationService';
import { RouteConstants } from '../constants/RouteConstants';
import { RouteParamObject } from '../types/RouteParamObject';
import { ThemeColors } from '../constants/ThemeColors';
import { LoadingView } from '../components/LoadingView';
import { ErrorView } from '../components/ErrorView';
import { EmptyView } from '../components/EmptyView';

/**
 * 错题本页（T6.6）：错误次数/最近错误时间/再练/移出。
 */
@Entry
@Component
struct WrongQuestionPage {
  @State items: WrongItem[] = [];
  @State loading: boolean = true;
  @State loadError: boolean = false;
  @State retraining: boolean = false;

  aboutToAppear(): void {
    this.load();
  }

  async load(): Promise<void> {
    this.loading = true;
    this.loadError = false;
    const response = await HttpClient.get<PageData<WrongItem>>('/wrong/list?page=1&size=50');
    if (response.code === 0 && response.data !== null) {
      this.items = response.data.records;
    } else {
      this.loadError = true;
    }
    this.loading = false;
  }

  async removeItem(wrongId: number): Promise<void> {
    const response = await HttpClient.post<Object>(`/wrong/${wrongId}/remove`, new Object());
    if (response.code === 0) {
      this.load();
    }
  }

  async retrain(): Promise<void> {
    this.retraining = true;
    const response = await PracticeRepository.wrongPractice(10);
    this.retraining = false;
    if (response.code === 0 && response.data !== null) {
      const param = new RouteParamObject();
      param.targetType = 5;
      NavigationService.push(RouteConstants.ANSWER, param);
    }
  }

  formatTime(time: string): string {
    if (time === '') {
      return '';
    }
    return time.substring(0, 16).replace('T', ' ');
  }

  build() {
    Column() {
      Row() {
        Text('错题本')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
        if (this.items.length > 0) {
          Button('错题重练')
            .height(36)
            .backgroundColor(ThemeColors.SUCCESS)
            .enabled(!this.retraining)
            .onClick(() => {
              this.retrain();
            })
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12 })

      if (this.loading) {
        LoadingView()
      } else if (this.loadError) {
        ErrorView({ onRetry: () => this.load() })
      } else if (this.items.length === 0) {
        EmptyView({ emptyText: '暂无错题，继续保持！' })
      } else {
        List() {
          ForEach(this.items, (item: WrongItem) => {
            ListItem() {
              Column() {
                Text(item.content)
                  .fontSize(14)
                  .lineHeight(22)
                  .width('100%')
                Row() {
                  Text(`错误 ${item.wrongCount} 次`)
                    .fontSize(12)
                    .fontColor(ThemeColors.DANGER)
                  Text(` · ${this.formatTime(item.lastWrongTime)}`)
                    .fontSize(12)
                    .fontColor(ThemeColors.TEXT_TERTIARY)
                    .margin({ left: 8 })
                  Blank()
                  Text('移出')
                    .fontSize(12)
                    .fontColor(ThemeColors.TEXT_SECONDARY)
                    .onClick(() => {
                      this.removeItem(item.wrongId);
                    })
                }
                .width('100%')
                .margin({ top: 8 })
              }
              .width('100%')
              .padding(14)
              .margin({ left: 16, right: 16, top: 10 })
              .borderRadius(10)
              .backgroundColor(ThemeColors.CARD_BACKGROUND)
            }
          }, (item: WrongItem) => item.wrongId.toString())
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

/** 分页响应 */
export class PageData<T> {
  records: T[] = [];
  total: number = 0;
}
