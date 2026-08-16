/**
 * 路由路径常量（T1.3）。
 * 契约来源：任务书 4.2 页面清单。
 *
 * <p>业务代码跳转一律使用 NavigationService + 本常量，
 * 禁止直接调用底层路由 API（任务书 2.2）。
 */
export class RouteConstants {
  /** 启动页 */
  static readonly SPLASH: string = 'SplashPage';
  /** 登录 */
  static readonly LOGIN: string = 'LoginPage';
  /** 注册 */
  static readonly REGISTER: string = 'RegisterPage';
  /** 协议展示 */
  static readonly AGREEMENT: string = 'AgreementPage';
  /** 主容器（TabBar） */
  static readonly MAIN: string = 'MainPage';
  /** 首页 */
  static readonly HOME: string = 'HomePage';
  /** 学习入口 */
  static readonly STUDY: string = 'StudyPage';
  /** 常识分类 */
  static readonly KNOWLEDGE_CATEGORY: string = 'KnowledgeCategoryPage';
  /** 常识列表 */
  static readonly KNOWLEDGE_LIST: string = 'KnowledgeListPage';
  /** 常识详情 */
  static readonly KNOWLEDGE_DETAIL: string = 'KnowledgeDetailPage';
  /** 成语分类 */
  static readonly IDIOM_CATEGORY: string = 'IdiomCategoryPage';
  /** 成语列表 */
  static readonly IDIOM_LIST: string = 'IdiomListPage';
  /** 成语详情 */
  static readonly IDIOM_DETAIL: string = 'IdiomDetailPage';
  /** 练习入口 */
  static readonly PRACTICE: string = 'PracticePage';
  /** 答题页 */
  static readonly ANSWER: string = 'AnswerPage';
  /** 练习结果 */
  static readonly ANSWER_RESULT: string = 'AnswerResultPage';
  /** 复习入口 */
  static readonly REVIEW: string = 'ReviewPage';
  /** 复习过程 */
  static readonly REVIEW_SESSION: string = 'ReviewSessionPage';
  /** 错题本 */
  static readonly WRONG_QUESTION: string = 'WrongQuestionPage';
  /** 我的收藏 */
  static readonly FAVORITE: string = 'FavoritePage';
  /** 学习记录 */
  static readonly STUDY_RECORD: string = 'StudyRecordPage';
  /** 学习统计 */
  static readonly STATS: string = 'StatsPage';
  /** 我的 */
  static readonly MINE: string = 'MinePage';
  /** 设置 */
  static readonly SETTINGS: string = 'SettingsPage';
}

/** 页面跳转参数 key 常量（与各页面入参约定一致） */
export class RouteParams {
  /** 常识知识点 id */
  static readonly KNOWLEDGE_ID: string = 'knowledgeId';
  /** 成语 id */
  static readonly IDIOM_ID: string = 'idiomId';
  /** 题目 id */
  static readonly QUESTION_ID: string = 'questionId';
  /** 练习场次 id */
  static readonly SESSION_ID: string = 'sessionId';
  /** 分类 id */
  static readonly CATEGORY_ID: string = 'categoryId';
}
