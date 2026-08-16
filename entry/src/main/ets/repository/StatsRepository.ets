import { HttpClient } from '../service/HttpClient';
import { ApiResponse } from '../constants/HttpConstants';

/**
 * 统计仓库（T8.x）。
 */

/** overview 响应 */
export class StatsOverviewData {
  studyDays: number = 0;
  totalStudyMinutes: number = 0;
  knowledgeMastered: number = 0;
  idiomMastered: number = 0;
  totalAnswers: number = 0;
  correctAnswers: number = 0;
  accuracy: number = 0;
  streakDays: number = 0;
}

/** 趋势点 */
export class TrendPoint {
  date: string = '';
  studyMinutes: number = 0;
  answerCount: number = 0;
  accuracy: number = 0;
}

/** 学习记录项 */
export class StudyRecordItem {
  id: number = 0;
  recordType: number = 0;
  targetId: number = 0;
  durationSeconds: number = 0;
  createdAt: string = '';
}

/** 分页 */
export class PageData<T> {
  records: T[] = [];
  total: number = 0;
}

export class StatsRepository {

  static async overview(): Promise<ApiResponse<StatsOverviewData>> {
    return HttpClient.get<StatsOverviewData>('/stats/overview');
  }

  static async trend(days: number): Promise<ApiResponse<TrendPoint[]>> {
    return HttpClient.get<TrendPoint[]>(`/stats/trend?days=${days}`);
  }

  static async records(page: number, size: number): Promise<ApiResponse<PageData<StudyRecordItem>>> {
    return HttpClient.get<PageData<StudyRecordItem>>(`/record/list?page=${page}&size=${size}`);
  }
}
