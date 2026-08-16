import { HomePage } from './HomePage';
import { StudyPage } from './StudyPage';
import { PracticePage } from './PracticePage';
import { ReviewPage } from './ReviewPage';
import { MinePage } from './MinePage';

/**
 * 主容器（T1.4）：底部导航 TabBar（首页/学习/练习/复习/我的）。
 * 各 Tab 直接内嵌功能页（T1.4 优化：点 Tab 即进功能页，无需二次点击）。
 * 登录态守卫：进入本页即视为已登录（由登录流程/启动页保证）。
 */
@Component
export struct MainPage {
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
  NavDestination() {
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
          PracticePage()
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
}

/** 系统路由表入口 */
@Builder
export function MainPageBuilder() {
  MainPage()
}
