import { KnowledgeRepository, KnowledgeCategoryItem } from '../repository/KnowledgeRepository';
import { NavigationService } from '../service/NavigationService';
import { RouteConstants } from '../constants/RouteConstants';
import { RouteParamObject } from '../types/RouteParamObject';
import { ThemeColors } from '../constants/ThemeColors';
import { LoadingView } from '../components/LoadingView';
import { ErrorView } from '../components/ErrorView';
import { EmptyView } from '../components/EmptyView';

/**
 * 常识分类页（T5.3）。
 * 展示 9 大分类，含各分类知识点数与已掌握数。
 */
@Entry
@Component
struct KnowledgeCategoryPage {
  @State categories: KnowledgeCategoryItem[] = [];
  @State loading: boolean = true;
  @State loadError: boolean = false;

  aboutToAppear(): void {
    this.load();
  }

  async load(): Promise<void> {
    this.loading = true;
    this.loadError = false;
    const response = await KnowledgeRepository.categories();
    if (response.code === 0 && response.data !== null) {
      this.categories = response.data;
    } else {
      this.loadError = true;
    }
    this.loading = false;
  }

  @Builder
  CategoryCard(item: KnowledgeCategoryItem) {
    Column() {
      Row() {
        Text(item.name)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
        Blank()
        Text(`${item.masteredCount}/${item.knowledgeCount} 已掌握`)
          .fontSize(12)
          .fontColor(ThemeColors.TEXT_TERTIARY)
      }
      .width('100%')

      Row() {
        Text(`共 ${item.knowledgeCount} 个知识点`)
          .fontSize(12)
          .fontColor(ThemeColors.TEXT_SECONDARY)
        Blank()
        Text('查看 >')
          .fontSize(12)
          .fontColor(ThemeColors.PRIMARY)
      }
      .width('100%')
      .margin({ top: 8 })
    }
    .width('100%')
    .padding(14)
    .margin({ left: 16, right: 16, top: 10 })
    .borderRadius(12)
    .backgroundColor(ThemeColors.CARD_BACKGROUND)
    .onClick(() => {
      const param = new RouteParamObject();
      param.categoryId = item.id;
      NavigationService.push(RouteConstants.KNOWLEDGE_LIST, param);
    })
  }

  build() {
    Column() {
      Text('常识')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .padding({ left: 16, top: 12 })

      if (this.loading) {
        LoadingView()
      } else if (this.loadError) {
        ErrorView({ onRetry: () => this.load() })
      } else if (this.categories.length === 0) {
        EmptyView({ emptyText: '暂无常识分类' })
      } else {
        List() {
          ForEach(this.categories, (item: KnowledgeCategoryItem) => {
            ListItem() {
              this.CategoryCard(item)
            }
          }, (item: KnowledgeCategoryItem) => item.id.toString())
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
