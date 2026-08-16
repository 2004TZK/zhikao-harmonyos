import { NavigationService } from '../service/NavigationService';
import { RouteConstants } from '../constants/RouteConstants';

/**
 * 协议展示页（T4.2）：隐私政策 / 用户协议。
 * 入口：设置页与首次启动弹窗。
 */
@Entry
@Component
struct AgreementPage {
  @State currentTab: number = 0;

  build() {
    Column() {
      // 顶部 Tab 切换
      Row() {
        Text('隐私政策')
          .fontSize(this.currentTab === 0 ? 16 : 14)
          .fontWeight(this.currentTab === 0 ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.currentTab === 0 ? '#1A73E8' : '#999999')
          .onClick(() => {
            this.currentTab = 0;
          })
        Text('用户协议')
          .fontSize(this.currentTab === 1 ? 16 : 14)
          .fontWeight(this.currentTab === 1 ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.currentTab === 1 ? '#1A73E8' : '#999999')
          .margin({ left: 40 })
          .onClick(() => {
            this.currentTab = 1;
          })
      }
      .width('100%')
      .padding({ top: 16, bottom: 12 })
      .justifyContent(FlexAlign.Center)

      if (this.currentTab === 0) {
        Scroll() {
          Text('隐私政策（占位文本，正式版由运营补充）\n\n' +
            '1. 我们仅收集为提供学习服务所必需的信息：账号信息（用户名、密码哈希）、学习记录（浏览/练习/复习行为）、设备匿名标识（游客 UUID，不采集硬件指纹）。\n\n' +
            '2. 您的学习数据用于为您提供个性化复习计划与学习统计。\n\n' +
            '3. 我们不会向第三方出售您的个人信息。\n\n' +
            '4. 您可以随时在设置中注销账号，注销后您的学习行为数据将被删除。\n\n' +
            '5. 如有疑问请联系我们。')
            .fontSize(14)
            .lineHeight(22)
            .fontColor('#333333')
            .padding(16)
        }
        .layoutWeight(1)
      } else {
        Scroll() {
          Text('用户协议（占位文本，正式版由运营补充）\n\n' +
            '1. 本 App 为公务员考试、事业单位考试备考学习工具，提供常识与成语学习内容。\n\n' +
            '2. 用户应遵守法律法规，不得利用本 App 从事违法违规活动。\n\n' +
            '3. 学习内容仅供个人学习使用，不得用于商业用途或二次传播。\n\n' +
            '4. 本协议最终解释权归本产品所有。')
            .fontSize(14)
            .lineHeight(22)
            .fontColor('#333333')
            .padding(16)
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
}
