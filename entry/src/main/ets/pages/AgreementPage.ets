import { NavigationService } from '../service/NavigationService';
import { RouteConstants } from '../constants/RouteConstants';

/**
 * 协议展示页（T4.2）：隐私政策 / 用户协议。
 * 入口：设置页与首次启动弹窗。
 * 更新：T10.10 发布合规自查——补充完整隐私政策与用户协议正文（联系方式由运营配置）。
 */
@Entry
@Component
struct AgreementPage {
  @State currentTab: number = 0;
  /** 客服/联系方式（发布前由运营填入正式邮箱或公众号） */
  private readonly contact: string = 'support@zhikao.example.com';

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
          Text(this.privacyText())
            .fontSize(14)
            .lineHeight(22)
            .fontColor('#333333')
            .padding(16)
        }
        .layoutWeight(1)
      } else {
        Scroll() {
          Text(this.agreementText())
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

  private privacyText(): string {
    return '知考隐私政策\n\n' +
      '更新日期：2026 年 8 月\n' +
      '生效日期：2026 年 8 月\n\n' +
      '我们深知个人信息对您的重要性，并会尽全力保护您的个人信息安全。本隐私政策旨在帮助您了解我们如何处理您的个人信息。\n\n' +
      '一、我们收集的信息\n' +
      '1. 账号信息：您注册时提供的用户名与密码（密码经加密存储，不保存明文）。\n' +
      '2. 学习信息：您在本应用内的学习行为数据，包括内容浏览记录、练习与答题记录、错题记录、复习进度、收藏内容、学习时长与统计信息。\n' +
      '3. 设备匿名标识：游客模式下生成的随机 UUID，用于标识游客身份；我们不采集设备硬件指纹、IMEI 等设备唯一标识。\n\n' +
      '二、信息的使用\n' +
      '我们仅将上述信息用于：为您提供学习、练习、复习与统计功能；生成个性化复习计划；改进产品与服务；保障账号与系统安全。\n\n' +
      '三、信息的共享与公开\n' +
      '我们不会向任何第三方出售您的个人信息。除法律法规要求、监管机构依法调取或获得您的明确同意外，我们不会向第三方共享或公开您的个人信息。\n\n' +
      '四、信息的存储与保护\n' +
      '您的个人信息存储于境内服务器，我们采取访问控制、加密传输（HTTPS）等合理措施保护信息安全。\n\n' +
      '五、您的权利\n' +
      '您有权访问、更正、删除您的个人信息；有权注销账号。注销账号后，您的学习行为数据将被删除，账号信息将按要求脱敏保留。\n\n' +
      '六、未成年人保护\n' +
      '本应用面向备考成人用户。若您为未成年人，请在监护人指导下使用，并在监护人同意后提交个人信息。\n\n' +
      '七、政策更新与联系我们\n' +
      '我们可能适时更新本政策，更新后将通过应用内提示告知。如您对本政策有任何疑问，请联系：' + this.contact + '。';
  }

  private agreementText(): string {
    return '知考用户协议\n\n' +
      '更新日期：2026 年 8 月\n' +
      '生效日期：2026 年 8 月\n\n' +
      '欢迎使用知考！本协议是您与我们之间就使用知考应用（以下简称"本应用"）所订立的协议。请您在使用前仔细阅读并充分理解本协议。\n\n' +
      '一、服务内容\n' +
      '本应用为公务员考试、事业单位考试等备考学习工具，提供公考常识与成语学习内容、练习、复习与学习统计功能。我们可能根据运营需要调整、增加或减少部分功能。\n\n' +
      '二、账号注册与使用\n' +
      '1. 您应提供真实、准确、完整的注册信息，并对账号下的所有行为负责。\n' +
      '2. 请妥善保管您的账号与密码，因您保管不善造成的损失由您自行承担。\n' +
      '3. 您也可以以游客身份使用本应用的部分功能，游客身份下产生的学习数据与游客标识绑定。\n\n' +
      '三、用户行为规范\n' +
      '您承诺遵守法律法规，不得利用本应用从事以下行为：\n' +
      '1. 发布、传播违法违规、虚假或侵权信息；\n' +
      '2. 使用自动化工具批量访问、抓取本应用内容；\n' +
      '3. 干扰、破坏本应用正常运营或侵害他人合法权益；\n' +
      '4. 其他违反法律法规或本协议约定的行为。\n\n' +
      '四、知识产权\n' +
      '本应用内的学习内容（含自建与授权内容）的知识产权归相应权利方所有，仅供您个人学习使用，未经许可不得复制、传播或用于商业用途。\n\n' +
      '五、免责声明\n' +
      '本应用内容仅供参考，不构成任何考试承诺或保证。因不可抗力、网络故障等原因导致的服务中断，我们不承担相应责任。\n\n' +
      '六、协议的变更与终止\n' +
      '我们可能适时更新本协议，更新后将在应用内提示。若您违反本协议，我们有权暂停或终止向您提供服务。\n\n' +
      '七、法律适用与争议解决\n' +
      '本协议的订立、履行与解释适用中华人民共和国法律。因本协议产生的争议，双方应友好协商解决；协商不成的，提交有管辖权的人民法院处理。\n\n' +
      '八、联系我们\n' +
      '如您对本协议有任何疑问，请联系：' + this.contact + '。';
  }
}
