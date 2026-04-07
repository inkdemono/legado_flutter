import 'package:equatable/equatable.dart';

/// 远程书籍模型
// ignore: must_be_immutable
class RemoteBook with EquatableMixin {
  final String filename;
  final String path;
  final int size;
  final int lastModify;
  final String contentType;
  bool isOnBookShelf;

  RemoteBook({
    required this.filename,
    required this.path,
    required this.size,
    required this.lastModify,
    this.contentType = 'folder',
    this.isOnBookShelf = false,
  });

  bool get isDir => contentType == 'folder';

  /// 判断是否为书籍文件
  bool get isBookFile {
    if (isDir) return false;
    final ext = filename.toLowerCase().split('.').last;
    return ['txt', 'epub', 'pdf', 'mobi', 'azw', 'azw3', 'fb2', 'zip', 'rar', '7z'].contains(ext);
  }

  @override
  List<Object?> get props => [
        filename,
        path,
        size,
        lastModify,
        contentType,
        isOnBookShelf,
      ];

  @override
  String toString() =>
      'RemoteBook(filename: $filename, path: $path, isDir: $isDir)';
}
