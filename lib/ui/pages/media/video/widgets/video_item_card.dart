import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../data/models/media/video_item.dart';
import '../../../../widgets/home/home_shell.dart';

/// 视频项卡片组件
class VideoItemCard extends StatelessWidget {
  final VideoItem video;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isHorizontal;

  const VideoItemCard({
    super.key,
    required this.video,
    this.onTap,
    this.onLongPress,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isHorizontal) {
      return _buildHorizontalCard(context);
    }
    return _buildGridCard(context);
  }

  Widget _buildGridCard(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(
            color: HomePalette.card(context),
            borderRadius: BorderRadius.circular(22),
            boxShadow: HomePalette.cardShadow(context),
            border: Border.all(color: HomePalette.lineColor(context)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 10,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildThumbnail(context),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.16),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    if (video.isLocal)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: _buildBadge(
                          label: '本地',
                          backgroundColor: Colors.white.withValues(alpha: 0.18),
                          textColor: Colors.white,
                        ),
                      ),
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: _buildBadge(
                        label: video.formattedDuration,
                        backgroundColor: Colors.black.withValues(alpha: 0.52),
                        textColor: Colors.white,
                        radius: 8,
                      ),
                    ),
                    if (video.watchProgress > 0)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: SizedBox(
                          height: 3,
                          child: LinearProgressIndicator(
                            value: video.watchProgressPercent,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.18),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF38BDF8),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.45,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2329),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _buildGridMeta(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF86909C),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalCard(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: HomePalette.card(context),
            borderRadius: BorderRadius.circular(22),
            boxShadow: HomePalette.cardShadow(context),
            border: Border.all(color: HomePalette.lineColor(context)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 120,
                  height: 72,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildThumbnail(context),
                      Center(
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 6,
                        bottom: 6,
                        child: _buildBadge(
                          label: video.formattedDuration,
                          backgroundColor: Colors.black.withValues(alpha: 0.52),
                          textColor: Colors.white,
                          radius: 8,
                        ),
                      ),
                      if (video.watchProgress > 0)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: SizedBox(
                            height: 3,
                            child: LinearProgressIndicator(
                              value: video.watchProgressPercent,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.18),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF38BDF8),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        fontWeight: FontWeight.w700,
                        color: HomePalette.primaryText(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _buildHistoryMeta(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: HomePalette.tertiaryText(context),
                      ),
                    ),
                    if (video.watchProgress > 0) ...[
                      const SizedBox(height: 8),
                      _buildBadge(
                        label: video.watchProgressPercent >= 1
                            ? '已看完'
                            : '已看 ${_formatProgress()}',
                        backgroundColor: const Color(0xFFE0F2FE),
                        textColor: const Color(0xFF0369A1),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_horiz_rounded,
                  color: HomePalette.tertiaryText(context),
                ),
                itemBuilder: (context) => const [
                  PopupMenuItem<String>(
                    value: 'info',
                    child: Text('详情'),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('删除'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context) {
    final thumbnail = video.thumbnail;

    if (thumbnail != null) {
      if (video.isLocal) {
        return Image.file(
          File(thumbnail),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(context),
        );
      }
      return CachedNetworkImage(
        imageUrl: thumbnail,
        fit: BoxFit.cover,
        placeholder: (_, __) => _buildPlaceholder(context),
        errorWidget: (_, __, ___) => _buildPlaceholder(context),
      );
    }

    return _buildPlaceholder(context);
  }

  Widget _buildPlaceholder(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0EA5E9), Color(0xFF312E81)],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.video_library_rounded,
          color: Colors.white70,
          size: 42,
        ),
      ),
    );
  }

  Widget _buildBadge({
    required String label,
    required Color backgroundColor,
    required Color textColor,
    double radius = 999,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  String _buildGridMeta() {
    if (video.watchProgress > 0) {
      return '已看 ${_formatProgress()} · ${video.isLocal ? '本地视频' : '网络视频'}';
    }
    if (video.description?.isNotEmpty == true) {
      return video.description!;
    }
    return '${video.isLocal ? '本地视频' : '网络视频'} · ${video.formattedDuration}';
  }

  String _buildHistoryMeta() {
    if (video.description?.isNotEmpty == true) {
      return video.description!;
    }
    return '${video.isLocal ? '本地视频' : '网络视频'} · ${video.formattedDuration}';
  }

  String _formatProgress() {
    final progress = video.watchProgressPercent * 100;
    return '${progress.toStringAsFixed(0)}%';
  }
}
