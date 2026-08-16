import { IdiomRepository, IdiomCategoryItem } from '../repository/IdiomRepository';
import { NavigationService } from '../service/NavigationService';
import { RouteConstants } from '../constants/RouteConstants';
import { RouteParamObject } from '../types/RouteParamObject';
import { ThemeColors } from '../constants/ThemeColors';
import { LoadingView } from '../components/LoadingView';
import { ErrorView } from '../components/ErrorView';
import { EmptyView } from '../components/EmptyView';

/**
 * 成语分类页（T5.5）。
 */
@Entry
@Component
struct IdiomCategoryPage {
  @State categories: IdiomCategoryItem[] = [];
  @State loading: boolean = true;
  @State loadError: boolean = false;

  aboutToAppear(): void {
    this.load();
  }

  async load(): Promise<void> {
    this.loading = true;
    this.loadError = false;
    const response = await IdiomRepository.categories();
    if (response.code === 0 && response.data !== null) {
      this.categories = response.data;
    } else {
      this.loadError = true;
    }
    this.loading = false;
  }

  @Builder
  CategoryCard(item: IdiomCategoryItem) {
    Column() {
      Row() {
        Text(item.name)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
        Blank()
        Text('查看 >')
          .fontSize(12)
          .fontColor(ThemeColors.PRIMARY)
      }
      .width('100%')
    }
    .width('100%')
    .padding(14)
    .margin({ left: 16, right: 16, top: 10 })
    .borderRadius(12)
    .backgroundColor(ThemeColors.CARD_BACKGROUND)
    .onClick(() => {
      const param = new RouteParamObject();
      param.categoryId = item.id;
      NavigationService.push(RouteConstants.IDIOM_LIST, param);
    })
  }

  build() {
    Column() {
      Text('成语')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .padding({ left: 16, top: 12 })

      if (this.loading) {
        LoadingView()
      } else if (this.loadError) {
        ErrorView({ onRetry: () => this.load() })
      } else if (this.categories.length === 0) {
        EmptyView({ emptyText: '暂无成语分类' })
      } else {
        List() {
          ForEach(this.categories, (item: IdiomCategoryItem) => {
            ListItem() {
              this.CategoryCard(item)
            }
          }, (item: IdiomCategoryItem) => item.id.toString())
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
