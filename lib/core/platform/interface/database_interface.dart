/// 数据库接口抽象层
/// 
/// 用于统一不同平台的数据库操作
/// 支持 Android、iOS 和 HarmonyOS
abstract class DatabaseInterface {
  /// 打开数据库
  Future<void> openDatabase(String path);

  /// 执行 SQL 查询
  Future<List<Map<String, dynamic>>> query(
    String sql, [
    List<dynamic>? arguments,
  ]);

  /// 执行插入操作
  Future<int> insert(
    String table,
    Map<String, dynamic> values, {
    String? nullColumnHack,
  });

  /// 执行更新操作
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<dynamic>? whereArgs,
  });

  /// 执行删除操作
  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  });

  /// 执行原始 SQL
  Future<void> execute(String sql, [List<dynamic>? arguments]);

  /// 执行事务
  Future<T> transaction<T>(Future<T> Function() action);

  /// 关闭数据库
  Future<void> close();

  /// 检查表是否存在
  Future<bool> tableExists(String tableName);

  /// 获取数据库版本
  Future<int> getVersion();

  /// 设置数据库版本
  Future<void> setVersion(int version);
}
