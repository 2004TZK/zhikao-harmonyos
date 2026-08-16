import { HomePage } from './HomePage';
import { StudyPage } from './StudyPage';
import { NavigationService } from '../service/NavigationService';
import { RouteConstants } from '../constants/RouteConstants';
import { ReviewPage } from './ReviewPage';
import { MinePage } from './MinePage';

/**
 * 主容器（T1.4）：底部导航 TabBar（首页/学习/练习/复习/我的）。
 * 登录态守卫：进入本页即视为已登录（由登录流程/启动页保证）。
 */
@Entry
@Component
struct MainPage {
  @State currentIndex: number = 0;
  private tabsController: TabsController = new TabsController();

  @Builder
  TabBuilder(title: string, index: number) {
    Column() {
      Text(title)
        .fontSize(this.currentIndex === index ? 18 : 16)
        .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.currentIndex === index ? '#1A73E8' : '#999999')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
      TabContent() {
        HomePage()
      }
      .tabBar(this.TabBuilder('首页', 0))

      TabContent() {
        StudyPage()
      }
      .tabBar(this.TabBuilder('学习', 1))

      TabContent() {
        Column() {
          Text('练习')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 40 })
          Text('每日挑战 / 专项训练 / 随机训练')
            .fontSize(13)
            .fontColor('#999999')
            .margin({ top: 12 })
          Button('进入练习')
            .width(140)
            .margin({ top: 32 })
            .onClick(() => {
              NavigationService.push(RouteConstants.PRACTICE);
            })
        }
        .width('100%')
        .height('100%')
        .backgroundColor(Color.White)
      }
      .tabBar(this.TabBuilder('练习', 2))

      TabContent() {
        ReviewPage()
      }
      .tabBar(this.TabBuilder('复习', 3))

      TabContent() {
        MinePage()
      }
      .tabBar(this.TabBuilder('我的', 4))
    }
    .scrollable(false)
    .barHeight(56)
    .onChange((index: number) => {
      this.currentIndex = index;
    })
    .backgroundColor(Color.White)
  }
}
