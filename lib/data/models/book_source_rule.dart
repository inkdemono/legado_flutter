import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

// part 'book_source_rule.g.dart'; // 运行 build_runner 后取消注释

@JsonSerializable()
// ignore: must_be_immutable
class SearchRule with EquatableMixin {
  @JsonKey(name: 'bookList')
  String? bookList;

  @JsonKey(name: 'name')
  String? name;

  @JsonKey(name: 'author')
  String? author;

  @JsonKey(name: 'kind')
  String? kind;

  @JsonKey(name: 'wordCount')
  String? wordCount;

  @JsonKey(name: 'lastChapter')
  String? lastChapter;

  @JsonKey(name: 'intro')
  String? intro;

  @JsonKey(name: 'coverUrl')
  String? coverUrl;

  @JsonKey(name: 'bookUrl')
  String? bookUrl;

  @JsonKey(name: 'checkKeyWord')
  String? checkKeyWord;

  SearchRule({
    this.bookList,
    this.name,
    this.author,
    this.kind,
    this.wordCount,
    this.lastChapter,
    this.intro,
    this.coverUrl,
    this.bookUrl,
    this.checkKeyWord,
  });

  factory SearchRule.fromJson(Map<String, dynamic> json) {
    return SearchRule(
      bookList: json['bookList'],
      name: json['name'],
      author: json['author'],
      kind: json['kind'],
      wordCount: json['wordCount'],
      lastChapter: json['lastChapter'],
      intro: json['intro'],
      coverUrl: json['coverUrl'],
      bookUrl: json['bookUrl'],
      checkKeyWord: json['checkKeyWord'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookList': bookList,
      'name': name,
      'author': author,
      'kind': kind,
      'wordCount': wordCount,
      'lastChapter': lastChapter,
      'intro': intro,
      'coverUrl': coverUrl,
      'bookUrl': bookUrl,
      'checkKeyWord': checkKeyWord,
    };
  }

  @override
  List<Object?> get props => [
        bookList,
        name,
        author,
        kind,
        wordCount,
        lastChapter,
        intro,
        coverUrl,
        bookUrl,
        checkKeyWord,
      ];

  @override
  String toString() => 'SearchRule(bookList: $bookList, bookUrl: $bookUrl)';
}

@JsonSerializable()
// ignore: must_be_immutable
class BookInfoRule with EquatableMixin {
  @JsonKey(name: 'init')
  String? init;

  @JsonKey(name: 'name')
  String? name;

  @JsonKey(name: 'author')
  String? author;

  @JsonKey(name: 'kind')
  String? kind;

  @JsonKey(name: 'wordCount')
  String? wordCount;

  @JsonKey(name: 'lastChapter')
  String? lastChapter;

  @JsonKey(name: 'intro')
  String? intro;

  @JsonKey(name: 'coverUrl')
  String? coverUrl;

  @JsonKey(name: 'tocUrl')
  String? tocUrl;

  @JsonKey(name: 'canReName')
  String? canReName;

  /// 书籍更新时间规则（官方对齐字段）
  /// 从详情页提取书籍最后更新时间，用于判断书籍是否有更新。
  @JsonKey(name: 'updateTime')
  String? updateTime;

  /// 下载直链规则（官方对齐字段）
  /// 用于直链下载类书源，提取可直接下载的文件地址列表。
  /// 多个 URL 以换行符分隔。
  @JsonKey(name: 'downloadUrls')
  String? downloadUrls;

  BookInfoRule({
    this.init,
    this.name,
    this.author,
    this.kind,
    this.wordCount,
    this.lastChapter,
    this.intro,
    this.coverUrl,
    this.tocUrl,
    this.canReName,
    this.updateTime,
    this.downloadUrls,
  });

  factory BookInfoRule.fromJson(Map<String, dynamic> json) {
    return BookInfoRule(
      init: json['init'],
      name: json['name'],
      author: json['author'],
      kind: json['kind'],
      wordCount: json['wordCount'],
      lastChapter: json['lastChapter'],
      intro: json['intro'],
      coverUrl: json['coverUrl'],
      tocUrl: json['tocUrl'],
      canReName: json['canReName'],
      updateTime: json['updateTime'],
      downloadUrls: json['downloadUrls'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'init': init,
      'name': name,
      'author': author,
      'kind': kind,
      'wordCount': wordCount,
      'lastChapter': lastChapter,
      'intro': intro,
      'coverUrl': coverUrl,
      'tocUrl': tocUrl,
      'canReName': canReName,
      'updateTime': updateTime,
      'downloadUrls': downloadUrls,
    };
  }

  @override
  List<Object?> get props => [
        init,
        name,
        author,
        kind,
        wordCount,
        lastChapter,
        intro,
        coverUrl,
        tocUrl,
        canReName,
        updateTime,
        downloadUrls,
      ];

  @override
  String toString() => 'BookInfoRule(name: $name, tocUrl: $tocUrl)';
}

@JsonSerializable()
// ignore: must_be_immutable
class TocRule with EquatableMixin {
  @JsonKey(name: 'preUpdateJs')
  String? preUpdateJs; // 解析目录前执行的JavaScript代码（参考项目支持）

  @JsonKey(name: 'chapterList')
  String? chapterList;

  @JsonKey(name: 'chapterName')
  String? chapterName;

  @JsonKey(name: 'chapterUrl')
  String? chapterUrl;

  @JsonKey(name: 'isVip')
  String? isVip;

  @JsonKey(name: 'isVolume')
  String? isVolume; // 卷名规则（参考项目支持）

  @JsonKey(name: 'updateTime')
  String? updateTime;

  @JsonKey(name: 'nextTocUrl')
  String? nextTocUrl;

  @JsonKey(name: 'formatJs')
  String? formatJs; // 格式化章节标题的JavaScript代码（参考项目支持）

  /// 章节时长规则（音视频目录专用）
  /// 从目录列表中提取每集/每曲的播放时长。
  /// 提取结果可以是：
  ///   - 秒数字符串，如 "1800"（30分钟）
  ///   - 时间格式字符串，如 "00:30:00" 或 "30:00"（解析时统一转换为秒）
  /// 解析后存入 BookChapter.duration（单位：秒），供播放器展示进度条总时长。
  @JsonKey(name: 'duration')
  String? duration;

  TocRule({
    this.preUpdateJs,
    this.chapterList,
    this.chapterName,
    this.chapterUrl,
    this.isVip,
    this.isVolume,
    this.updateTime,
    this.nextTocUrl,
    this.formatJs,
    this.duration,
  });

  factory TocRule.fromJson(Map<String, dynamic> json) {
    return TocRule(
      preUpdateJs: json['preUpdateJs'],
      chapterList: json['chapterList'],
      chapterName: json['chapterName'],
      chapterUrl: json['chapterUrl'],
      isVip: json['isVip'],
      isVolume: json['isVolume'],
      updateTime: json['updateTime'],
      nextTocUrl: json['nextTocUrl'],
      formatJs: json['formatJs'],
      duration: json['duration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'preUpdateJs': preUpdateJs,
      'chapterList': chapterList,
      'chapterName': chapterName,
      'chapterUrl': chapterUrl,
      'isVip': isVip,
      'isVolume': isVolume,
      'updateTime': updateTime,
      'nextTocUrl': nextTocUrl,
      'formatJs': formatJs,
      'duration': duration,
    };
  }

  @override
  List<Object?> get props => [
        preUpdateJs,
        chapterList,
        chapterName,
        chapterUrl,
        isVip,
        isVolume,
        updateTime,
        nextTocUrl,
        formatJs,
        duration,
      ];

  @override
  String toString() => 'TocRule(chapterList: $chapterList, next: $nextTocUrl)';
}

@JsonSerializable()
// ignore: must_be_immutable
class ContentRule with EquatableMixin {
  @JsonKey(name: 'content')
  String? content;

  /// 正文内标题规则（官方对齐字段）
  /// 当网站不单独显示章节标题、标题混在正文页时使用。
  /// 提取结果会作为章节标题覆盖目录规则抓取的标题。
  @JsonKey(name: 'title')
  String? title;

  /// 漫画章节图片URL列表规则（可选）
  /// 优先于 [content] 提取图片列表，支持 CSS/XPath/JSONPath/JS/## 语法
  @JsonKey(name: 'images')
  String? images;

  @JsonKey(name: 'nextContentUrl')
  String? nextContentUrl;

  @JsonKey(name: 'webJs')
  String? webJs;

  @JsonKey(name: 'sourceRegex')
  String? sourceRegex;

  @JsonKey(name: 'replaceRegex')
  String? replaceRegex;

  @JsonKey(name: 'imageStyle')
  String? imageStyle;

  @JsonKey(name: 'imageDecode')
  String? imageDecode; // 图片解密JS

  /// 付费操作规则（官方对齐字段）
  /// 用于自动完成付费章节的解锁操作。
  /// 可以是纯 JS 代码，也可以是包含 {{js}} 的 URL。
  /// JS 执行完毕后，重新请求章节内容。
  @JsonKey(name: 'payAction')
  String? payAction;

  // ── Phase 2：音视频专属规则字段 ─────────────────────────────────────────

  /// 音频 URL 规则（bookSourceType=1 时使用）
  /// 优先于 [content] + [sourceRegex] 机制，直接从页面提取音频直链。
  /// 支持 CSS/XPath/JSONPath/JS/## 语法。
  /// 示例：`$.data.url`（JSON接口）、`class.audio-src@src`（HTML标签属性）
  @JsonKey(name: 'audioUrl')
  String? audioUrl;

  /// 视频 URL 规则（bookSourceType=2 时使用）
  /// 优先于 [content] + [sourceRegex] 机制，直接从页面提取视频直链或播放列表。
  /// 支持 CSS/XPath/JSONPath/JS/## 语法。
  @JsonKey(name: 'videoUrl')
  String? videoUrl;

  /// 歌词/字幕 URL 规则（音频源可选）
  /// 提取 .lrc / .srt 等歌词或字幕文件的 URL，播放器同步展示。
  @JsonKey(name: 'lyricsUrl')
  String? lyricsUrl;

  /// 外挂字幕 URL 规则（视频源可选）
  /// 提取 .srt / .ass / .vtt 等字幕文件的 URL。
  @JsonKey(name: 'subtitleUrl')
  String? subtitleUrl;

  /// 多码率/多清晰度列表规则（音视频源可选）
  /// 提取结果为 JSON 数组，每项包含 label（清晰度标签）和 url（播放地址）。
  /// 示例返回：`[{"label":"高清","url":"https://..."},{"label":"标清","url":"https://..."}]`
  @JsonKey(name: 'qualityList')
  String? qualityList;

  ContentRule({
    this.content,
    this.title,
    this.images,
    this.nextContentUrl,
    this.webJs,
    this.sourceRegex,
    this.replaceRegex,
    this.imageStyle,
    this.imageDecode,
    this.payAction,
    this.audioUrl,
    this.videoUrl,
    this.lyricsUrl,
    this.subtitleUrl,
    this.qualityList,
  });

  factory ContentRule.fromJson(Map<String, dynamic> json) {
    return ContentRule(
      content: json['content'],
      title: json['title'],
      images: json['images'],
      nextContentUrl: json['nextContentUrl'],
      webJs: json['webJs'],
      sourceRegex: json['sourceRegex'],
      replaceRegex: json['replaceRegex'],
      imageStyle: json['imageStyle'],
      imageDecode: json['imageDecode'],
      payAction: json['payAction'],
      audioUrl: json['audioUrl'],
      videoUrl: json['videoUrl'],
      lyricsUrl: json['lyricsUrl'],
      subtitleUrl: json['subtitleUrl'],
      qualityList: json['qualityList'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'title': title,
      'images': images,
      'nextContentUrl': nextContentUrl,
      'webJs': webJs,
      'sourceRegex': sourceRegex,
      'replaceRegex': replaceRegex,
      'imageStyle': imageStyle,
      'imageDecode': imageDecode,
      'payAction': payAction,
      'audioUrl': audioUrl,
      'videoUrl': videoUrl,
      'lyricsUrl': lyricsUrl,
      'subtitleUrl': subtitleUrl,
      'qualityList': qualityList,
    };
  }

  @override
  List<Object?> get props => [
        content,
        title,
        images,
        nextContentUrl,
        webJs,
        sourceRegex,
        replaceRegex,
        imageStyle,
        imageDecode,
        payAction,
        audioUrl,
        videoUrl,
        lyricsUrl,
        subtitleUrl,
        qualityList,
      ];

  @override
  String toString() =>
      'ContentRule(content: $content, nextContentUrl: $nextContentUrl)';
}

@JsonSerializable()
// ignore: must_be_immutable
class ExploreRule with EquatableMixin {
  @JsonKey(name: 'bookList')
  String? bookList;

  @JsonKey(name: 'name')
  String? name;

  @JsonKey(name: 'author')
  String? author;

  @JsonKey(name: 'kind')
  String? kind;

  @JsonKey(name: 'wordCount')
  String? wordCount;

  @JsonKey(name: 'lastChapter')
  String? lastChapter;

  @JsonKey(name: 'intro')
  String? intro;

  @JsonKey(name: 'coverUrl')
  String? coverUrl;

  @JsonKey(name: 'bookUrl')
  String? bookUrl;

  ExploreRule({
    this.bookList,
    this.name,
    this.author,
    this.kind,
    this.wordCount,
    this.lastChapter,
    this.intro,
    this.coverUrl,
    this.bookUrl,
  });

  factory ExploreRule.fromJson(Map<String, dynamic> json) {
    return ExploreRule(
      bookList: json['bookList'],
      name: json['name'],
      author: json['author'],
      kind: json['kind'],
      wordCount: json['wordCount'],
      lastChapter: json['lastChapter'],
      intro: json['intro'],
      coverUrl: json['coverUrl'],
      bookUrl: json['bookUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookList': bookList,
      'name': name,
      'author': author,
      'kind': kind,
      'wordCount': wordCount,
      'lastChapter': lastChapter,
      'intro': intro,
      'coverUrl': coverUrl,
      'bookUrl': bookUrl,
    };
  }

  @override
  List<Object?> get props => [
        bookList,
        name,
        author,
        kind,
        wordCount,
        lastChapter,
        intro,
        coverUrl,
        bookUrl,
      ];

  @override
  String toString() => 'ExploreRule(bookList: $bookList, bookUrl: $bookUrl)';
}
