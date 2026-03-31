// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'music_track.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MusicTrack _$MusicTrackFromJson(Map<String, dynamic> json) => MusicTrack(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String?,
      album: json['album'] as String?,
      duration: (json['duration'] as num?)?.toInt(),
      filePath: json['filePath'] as String?,
      url: json['url'] as String?,
      coverPath: json['coverPath'] as String?,
      coverUrl: json['coverUrl'] as String?,
      lyricsPath: json['lyricsPath'] as String?,
      lyrics: json['lyrics'] as String?,
      isLocal: json['isLocal'] as bool? ?? false,
      fileSize: (json['fileSize'] as num?)?.toInt(),
      addedAt: DateTime.parse(json['addedAt'] as String),
      playCount: (json['playCount'] as num?)?.toInt() ?? 0,
      lastPlayedAt: json['lastPlayedAt'] == null
          ? null
          : DateTime.parse(json['lastPlayedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$MusicTrackToJson(MusicTrack instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'artist': instance.artist,
      'album': instance.album,
      'duration': instance.duration,
      'filePath': instance.filePath,
      'url': instance.url,
      'coverPath': instance.coverPath,
      'coverUrl': instance.coverUrl,
      'lyricsPath': instance.lyricsPath,
      'lyrics': instance.lyrics,
      'isLocal': instance.isLocal,
      'fileSize': instance.fileSize,
      'addedAt': instance.addedAt.toIso8601String(),
      'playCount': instance.playCount,
      'lastPlayedAt': instance.lastPlayedAt?.toIso8601String(),
      'metadata': instance.metadata,
    };
