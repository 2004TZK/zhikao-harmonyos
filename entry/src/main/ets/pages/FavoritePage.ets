import { HttpClient } from '../service/HttpClient';
import { NavigationService } from '../service/NavigationService';
import { RouteConstants } from '../constants/RouteConstants';
import { RouteParamObject } from '../types/RouteParamObject';
import { ThemeColors } from '../constants/ThemeColors';
import { LoadingView } from '../components/LoadingView';
import { ErrorView } from '../components/ErrorView';
import { EmptyView } from '../components/EmptyView';

/**
 * 收藏列表页（T5.6）：知识点/成语双 Tab。
 */
@Component
export struct FavoritePage {
  @State currentTab: number = 0;
  @State knowledgeItems: FavoriteItem[] = [];
  @State idiomItems: FavoriteItem[] = [];
  @State loading: boolean = true;
  @State loadError: boolean = false;

  aboutToAppear(): void {
    this.load();
  }

  async load(): Promise<void> {
    this.loading = true;
    this.loadError = false;
    // 并行请求两类收藏
    const kResp = await HttpClient.get<FavoriteItem[]>('/favorite/list?targetType=1');
    const iResp = await HttpClient.get<FavoriteItem[]>('/favorite/list?targetType=2');
    if (kResp.code === 0 && kResp.data !== null) {
      this.knowledgeItems = kResp.data;
    }
    if (iResp.code === 0 && iResp.data !== null) {
      this.idiomItems = iResp.data;
    }
    if (kResp.code !== 0 && iResp.code !== 0) {
      this.loadError = true;
    }
    this.loading = false;
  }

  openDetail(item: FavoriteItem): void {
    const param = new RouteParamObject();
    if (this.currentTab === 0) {
      param.knowledgeId = item.targetId;
      NavigationService.push(RouteConstants.KNOWLEDGE_DETAIL, param);
    } else {
      param.idiomId = item.targetId;
      NavigationService.push(RouteConstants.IDIOM_DETAIL, param);
    }
  }

  build() {
  NavDestination() {
      Column() {
        // Tab
        Row() {
          Text('知识点')
            .fontSize(this.currentTab === 0 ? 16 : 14)
            .fontWeight(this.currentTab === 0 ? FontWeight.Bold : FontWeight.Normal)
            .fontColor(this.currentTab === 0 ? ThemeColors.PRIMARY : ThemeColors.TEXT_TERTIARY)
            .onClick(() => {
              this.currentTab = 0;
            })
          Text('成语')
            .fontSize(this.currentTab === 1 ? 16 : 14)
            .fontWeight(this.currentTab === 1 ? FontWeight.Bold : FontWeight.Normal)
            .fontColor(this.currentTab === 1 ? ThemeColors.PRIMARY : ThemeColors.TEXT_TERTIARY)
            .margin({ left: 40 })
            .onClick(() => {
              this.currentTab = 1;
            })
        }
        .width('100%')
        .padding({ top: 14, bottom: 10 })
        .justifyContent(FlexAlign.Center)
  
        if (this.loading) {
          LoadingView()
        } else if (this.loadError) {
          ErrorView({ onRetry: () => this.load() })
        } else if (this.currentTab === 0 && this.knowledgeItems.length === 0) {
          EmptyView({ emptyText: '暂无收藏的知识点' })
        } else if (this.currentTab === 1 && this.idiomItems.length === 0) {
          EmptyView({ emptyText: '暂无收藏的成语' })
        } else {
          List() {
            if (this.currentTab === 0) {
              ForEach(this.knowledgeItems, (item: FavoriteItem) => {
                ListItem() {
                  Row() {
                    Text(item.title)
                      .fontSize(15)
                      .layoutWeight(1)
                    Text('去查看 >')
                      .fontSize(12)
                      .fontColor(ThemeColors.PRIMARY)
                  }
                  .width('100%')
                  .padding(14)
                  .onClick(() => {
                    this.openDetail(item);
                  })
                }
              }, (item: FavoriteItem) => item.targetId.toString())
            } else {
              ForEach(this.idiomItems, (item: FavoriteItem) => {
                ListItem() {
                  Row() {
                    Text(item.title)
                      .fontSize(15)
                      .layoutWeight(1)
                    Text('去查看 >')
                      .fontSize(12)
                      .fontColor(ThemeColors.PRIMARY)
                  }
                  .width('100%')
                  .padding(14)
                  .onClick(() => {
                    this.openDetail(item);
                  })
                }
              }, (item: FavoriteItem) => item.targetId.toString())
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
}

/** 收藏项 */
export class FavoriteItem {
  id: number = 0;
  userId: number = 0;
  targetType: number = 0;
  targetId: number = 0;
  title: string = '';
  createdAt: string = '';
}

/** 系统路由表入口 */
@Builder
export function FavoritePageBuilder() {
  FavoritePage()
}
