import { KnowledgeRepository, KnowledgeListItem } from '../repository/KnowledgeRepository';
import { RouterManager } from '../service/RouterManager';
import { NavigationService } from '../service/NavigationService';
import { RouteConstants } from '../constants/RouteConstants';
import { RouteParamObject } from '../types/RouteParamObject';
import { ThemeColors } from '../constants/ThemeColors';
import { LoadingView } from '../components/LoadingView';
import { ErrorView } from '../components/ErrorView';
import { EmptyView } from '../components/EmptyView';

/**
 * 常识列表页（T5.3）。
 * 分页加载、搜索、掌握度徽标。
 */
@Entry
@Component
struct KnowledgeListPage {
  @State categoryId: number = 0;
  @State keyword: string = '';
  @State items: KnowledgeListItem[] = [];
  @State page: number = 1;
  @State total: number = 0;
  @State loading: boolean = true;
  @State loadError: boolean = false;
  @State loadingMore: boolean = false;
  @State hasMore: boolean = true;

  aboutToAppear(): void {
    // 路由参数：categoryId（从 RouterManager 当前页面参数读取）
    const param = RouterManager.getInstance().getParamByName(RouteConstants.KNOWLEDGE_LIST) as RouteParamObject;
    if (param !== undefined && param !== null) {
      this.categoryId = param.categoryId;
    }
    this.load();
  }

  async load(reset: boolean = true): Promise<void> {
    if (reset) {
      this.page = 1;
      this.loading = true;
    } else {
      this.loadingMore = true;
    }
    this.loadError = false;
    const response = await KnowledgeRepository.list(
      this.categoryId, this.keyword, undefined, this.page, 20);
    if (response.code === 0 && response.data !== null) {
      const data = response.data;
      this.total = data.total;
      if (reset) {
        this.items = data.records;
      } else {
        this.items = this.items.concat(data.records);
      }
      this.hasMore = this.items.length < this.total;
    } else {
      this.loadError = true;
    }
    this.loading = false;
    this.loadingMore = false;
  }

  loadMore(): void {
    if (this.hasMore && !this.loadingMore) {
      this.page++;
      this.load(false);
    }
  }

  masteryText(mastery: number): string {
    if (mastery === 0) {
      return '未学';
    }
    if (mastery === 1) {
      return '学习中';
    }
    if (mastery === 2) {
      return '已学习';
    }
    if (mastery === 3) {
      return '掌握';
    }
    return '熟练';
  }

  masteryColor(mastery: number): string {
    if (mastery >= 3) {
      return ThemeColors.SUCCESS;
    }
    if (mastery >= 1) {
      return ThemeColors.PRIMARY;
    }
    return ThemeColors.TEXT_TERTIARY;
  }

  build() {
    Column() {
      // 搜索栏
      Row() {
        TextInput({ placeholder: '搜索常识知识点', text: this.keyword })
          .layoutWeight(1)
          .height(40)
          .onChange((value: string) => {
            this.keyword = value;
          })
        Button('搜索')
          .height(40)
          .margin({ left: 8 })
          .backgroundColor(ThemeColors.PRIMARY)
          .onClick(() => {
            this.load(true);
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12 })

      if (this.loading) {
        LoadingView()
      } else if (this.loadError) {
        ErrorView({ onRetry: () => this.load(true) })
      } else if (this.items.length === 0) {
        EmptyView({ emptyText: '暂无知识点' })
      } else {
        List() {
          ForEach(this.items, (item: KnowledgeListItem) => {
            ListItem() {
              Row() {
                Column() {
                  Text(item.title)
                    .fontSize(15)
                    .fontWeight(FontWeight.Medium)
                  Text(item.summary)
                    .fontSize(12)
                    .fontColor(ThemeColors.TEXT_TERTIARY)
                    .margin({ top: 4 })
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Text(this.masteryText(item.mastery))
                  .fontSize(11)
                  .fontColor(Color.White)
                  .backgroundColor(this.masteryColor(item.mastery))
                  .borderRadius(4)
                  .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              }
              .width('100%')
              .padding(14)
              .onClick(() => {
                const param = new RouteParamObject();
                param.knowledgeId = item.id;
                NavigationService.push(RouteConstants.KNOWLEDGE_DETAIL, param);
              })
            }
          }, (item: KnowledgeListItem) => item.id.toString())

          if (this.hasMore) {
            ListItem() {
              Text(this.loadingMore ? '加载中...' : '上拉加载更多')
                .fontSize(13)
                .fontColor(ThemeColors.TEXT_TERTIARY)
                .width('100%')
                .textAlign(TextAlign.Center)
                .padding(12)
            }
            .onAppear(() => {
              this.loadMore();
            })
          }
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
