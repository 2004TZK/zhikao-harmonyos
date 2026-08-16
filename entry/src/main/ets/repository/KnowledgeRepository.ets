import { HttpClient } from '../service/HttpClient';
import { ApiResponse } from '../constants/HttpConstants';

/**
 * 常识仓库（T5.x）。
 * 聚合网络请求，页面经 ViewModel 调用（层职责约定 3.1）。
 */

/** 分类项 */
export class KnowledgeCategoryItem {
  id: number = 0;
  name: string = '';
  icon: string = '';
  sort: number = 0;
  knowledgeCount: number = 0;
  masteredCount: number = 0;
}

/** 知识点项 */
export class KnowledgeListItem {
  id: number = 0;
  title: string = '';
  categoryId: number = 0;
  summary: string = '';
  difficulty: number = 0;
  mastery: number = 0;
}

/** 分页响应 */
export class PageData<T> {
  records: T[] = [];
  total: number = 0;
  page: number = 0;
  size: number = 0;
}

export class KnowledgeRepository {

  /** 分类列表 */
  static async categories(): Promise<ApiResponse<KnowledgeCategoryItem[]>> {
    return HttpClient.get<KnowledgeCategoryItem[]>('/knowledge/categories');
  }

  /** 知识点列表（分页+搜索+分类过滤） */
  static async list(categoryId: number | undefined, keyword: string, mastery: number | undefined, page: number, size: number): Promise<ApiResponse<PageData<KnowledgeListItem>>> {
    let path = `/knowledge/list?page=${page}&size=${size}`;
    if (categoryId !== undefined && categoryId > 0) {
      path += `&categoryId=${categoryId}`;
    }
    if (keyword !== '') {
      path += `&keyword=${encodeURIComponent(keyword)}`;
    }
    if (mastery !== undefined && mastery > 0) {
      path += `&mastery=${mastery}`;
    }
    return HttpClient.get<PageData<KnowledgeListItem>>(path);
  }
}
