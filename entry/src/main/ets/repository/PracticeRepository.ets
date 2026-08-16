import { HttpClient } from '../service/HttpClient';
import { ApiResponse } from '../constants/HttpConstants';

/**
 * 练习仓库（T6.x）。
 */

/** 选项 */
export class PracticeOption {
  optionId: number = 0;
  label: string = '';
  content: string = '';
}

/** 题目（不含答案，契约 6.13 示例 2） */
export class PracticeQuestion {
  questionId: number = 0;
  content: string = '';
  knowledgeId: number = 0;
  idiomId: number = 0;
  options: PracticeOption[] = [];
}

/** 组卷响应 */
export class PracticeSessionData {
  sessionId: number = 0;
  totalCount: number = 0;
  questions: PracticeQuestion[] = [];
}

/** 判分响应（契约 6.13 示例 3） */
export class AnswerResultData {
  correct: boolean = false;
  correctOptionLabel: string = '';
  analysis: string = '';
  knowledgeId: number = 0;
  idiomId: number = 0;
}

/** 场次结果 */
export class SessionResultData {
  sessionId: number = 0;
  totalCount: number = 0;
  correctCount: number = 0;
  wrongCount: number = 0;
  accuracy: number = 0;
  wrongQuestions: WrongQuestionSummary[] = [];
}

/** 错题摘要 */
export class WrongQuestionSummary {
  questionId: number = 0;
  content: string = '';
  knowledgeId: number = 0;
  idiomId: number = 0;
}

/** 错题本项 */
export class WrongItem {
  wrongId: number = 0;
  questionId: number = 0;
  content: string = '';
  analysis: string = '';
  knowledgeId: number = 0;
  idiomId: number = 0;
  wrongCount: number = 0;
  lastWrongTime: string = '';
}

/** 组卷请求 */
export class CreateSessionRequest {
  type: number = 1;
  refType: number = 0;
  refId: number = 0;
  count: number = 0;
}

/** 提交答案请求 */
export class SubmitAnswerRequest {
  questionId: number = 0;
  optionId: number = 0;
}

export class PracticeRepository {

  /** 创建场次 */
  static async createSession(type: number, refType: number, refId: number, count: number): Promise<ApiResponse<PracticeSessionData>> {
    const body = new CreateSessionRequest();
    body.type = type;
    body.refType = refType;
    body.refId = refId;
    body.count = count;
    return HttpClient.post<PracticeSessionData>('/practice/sessions', body);
  }

  /** 提交答案 */
  static async submitAnswer(sessionId: number, questionId: number, optionId: number): Promise<ApiResponse<AnswerResultData>> {
    const body = new SubmitAnswerRequest();
    body.questionId = questionId;
    body.optionId = optionId;
    return HttpClient.post<AnswerResultData>(`/practice/sessions/${sessionId}/answers`, body);
  }

  /** 场次结果 */
  static async sessionResult(sessionId: number): Promise<ApiResponse<SessionResultData>> {
    return HttpClient.get<SessionResultData>(`/practice/sessions/${sessionId}/result`);
  }

  /** 错题重练 */
  static async wrongPractice(count: number): Promise<ApiResponse<PracticeSessionData>> {
    return HttpClient.post<PracticeSessionData>(`/practice/wrong-practice?count=${count}`, new Object());
  }
}
