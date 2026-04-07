import 'package:equatable/equatable.dart';

/// RSS阅读记录数据模型
/// 参考项目：io.legado.app.data.entities.RssReadRecord
// ignore: must_be_immutable
class RssReadRecord with EquatableMixin {
  /// 记录标识（主键，格式：origin_link）
  final String record;

  /// 标题
  String? title;

  /// 阅读时间
  int? readTime;

  /// 是否已读
  bool read;

  RssReadRecord({
    required this.record,
    this.title,
    this.readTime,
    this.read = true,
  });

  /// 从JSON创建
  factory RssReadRecord.fromJson(Map<String, dynamic> json) {
    return RssReadRecord(
      record: json['record'] as String? ?? '',
      title: json['title'] as String?,
      readTime: json['readTime'] as int?,
      read: json['read'] == 1 || json['read'] == true,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'record': record,
      'title': title,
      'readTime': readTime,
      'read': read ? 1 : 0,
    };
  }

  /// 从RSS文章创建记录标识
  static String createRecord(String origin, String link) {
    return '$origin|$link';
  }

  /// 从记录标识解析origin和link
  static Map<String, String> parseRecord(String record) {
    final parts = record.split('|');
    if (parts.length >= 2) {
      return {
        'origin': parts[0],
        'link': parts.sublist(1).join('|'),
      };
    }
    return {'origin': '', 'link': record};
  }

  @override
  List<Object?> get props => [record];

  @override
  String toString() => 'RssReadRecord(record: $record, read: $read)';
}
