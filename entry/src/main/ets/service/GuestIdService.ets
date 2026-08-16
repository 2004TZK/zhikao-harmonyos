import { PreferencesService } from './PreferencesService';

/**
 * 游客身份服务（T1.6/T4.3）。
 * 职责（任务书 6.1 游客约定）：首次启动生成随机 UUID 并持久化到 Preferences，
 * 重启后保持不变；卸载后自然失效（不做跨设备找回）。
 */
export class GuestIdService {
  private static readonly KEY_GUEST_UUID: string = 'guest_uuid';

  /** 获取游客 UUID；不存在则生成并持久化（幂等，重复调用返回同一值） */
  static async getOrCreateGuestUuid(): Promise<string> {
    const pref = PreferencesService.getInstance();
    const existing = await pref.getString(GuestIdService.KEY_GUEST_UUID);
    if (existing !== '') {
      return existing;
    }
    const uuid = GuestIdService.generateUuid();
    await pref.putString(GuestIdService.KEY_GUEST_UUID, uuid);
    return uuid;
  }

  /** 清除游客 UUID（账号注销/游客身份失效时调用） */
  static async clear(): Promise<void> {
    await PreferencesService.getInstance().remove(GuestIdService.KEY_GUEST_UUID);
  }

  /** 生成随机 UUID v4（标准随机数 + 时间戳，不采集任何硬件指纹） */
  private static generateUuid(): string {
    // 生成 16 字节随机数（基于 Math.random，避免外部模块依赖）
    const bytes: number[] = [];
    for (let i = 0; i < 16; i++) {
      bytes.push(Math.floor(Math.random() * 256));
    }
    // v4 版本位与变体位
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    const hex: string[] = [];
    for (let i = 0; i < 16; i++) {
      hex.push(bytes[i].toString(16).padStart(2, '0'));
    }
    return `${hex[0]}${hex[1]}${hex[2]}${hex[3]}-${hex[4]}${hex[5]}-${hex[6]}${hex[7]}-${hex[8]}${hex[9]}-${hex[10]}${hex[11]}${hex[12]}${hex[13]}${hex[14]}${hex[15]}`;
  }
}
