import { notificationManager } from '@kit.NotificationKit';
import { PreferencesService } from './PreferencesService';

/**
 * 学习提醒通知（T9.3）。
 * 用户设定提醒时间，到点弹出通知，点击拉起 App。
 * V1.0 简化：提供通知发送能力与提醒时间偏好存储；
 * 定时触发由系统闹钟/后台任务在真机调试阶段完善（模拟器能力有限）。
 */
export class NotificationService {

  private static readonly KEY_REMIND_TIME: string = 'remind_time';
  private static readonly KEY_REMIND_ENABLED: string = 'remind_enabled';

  /** 请求通知权限 */
  static async requestPermission(): Promise<boolean> {
    try {
      const enabled = await notificationManager.isNotificationEnabled();
      if (!enabled) {
        await notificationManager.requestEnableNotification();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /** 发送学习提醒通知 */
  static async sendReminder(): Promise<void> {
    try {
      await notificationManager.publish({
        id: 1001,
        content: {
          notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: '知考学习提醒',
            text: '该学习啦！每天 10~20 分钟，坚持积累。'
          }
        }
      });
    } catch (e) {
      // 通知发送失败（无权限等），静默处理
    }
  }

  /** 设置提醒时间（HH:mm） */
  static async setRemindTime(time: string, enabled: boolean): Promise<void> {
    const pref = PreferencesService.getInstance();
    await pref.putString(NotificationService.KEY_REMIND_TIME, time);
    await pref.putBoolean(NotificationService.KEY_REMIND_ENABLED, enabled);
  }

  static async getRemindTime(): Promise<string> {
    return PreferencesService.getInstance().getString(NotificationService.KEY_REMIND_TIME, '20:00');
  }

  static async isRemindEnabled(): Promise<boolean> {
    return PreferencesService.getInstance().getBoolean(NotificationService.KEY_REMIND_ENABLED);
  }
}
