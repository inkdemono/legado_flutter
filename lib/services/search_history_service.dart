/// 搜索历史服务（已迁移到SearchKeywordService）
/// 为了保持向后兼容，保留此服务作为SearchKeywordService的包装
library;

import 'search_keyword_service.dart';
import 'package:legado_flutter/providers/service_registry.dart';

/// 搜索历史服务
@Deprecated('请使用 SearchKeywordService 代替')
class SearchHistoryService {
  static final SearchHistoryService instance = SearchHistoryService._init();
  SearchHistoryService._init();

  /// 获取搜索历史
  Future<List<String>> getSearchHistory() async {
    return await readService(AppServices.searchKeywordService).getSearchHistory();
  }

  /// 保存搜索关键词
  Future<void> saveSearchKeyword(String keyword) async {
    await readService(AppServices.searchKeywordService).saveSearchKeyword(keyword);
  }

  /// 删除搜索历史
  Future<void> deleteSearchHistory(String keyword) async {
    await readService(AppServices.searchKeywordService).deleteSearchHistory(keyword);
  }

  /// 清空搜索历史
  Future<void> clearSearchHistory() async {
    await readService(AppServices.searchKeywordService).clearSearchHistory();
  }
}
