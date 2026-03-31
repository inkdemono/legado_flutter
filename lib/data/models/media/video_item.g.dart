// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoItem _$VideoItemFromJson(Map<String, dynamic> json) => VideoItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      duration: (json['duration'] as num?)?.toInt(),
      filePath: json['filePath'] as String?,
      url: json['url'] as String?,
      thumbnailPath: json['thumbnailPath'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      isLocal: json['isLocal'] as bool? ?? false,
      fileSize: (json['fileSize'] as num?)?.toInt(),
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      addedAt: DateTime.parse(json['addedAt'] as String),
      watchProgress: (json['watchProgress'] as num?)?.toInt() ?? 0,
      lastWatchedAt: json['lastWatchedAt'] == null
          ? null
          : DateTime.parse(json['lastWatchedAt'] as String),
      playbackSpeed: (json['playbackSpeed'] as num?)?.toDouble() ?? 1.0,
    );

Map<String, dynamic> _$VideoItemToJson(VideoItem instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'duration': instance.duration,
      'filePath': instance.filePath,
      'url': instance.url,
      'thumbnailPath': instance.thumbnailPath,
      'thumbnailUrl': instance.thumbnailUrl,
      'isLocal': instance.isLocal,
      'fileSize': instance.fileSize,
      'width': instance.width,
      'height': instance.height,
      'addedAt': instance.addedAt.toIso8601String(),
      'watchProgress': instance.watchProgress,
      'lastWatchedAt': instance.lastWatchedAt?.toIso8601String(),
      'playbackSpeed': instance.playbackSpeed,
    };
