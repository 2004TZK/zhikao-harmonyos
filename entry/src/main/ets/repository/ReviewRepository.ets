import { HttpClient } from '../service/HttpClient';
import { ApiResponse } from '../constants/HttpConstants';

/**
 * 复习仓库（T7.x）。
 */

/** 今日复习概览（契约 6.13 示例 4） */
export class ReviewTodayData {
  pendingTotal: number = 0;
  suggestedCount: number = 0;
  groups: ReviewGroups = new ReviewGroups();
}

export class ReviewGroups {
  forgetting: number = 0;
  normal: number = 0;
  wrongReinforce: number = 0;
}

/** 复习项 */
export class ReviewItem {
  targetType: number = 0;
  targetId: number = 0;
  reviewType: number = 0;
  reviewStage: number = 0;
  title: string = '';
  content: string = '';
}

/** 提交复习结果请求 */
export class SubmitReviewRequest {
  targetType: number = 0;
  targetId: number = 0;
  isCorrect: boolean = false;
}

export class ReviewRepository {

  /** 今日复习概览 */
  static async today(): Promise<ApiResponse<ReviewTodayData>> {
    return HttpClient.get<ReviewTodayData>('/review/today');
  }

  /** 开始复习会话 */
  static async createSession(): Promise<ApiResponse<ReviewItem[]>> {
    return HttpClient.post<ReviewItem[]>('/review/sessions', new Object());
  }

  /** 提交单项复习结果 */
  static async submitItem(targetType: number, targetId: number, isCorrect: boolean): Promise<ApiResponse<Object>> {
    const body = new SubmitReviewRequest();
    body.targetType = targetType;
    body.targetId = targetId;
    body.isCorrect = isCorrect;
    return HttpClient.post<Object>(`/review/sessions/1/items`, body);
  }
}
