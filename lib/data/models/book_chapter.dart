import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

// part 'book_chapter.g.dart'; // 运行 build_runner 后取消注释

@JsonSerializable()
// ignore: must_be_immutable
class BookChapter with EquatableMixin {
  /// 章节地址
  @JsonKey(name: 'url')
  final String url;

  /// 章节标题
  @JsonKey(name: 'title')
  String title;

  /// 是否是卷名
  @JsonKey(name: 'isVolume')
  bool isVolume;

  /// 用来拼接相对url
  @JsonKey(name: 'baseUrl')
  String baseUrl;

  /// 书籍地址
  @JsonKey(name: 'bookUrl')
  String bookUrl;

  /// 章节序号
  @JsonKey(name: 'index')
  int index;

  /// 是否VIP
  @JsonKey(name: 'isVip')
  bool isVip;

  /// 是否已购买
  @JsonKey(name: 'isPay')
  bool isPay;

  /// 音频真实URL
  @JsonKey(name: 'resourceUrl')
  String? resourceUrl;

  /// 更新时间或其他章节附加信息
  @JsonKey(name: 'tag')
  String? tag;

  /// 本章节字数
  @JsonKey(name: 'wordCount')
  String? wordCount;

  /// 章节起始位置
  @JsonKey(name: 'start')
  int? start;

  /// 章节终止位置
  @JsonKey(name: 'end')
  int? end;

  /// EPUB书籍当前章节的fragmentId
  @JsonKey(name: 'startFragmentId')
  String? startFragmentId;

  /// EPUB书籍下一章节的fragmentId
  @JsonKey(name: 'endFragmentId')
  String? endFragmentId;

  /// 变量
  @JsonKey(name: 'variable')
  String? variable;

  /// 章节内容文件的本地路径 (相对路径)
  /// 格式: "bookFolderName/00001-abc.txt"
  /// 用于分文件存储策略,提升长章节读取性能
  @JsonKey(name: 'localPath')
  String? localPath;

  // ── Phase 3：音视频章节扩展字段 ──────────────────────────────────────────

  /// 章节时长（单位：秒）
  /// 从 TocRule.duration 规则解析，支持 "HH:MM:SS"、"MM:SS"、纯秒数字符串三种格式。
  /// 用于播放器进度条总时长展示，存入数据库便于离线展示。
  @JsonKey(name: 'duration')
  int? duration;

  /// 已解析的歌词/字幕文件 URL（音频源，运行时写入）
  /// 对应 ContentRule.lyricsUrl 规则解析结果（.lrc / .srt 等格式）。
  /// 播放器根据此 URL 加载歌词并同步滚动展示。
  @JsonKey(name: 'lyricsUrl')
  String? lyricsUrl;

  /// 已解析的外挂字幕文件 URL（视频源，运行时写入）
  /// 对应 ContentRule.subtitleUrl 规则解析结果（.srt / .ass / .vtt 等格式）。
  @JsonKey(name: 'subtitleUrl')
  String? subtitleUrl;

  /// 多码率/多清晰度选项（JSON 字符串，运行时写入）
  /// 对应 ContentRule.qualityList 规则解析结果。
  /// 格式：`[{"label":"高清","url":"https://..."},{"label":"标清","url":"..."}]`
  /// 播放器解析此 JSON 后向用户提供清晰度切换菜单。
  @JsonKey(name: 'qualityOptions')
  String? qualityOptions;

  BookChapter({
    required this.url,
    this.title = '',
    this.isVolume = false,
    this.baseUrl = '',
    required this.bookUrl,
    this.index = 0,
    this.isVip = false,
    this.isPay = false,
    this.resourceUrl,
    this.tag,
    this.wordCount,
    this.start,
    this.end,
    this.startFragmentId,
    this.endFragmentId,
    this.variable,
    this.localPath,
    this.duration,
    this.lyricsUrl,
    this.subtitleUrl,
    this.qualityOptions,
  });

  factory BookChapter.fromJson(Map<String, dynamic> json) {
    return BookChapter(
      url: json['url'] ?? '',
      title: json['title'] ?? '',
      isVolume: json['isVolume'] ?? false,
      baseUrl: json['baseUrl'] ?? '',
      bookUrl: json['bookUrl'] ?? '',
      index: json['index'] ?? 0,
      isVip: json['isVip'] ?? false,
      isPay: json['isPay'] ?? false,
      resourceUrl: json['resourceUrl'],
      tag: json['tag'],
      wordCount: json['wordCount'],
      start: json['start'],
      end: json['end'],
      startFragmentId: json['startFragmentId'],
      endFragmentId: json['endFragmentId'],
      variable: json['variable'],
      localPath: json['localPath'],
      duration: json['duration'],
      lyricsUrl: json['lyricsUrl'],
      subtitleUrl: json['subtitleUrl'],
      qualityOptions: json['qualityOptions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'title': title,
      'isVolume': isVolume,
      'baseUrl': baseUrl,
      'bookUrl': bookUrl,
      'index': index,
      'isVip': isVip,
      'isPay': isPay,
      'resourceUrl': resourceUrl,
      'tag': tag,
      'wordCount': wordCount,
      'start': start,
      'end': end,
      'startFragmentId': startFragmentId,
      'endFragmentId': endFragmentId,
      'variable': variable,
      'localPath': localPath,
      'duration': duration,
      'lyricsUrl': lyricsUrl,
      'subtitleUrl': subtitleUrl,
      'qualityOptions': qualityOptions,
    };
  }

  BookChapter copyWith({
    String? url,
    String? title,
    bool? isVolume,
    String? baseUrl,
    String? bookUrl,
    int? index,
    bool? isVip,
    bool? isPay,
    String? resourceUrl,
    String? tag,
    String? wordCount,
    int? start,
    int? end,
    String? startFragmentId,
    String? endFragmentId,
    String? variable,
    String? localPath,
    int? duration,
    String? lyricsUrl,
    String? subtitleUrl,
    String? qualityOptions,
  }) {
    return BookChapter(
      url: url ?? this.url,
      title: title ?? this.title,
      isVolume: isVolume ?? this.isVolume,
      baseUrl: baseUrl ?? this.baseUrl,
      bookUrl: bookUrl ?? this.bookUrl,
      index: index ?? this.index,
      isVip: isVip ?? this.isVip,
      isPay: isPay ?? this.isPay,
      resourceUrl: resourceUrl ?? this.resourceUrl,
      tag: tag ?? this.tag,
      wordCount: wordCount ?? this.wordCount,
      start: start ?? this.start,
      end: end ?? this.end,
      startFragmentId: startFragmentId ?? this.startFragmentId,
      endFragmentId: endFragmentId ?? this.endFragmentId,
      variable: variable ?? this.variable,
      localPath: localPath ?? this.localPath,
      duration: duration ?? this.duration,
      lyricsUrl: lyricsUrl ?? this.lyricsUrl,
      subtitleUrl: subtitleUrl ?? this.subtitleUrl,
      qualityOptions: qualityOptions ?? this.qualityOptions,
    );
  }

  /// 获取章节的唯一标识符（参考项目：BookChapter.primaryStr）
  /// 返回 bookUrl + url 的组合，用于作为缓存的 key
  String primaryStr() {
    return bookUrl + url;
  }

  @override
  List<Object?> get props => [url];

  @override
  String toString() {
    return 'BookChapter(title: $title, url: $url, index: $index)';
  }
}
