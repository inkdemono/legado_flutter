// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'music_playlist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MusicPlaylist _$MusicPlaylistFromJson(Map<String, dynamic> json) =>
    MusicPlaylist(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      coverPath: json['coverPath'] as String?,
      trackIds: (json['trackIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      isSystem: json['isSystem'] as bool? ?? false,
    );

Map<String, dynamic> _$MusicPlaylistToJson(MusicPlaylist instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'coverPath': instance.coverPath,
      'trackIds': instance.trackIds,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'isSystem': instance.isSystem,
    };
