import { IdiomRepository, IdiomListItem } from '../repository/IdiomRepository';
import { RouterManager } from '../service/RouterManager';
import { NavigationService } from '../service/NavigationService';
import { RouteConstants } from '../constants/RouteConstants';
import { RouteParamObject } from '../types/RouteParamObject';
import { ThemeColors } from '../constants/ThemeColors';
import { LoadingView } from '../components/LoadingView';
import { ErrorView } from '../components/ErrorView';
import { EmptyView } from '../components/EmptyView';

/**
 * 成语列表页（T5.5）。
 */
@Component
export struct IdiomListPage {
  @State categoryId: number = 0;
  @State keyword: string = '';
  @State items: IdiomListItem[] = [];
  @State page: number = 1;
  @State total: number = 0;
  @State loading: boolean = true;
  @State loadError: boolean = false;
  @State loadingMore: boolean = false;
  @State hasMore: boolean = true;

  aboutToAppear(): void {
    // 参数在 NavDestination onReady 中获取（系统路由表下 aboutToAppear 时参数未注入）
    const param = RouterManager.getInstance().getParamByName(RouteConstants.IDIOM_LIST) as RouteParamObject;
    if (param !== undefined && param !== null) {
      this.categoryId = param.categoryId;
    }
  }

  async load(reset: boolean = true): Promise<void> {
    if (reset) {
      this.page = 1;
      this.loading = true;
    } else {
      this.loadingMore = true;
    }
    this.loadError = false;
    const response = await IdiomRepository.list(this.categoryId, this.keyword, this.page, 20);
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

  build() {
  NavDestination() {
      Column() {
        Row() {
          TextInput({ placeholder: '搜索成语', text: this.keyword })
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
          EmptyView({ emptyText: '暂无成语' })
        } else {
          List() {
            ForEach(this.items, (item: IdiomListItem) => {
              ListItem() {
                Row() {
                  Column() {
                    Text(item.word)
                      .fontSize(16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(ThemeColors.PRIMARY)
                    Text(item.pinyin)
                      .fontSize(12)
                      .fontColor(ThemeColors.TEXT_TERTIARY)
                      .margin({ top: 2 })
                    Text(item.explanation)
                      .fontSize(13)
                      .fontColor(ThemeColors.TEXT_SECONDARY)
                      .margin({ top: 4 })
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                }
                .width('100%')
                .padding(14)
                .onClick(() => {
                  const param = new RouteParamObject();
                  param.idiomId = item.id;
                  NavigationService.push(RouteConstants.IDIOM_DETAIL, param);
                })
              }
            }, (item: IdiomListItem) => item.id.toString())
  
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
          .cachedCount(5)
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(ThemeColors.BACKGROUND)
    }
    .onReady((context: NavDestinationContext) => {
      // 系统路由表模式下：优先用 onReady 的 context.pathInfo.param 取参数（官方推荐）
      const pathParam = context.pathInfo.param as RouteParamObject;
      if (pathParam !== undefined && pathParam !== null && pathParam.categoryId > 0) {
        this.categoryId = pathParam.categoryId;
      } else {
        const param = RouterManager.getInstance().getParamByName(RouteConstants.IDIOM_LIST) as RouteParamObject;
        if (param !== undefined && param !== null && param.categoryId > 0) {
          this.categoryId = param.categoryId;
        }
      }
      this.load();
    })
  }
}

/** 系统路由表入口 */
@Builder
export function IdiomListPageBuilder() {
  IdiomListPage()
}
