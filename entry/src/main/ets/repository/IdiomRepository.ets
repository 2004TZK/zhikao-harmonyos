import { HttpClient } from '../service/HttpClient';
import { ApiResponse } from '../constants/HttpConstants';

/**
 * 成语仓库（T5.x）。
 */

/** 分类项 */
export class IdiomCategoryItem {
  id: number = 0;
  name: string = '';
  sort: number = 0;
}

/** 成语项 */
export class IdiomListItem {
  id: number = 0;
  word: string = '';
  pinyin: string = '';
  explanation: string = '';
  difficulty: number = 0;
}

/** 分页响应 */
export class PageData<T> {
  records: T[] = [];
  total: number = 0;
  page: number = 0;
  size: number = 0;
}

export class IdiomRepository {

  static async categories(): Promise<ApiResponse<IdiomCategoryItem[]>> {
    return HttpClient.get<IdiomCategoryItem[]>('/idiom/categories');
  }

  static async list(categoryId: number | undefined, keyword: string, page: number, size: number): Promise<ApiResponse<PageData<IdiomListItem>>> {
    let path = `/idiom/list?page=${page}&size=${size}`;
    if (categoryId !== undefined && categoryId > 0) {
      path += `&categoryId=${categoryId}`;
    }
    if (keyword !== '') {
      path += `&keyword=${encodeURIComponent(keyword)}`;
    }
    return HttpClient.get<PageData<IdiomListItem>>(path);
  }
}
