import { HttpClient } from '../service/HttpClient';
import { RouterManager } from '../service/RouterManager';
import { RouteConstants } from '../constants/RouteConstants';
import { RouteParamObject } from '../types/RouteParamObject';
import { ThemeColors } from '../constants/ThemeColors';
import { LoadingView } from '../components/LoadingView';
import { ErrorView } from '../components/ErrorView';

/**
 * 成语详情页（T5.5）。
 * 拼音/释义/出处/例句/近反义词/易混/常见误用/相关题目。
 */
@Component
export struct IdiomDetailPage {
  @State idiomId: number = 0;
  @State loading: boolean = true;
  @State loadError: boolean = false;
  @State word: string = '';
  @State pinyin: string = '';
  @State explanation: string = '';
  @State origin: string = '';
  @State example: string = '';
  @State synonyms: string = '';
  @State antonyms: string = '';
  @State confusing: string = '';
  @State commonError: string = '';
  @State favorited: boolean = false;
  @State relatedQuestions: IdiomRelatedQuestion[] = [];

  aboutToAppear(): void {
    // 参数在 NavDestination onReady 中获取（系统路由表下 aboutToAppear 时参数未注入）
    const param = RouterManager.getInstance().getParamByName(RouteConstants.IDIOM_DETAIL) as RouteParamObject;
    if (param !== undefined && param !== null) {
      this.idiomId = param.idiomId;
    }
  }

  async load(): Promise<void> {
    this.loading = true;
    this.loadError = false;
    const response = await HttpClient.get<IdiomDetailData>(`/idiom/${this.idiomId}`);
    if (response.code === 0 && response.data !== null) {
      const data = response.data;
      this.word = data.word;
      this.pinyin = data.pinyin;
      this.explanation = data.explanation;
      this.origin = data.origin;
      this.example = data.example;
      this.synonyms = data.synonyms;
      this.antonyms = data.antonyms;
      this.confusing = data.confusing;
      this.commonError = data.commonError;
      this.favorited = data.favorited;
      this.relatedQuestions = data.relatedQuestions;
    } else {
      this.loadError = true;
    }
    this.loading = false;
  }

  async toggleFavorite(): Promise<void> {
    const response = await HttpClient.post<boolean>(`/idiom/${this.idiomId}/favorite`, new Object());
    if (response.code === 0 && response.data !== null) {
      this.favorited = response.data;
    }
  }

  @Builder
  Section(title: string, content: string) {
    Column() {
      Text(title)
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .width('100%')
      Text(content)
        .fontSize(14)
        .lineHeight(22)
        .fontColor(ThemeColors.TEXT_SECONDARY)
        .width('100%')
        .margin({ top: 8 })
    }
    .width('100%')
    .padding(16)
    .margin({ left: 16, right: 16, top: 12 })
    .borderRadius(12)
    .backgroundColor(ThemeColors.CARD_BACKGROUND)
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
              Row() {
                Column() {
                  Text(this.word)
                    .fontSize(24)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(ThemeColors.PRIMARY)
                  Text(this.pinyin)
                    .fontSize(14)
                    .fontColor(ThemeColors.TEXT_SECONDARY)
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
  
                Text(this.favorited ? '★ 已收藏' : '☆ 收藏')
                  .fontSize(13)
                  .fontColor(this.favorited ? ThemeColors.WARNING : ThemeColors.TEXT_SECONDARY)
                  .onClick(() => {
                    this.toggleFavorite();
                  })
              }
              .width('100%')
              .padding(16)
  
              this.Section('释义', this.explanation)
              if (this.origin !== '') {
                this.Section('出处', this.origin)
              }
              if (this.example !== '') {
                this.Section('例句', this.example)
              }
              if (this.synonyms !== '') {
                this.Section('近义词', this.synonyms)
              }
              if (this.antonyms !== '') {
                this.Section('反义词', this.antonyms)
              }
              if (this.confusing !== '') {
                this.Section('易混成语', this.confusing)
              }
              if (this.commonError !== '') {
                this.Section('常见误用', this.commonError)
              }
  
              if (this.relatedQuestions.length > 0) {
                Column() {
                  Text('相关题目')
                    .fontSize(15)
                    .fontWeight(FontWeight.Bold)
                    .width('100%')
                    .margin({ bottom: 8 })
  
                  ForEach(this.relatedQuestions, (q: IdiomRelatedQuestion) => {
                    Column() {
                      Text(q.content)
                        .fontSize(14)
                        .lineHeight(20)
                        .width('100%')
                      Text(q.sourceName ?? '')
                        .fontSize(12)
                        .fontColor(ThemeColors.TEXT_TERTIARY)
                        .width('100%')
                        .margin({ top: 4 })
                    }
                    .width('100%')
                    .padding({ top: 8, bottom: 8 })
                  }, (q: IdiomRelatedQuestion) => q.id.toString())
                }
                .width('100%')
                .padding(16)
                .margin({ left: 16, right: 16, top: 12, bottom: 20 })
                .borderRadius(12)
                .backgroundColor(ThemeColors.CARD_BACKGROUND)
              }
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
      if (pathParam !== undefined && pathParam !== null && pathParam.idiomId > 0) {
        this.idiomId = pathParam.idiomId;
      } else {
        const param = RouterManager.getInstance().getParamByName(RouteConstants.IDIOM_DETAIL) as RouteParamObject;
        if (param !== undefined && param !== null && param.idiomId > 0) {
          this.idiomId = param.idiomId;
        }
      }
      this.load();
    })
  }
}

/** 相关题目项 */
export class IdiomRelatedQuestion {
  id: number = 0;
  content: string = '';
  sourceName: string = '';
}

/** 详情响应 data */
export class IdiomDetailData {
  id: number = 0;
  word: string = '';
  pinyin: string = '';
  explanation: string = '';
  origin: string = '';
  example: string = '';
  synonyms: string = '';
  antonyms: string = '';
  confusing: string = '';
  commonError: string = '';
  favorited: boolean = false;
  relatedQuestions: IdiomRelatedQuestion[] = [];
}

/** 系统路由表入口 */
@Builder
export function IdiomDetailPageBuilder() {
  IdiomDetailPage()
}
