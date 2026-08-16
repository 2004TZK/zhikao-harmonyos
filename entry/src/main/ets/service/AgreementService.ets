import { PreferencesService } from './PreferencesService';

/**
 * 首次启动隐私同意服务（T4.2）。
 * 任务书 8：首次启动展示隐私政策+用户协议弹窗，用户同意后才可初始化网络与数据采集能力。
 */
export class AgreementService {
  private static readonly KEY_AGREED: string = 'agreement_accepted';

  /** 是否已同意（首次启动为 false） */
  static async hasAgreed(): Promise<boolean> {
    return PreferencesService.getInstance().getBoolean(AgreementService.KEY_AGREED);
  }

  /** 记录同意（同意后放行网络初始化） */
  static async setAgreed(): Promise<void> {
    await PreferencesService.getInstance().putBoolean(AgreementService.KEY_AGREED, true);
  }
}
