/**
 * 页面跳转参数对象（T4.5）。
 * ArkTS 禁止无类型对象字面量，路由参数统一使用本类。
 */
export class RouteParamObject {
  knowledgeId: number = 0;
  idiomId: number = 0;
  questionId: number = 0;
  sessionId: number = 0;
  categoryId: number = 0;
  targetType: number = 0;
  targetId: number = 0;
}
