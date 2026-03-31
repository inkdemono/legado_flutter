import 'flex_child_style.dart';

/// 发现分类模型
/// 参考项目：ExploreKind.kt
class ExploreKind {
  final String title;
  final String? url;
  final FlexChildStyle? style;

  ExploreKind({
    required this.title,
    this.url,
    this.style,
  });

  factory ExploreKind.fromJson(Map<String, dynamic> json) {
    return ExploreKind(
      title: json['title'] ?? '',
      url: json['url'],
      style: json['style'] != null
          ? FlexChildStyle.fromJson(json['style'] as Map<String, dynamic>)
          : null,
    );
  }

  /// 获取样式（如果没有则返回默认样式）
  FlexChildStyle getStyle() {
    return style ?? FlexChildStyle.defaultStyle;
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
      'style': style?.toJson(),
    };
  }
}
