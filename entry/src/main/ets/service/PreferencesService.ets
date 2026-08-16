import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

/**
 * Preferences 本地存储封装（任务书 2.2：V1.0 仅使用 Preferences）。
 * 存储内容：Token、用户信息、主题、设置、最近访问、少量缓存、游客 UUID。
 */
export class PreferencesService {
  private static instance: PreferencesService = new PreferencesService();
  private pref: preferences.Preferences | undefined = undefined;
  private readyPromise: Promise<void> | undefined = undefined;
  private readonly STORE_NAME: string = 'zhikao_preferences';

  private constructor() {
  }

  static getInstance(): PreferencesService {
    return PreferencesService.instance;
  }

  /** 初始化（在 EntryAbility.onCreate 调用一次） */
  init(context: common.UIAbilityContext): Promise<void> {
    if (this.readyPromise === undefined) {
      this.readyPromise = preferences.getPreferences(context, this.STORE_NAME).then((p) => {
        this.pref = p;
      });
    }
    return this.readyPromise;
  }

  /** 等待初始化完成（页面启动流程使用，避免竞态） */
  async whenReady(): Promise<void> {
    if (this.pref !== undefined) {
      return;
    }
    // 等待 init 的 promise（若尚未调用 init，则抛错由调用方处理）
    if (this.readyPromise !== undefined) {
      await this.readyPromise;
    }
  }

  async getString(key: string, defaultValue: string = ''): Promise<string> {
    const value = await this.pref?.get(key, defaultValue);
    return (value as string) ?? defaultValue;
  }

  async putString(key: string, value: string): Promise<void> {
    await this.pref?.put(key, value);
    await this.pref?.flush();
  }

  async getNumber(key: string, defaultValue: number = 0): Promise<number> {
    const value = await this.pref?.get(key, defaultValue);
    return (value as number) ?? defaultValue;
  }

  async putNumber(key: string, value: number): Promise<void> {
    await this.pref?.put(key, value);
    await this.pref?.flush();
  }

  async getBoolean(key: string, defaultValue: boolean = false): Promise<boolean> {
    const value = await this.pref?.get(key, defaultValue);
    return (value as boolean) ?? defaultValue;
  }

  async putBoolean(key: string, value: boolean): Promise<void> {
    await this.pref?.put(key, value);
    await this.pref?.flush();
  }

  async remove(key: string): Promise<void> {
    await this.pref?.delete(key);
    await this.pref?.flush();
  }
}
