import { HttpClient } from '../service/HttpClient';
import { RouterManager } from '../service/RouterManager';
import { RouteConstants } from '../constants/RouteConstants';
import { RouteParamObject } from '../types/RouteParamObject';
import { ThemeColors } from '../constants/ThemeColors';
import { LoadingView } from '../components/LoadingView';
import { ErrorView } from '../components/ErrorView';

/**
 * 常识详情页（T5.4）。
 * 一句话记忆/核心知识/重点/易错点/相关真题/收藏/已掌握。
 */
@Component
export struct KnowledgeDetailPage {
  @State knowledgeId: number = 0;
  @State loading: boolean = true;
  @State loadError: boolean = false;
  @State title: string = '';
  @State summary: string = '';
  @State content: string = '';
  @State keyPoints: string = '';
  @State commonMistakes: string = '';
  @State difficulty: number = 0;
  @State mastery: number = 0;
  @State favorited: boolean = false;
  @State relatedQuestions: RelatedQuestion[] = [];

  aboutToAppear(): void {
    // 参数在 NavDestination onReady 中获取（系统路由表下 aboutToAppear 时参数未注入）
    const param = RouterManager.getInstance().getParamByName(RouteConstants.KNOWLEDGE_DETAIL) as RouteParamObject;
    if (param !== undefined && param !== null) {
      this.knowledgeId = param.knowledgeId;
    }
  }

  async load(): Promise<void> {
    this.loading = true;
    this.loadError = false;
    const response = await HttpClient.get<KnowledgeDetailData>(`/knowledge/${this.knowledgeId}`);
    if (response.code === 0 && response.data !== null) {
      const data = response.data;
      this.title = data.title;
      this.summary = data.summary;
      this.content = data.content;
      this.keyPoints = data.keyPoints;
      this.commonMistakes = data.commonMistakes;
      this.difficulty = data.difficulty;
      this.mastery = data.mastery;
      this.favorited = data.favorited;
      this.relatedQuestions = data.relatedQuestions;
    } else {
      this.loadError = true;
    }
    this.loading = false;
  }

  async toggleFavorite(): Promise<void> {
    const response = await HttpClient.post<boolean>(`/knowledge/${this.knowledgeId}/favorite`, new Object());
    if (response.code === 0 && response.data !== null) {
      this.favorited = response.data;
    }
  }

  async markMastered(): Promise<void> {
    const response = await HttpClient.post<Object>(`/knowledge/${this.knowledgeId}/mastered`, new Object());
    if (response.code === 0) {
      this.mastery = 2;
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
              // 标题区 + 操作
              Row() {
                Column() {
                  Text(this.title)
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                  Text(`难度 ${'★'.repeat(Math.max(1, this.difficulty))}`)
                    .fontSize(12)
                    .fontColor(ThemeColors.WARNING)
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
                if (this.mastery < 2) {
                  Text('标记已掌握')
                    .fontSize(13)
                    .fontColor(ThemeColors.PRIMARY)
                    .margin({ left: 12 })
                    .onClick(() => {
                      this.markMastered();
                    })
                } else {
                  Text(this.mastery >= 3 ? '已掌握' : '已学习')
                    .fontSize(13)
                    .fontColor(ThemeColors.SUCCESS)
                    .margin({ left: 12 })
                }
              }
              .width('100%')
              .padding(16)
  
              // 一句话记忆
              if (this.summary !== '') {
                Column() {
                  Text(this.summary)
                    .fontSize(15)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(ThemeColors.PRIMARY)
                    .width('100%')
                }
                .width('100%')
                .padding(16)
                .margin({ left: 16, right: 16 })
                .borderRadius(12)
                .backgroundColor('#E8F0FE')
              }
  
              // 核心知识
              this.Section('核心知识', this.content)
              // 重点
              if (this.keyPoints !== '') {
                this.Section('重点', this.keyPoints)
              }
              // 易错点
              if (this.commonMistakes !== '') {
                this.Section('易错点', this.commonMistakes)
              }
  
              // 相关真题
              if (this.relatedQuestions.length > 0) {
                Column() {
                  Text('相关真题')
                    .fontSize(15)
                    .fontWeight(FontWeight.Bold)
                    .width('100%')
                    .margin({ bottom: 8 })
  
                  ForEach(this.relatedQuestions, (q: RelatedQuestion) => {
                    Column() {
                      Text(q.content)
                        .fontSize(14)
                        .lineHeight(20)
                        .width('100%')
                      Text(`${q.sourceName ?? ''}${q.examYear > 0 ? ' · ' + q.examYear : ''}`)
                        .fontSize(12)
                        .fontColor(ThemeColors.TEXT_TERTIARY)
                        .width('100%')
                        .margin({ top: 4 })
                    }
                    .width('100%')
                    .padding({ top: 8, bottom: 8 })
                  }, (q: RelatedQuestion) => q.id.toString())
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
      if (pathParam !== undefined && pathParam !== null && pathParam.knowledgeId > 0) {
        this.knowledgeId = pathParam.knowledgeId;
      } else {
        const param = RouterManager.getInstance().getParamByName(RouteConstants.KNOWLEDGE_DETAIL) as RouteParamObject;
        if (param !== undefined && param !== null && param.knowledgeId > 0) {
          this.knowledgeId = param.knowledgeId;
        }
      }
      this.load();
    })
  }
}

/** 相关真题项 */
export class RelatedQuestion {
  id: number = 0;
  content: string = '';
  sourceName: string = '';
  examYear: number = 0;
}

/** 详情响应 data */
export class KnowledgeDetailData {
  id: number = 0;
  title: string = '';
  categoryId: number = 0;
  summary: string = '';
  content: string = '';
  keyPoints: string = '';
  commonMistakes: string = '';
  difficulty: number = 0;
  mastery: number = 0;
  favorited: boolean = false;
  relatedQuestions: RelatedQuestion[] = [];
}

/** 系统路由表入口 */
@Builder
export function KnowledgeDetailPageBuilder() {
  KnowledgeDetailPage()
}
