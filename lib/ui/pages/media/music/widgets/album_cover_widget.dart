import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../data/models/media/music_track.dart';

/// 专辑封面组件
/// 支持旋转动画
class AlbumCoverWidget extends StatefulWidget {
  final MusicTrack? track;
  final bool isPlaying;
  final double size;

  const AlbumCoverWidget({
    super.key,
    required this.track,
    this.isPlaying = false,
    this.size = 280,
  });

  @override
  State<AlbumCoverWidget> createState() => _AlbumCoverWidgetState();
}

class _AlbumCoverWidgetState extends State<AlbumCoverWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
  }

  @override
  void didUpdateWidget(AlbumCoverWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isPlaying && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * pi,
          child: child,
        );
      },
      child: _buildCover(),
    );
  }

  Widget _buildCover() {
    final coverUrl = widget.track?.displayCover;

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipOval(
        child: coverUrl != null
            ? _buildNetworkImage(coverUrl)
            : _buildDefaultCover(),
      ),
    );
  }

  Widget _buildNetworkImage(String url) {
    // 判断是本地文件还是网络 URL
    if (url.startsWith('/') || url.startsWith('file://')) {
      final localPath =
          url.startsWith('file://') ? Uri.parse(url).toFilePath() : url;
      return Image.file(
        File(localPath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildDefaultCover(),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (context, url) => _buildDefaultCover(),
      errorWidget: (context, url, error) => _buildDefaultCover(),
    );
  }

  Widget _buildDefaultCover() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
        ),
      ),
      child: Icon(
        Icons.music_note,
        size: widget.size * 0.4,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }
}
