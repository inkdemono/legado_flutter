/// 存储接口抽象层
/// 
/// 用于统一不同平台的文件存储操作
/// 支持 Android、iOS 和 HarmonyOS
abstract class StorageInterface {
  /// 获取应用文档目录路径
  Future<String> getAppDocumentsPath();

  /// 获取应用缓存目录路径
  Future<String> getAppCachePath();

  /// 保存文件
  Future<void> saveFile(String path, List<int> data);

  /// 读取文件
  Future<List<int>> readFile(String path);

  /// 删除文件
  Future<bool> deleteFile(String path);

  /// 检查文件是否存在
  Future<bool> fileExists(String path);

  /// 创建目录
  Future<void> createDirectory(String path);

  /// 列出目录内容
  Future<List<String>> listDirectory(String path);

  /// 复制文件
  Future<void> copyFile(String sourcePath, String destPath);

  /// 移动文件
  Future<void> moveFile(String sourcePath, String destPath);

  /// 获取文件大小（字节）
  Future<int> getFileSize(String path);

  /// 获取文件最后修改时间
  Future<DateTime> getLastModified(String path);
}
