import 'dart:async';
import 'package:flutter/material.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';

/// 视频手势类型
enum VideoGestureType {
  none,
  brightness,
  volume,
  seek,
}

/// 视频手势检测器
class VideoGestureDetector extends StatefulWidget {
  final Widget child;
  final Duration currentPosition;
  final Duration totalDuration;
  final void Function(Duration position) onSeek;
  final bool enabled;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;

  const VideoGestureDetector({
    super.key,
    required this.child,
    required this.currentPosition,
    required this.totalDuration,
    required this.onSeek,
    this.enabled = true,
    this.onTap,
    this.onDoubleTap,
  });

  @override
  State<VideoGestureDetector> createState() => _VideoGestureDetectorState();
}

class _VideoGestureDetectorState extends State<VideoGestureDetector> {
  // 手势状态
  VideoGestureType _gestureType = VideoGestureType.none;
  double _startDy = 0;
  double _startDx = 0;
  double _currentValue = 0;

  // 亮度/音量值
  double _brightness = 0.5;
  double _volume = 0.5;

  // Seek 相关
  Duration _seekPosition = Duration.zero;
  bool _isSeeking = false;

  // 隐藏提示的定时器
  Timer? _hideIndicatorTimer;

  @override
  void initState() {
    super.initState();
    _initBrightnessAndVolume();
  }

  Future<void> _initBrightnessAndVolume() async {
    try {
      _brightness = await ScreenBrightness().current;
    } catch (_) {
      _brightness = 0.5;
    }

    try {
      VolumeController().listener((volume) {
        if (mounted) {
          setState(() => _volume = volume);
        }
      });
      _volume = await VolumeController().getVolume();
    } catch (_) {
      _volume = 0.5;
    }
  }

  @override
  void dispose() {
    _hideIndicatorTimer?.cancel();
    VolumeController().removeListener();
    super.dispose();
  }

  void _resetGestureState() {
    _gestureType = VideoGestureType.none;
    _startDy = 0;
    _startDx = 0;
    _isSeeking = false;
  }

  void _cancelHideTimer() {
    _hideIndicatorTimer?.cancel();
  }

  void _startHideTimer() {
    _hideIndicatorTimer?.cancel();
    _hideIndicatorTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _resetGestureState());
      }
    });
  }

  void _onVerticalDragStart(DragStartDetails details, bool isLeft) {
    if (!widget.enabled) return;

    _cancelHideTimer();
    _startDy = details.globalPosition.dy;
    _gestureType = isLeft ? VideoGestureType.brightness : VideoGestureType.volume;
    _currentValue = isLeft ? _brightness : _volume;

    setState(() {});
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (!widget.enabled || _gestureType == VideoGestureType.none) return;

    final dy = details.globalPosition.dy - _startDy;
    final screenHeight = MediaQuery.of(context).size.height;
    final delta = -dy / screenHeight * 2; // 负号使得向上滑动增加

    if (_gestureType == VideoGestureType.brightness) {
      _brightness = (_brightness + delta).clamp(0.0, 1.0);
      _currentValue = _brightness;
      ScreenBrightness().setScreenBrightness(_brightness);
    } else if (_gestureType == VideoGestureType.volume) {
      _volume = (_volume + delta).clamp(0.0, 1.0);
      _currentValue = _volume;
      VolumeController().setVolume(_volume);
    }

    setState(() {});
    _startDy = details.globalPosition.dy;
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    _startHideTimer();
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    if (!widget.enabled) return;

    _cancelHideTimer();
    _startDx = details.globalPosition.dx;
    _gestureType = VideoGestureType.seek;
    _seekPosition = widget.currentPosition;
    _isSeeking = true;

    setState(() {});
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (!widget.enabled || _gestureType != VideoGestureType.seek) return;

    final dx = details.globalPosition.dx - _startDx;
    final screenWidth = MediaQuery.of(context).size.width;
    final duration = widget.totalDuration;

    // 每滑动屏幕宽度的 1/3，跳转 60 秒
    final seekSeconds = (dx / screenWidth) * 180;
    final newPosition = _seekPosition + Duration(seconds: seekSeconds.toInt());
    _seekPosition = Duration(
      milliseconds: newPosition.inMilliseconds.clamp(0, duration.inMilliseconds),
    );

    setState(() {});
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_isSeeking && _seekPosition != widget.currentPosition) {
      widget.onSeek(_seekPosition);
    }
    _startHideTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 手势检测层
        Row(
          children: [
            // 左侧 - 亮度控制
            Expanded(
              child: GestureDetector(
                onTap: widget.onTap,
                onDoubleTap: widget.onDoubleTap,
                onVerticalDragStart: (d) => _onVerticalDragStart(d, true),
                onVerticalDragUpdate: _onVerticalDragUpdate,
                onVerticalDragEnd: _onVerticalDragEnd,
                child: widget.child,
              ),
            ),
            // 右侧 - 音量控制
            Expanded(
              child: GestureDetector(
                onTap: widget.onTap,
                onDoubleTap: widget.onDoubleTap,
                onVerticalDragStart: (d) => _onVerticalDragStart(d, false),
                onVerticalDragUpdate: _onVerticalDragUpdate,
                onVerticalDragEnd: _onVerticalDragEnd,
                onHorizontalDragStart: _onHorizontalDragStart,
                onHorizontalDragUpdate: _onHorizontalDragUpdate,
                onHorizontalDragEnd: _onHorizontalDragEnd,
                child: Container(color: Colors.transparent),
              ),
            ),
          ],
        ),

        // 手势提示
        if (_gestureType != VideoGestureType.none)
          Center(
            child: _buildGestureIndicator(),
          ),
      ],
    );
  }

  Widget _buildGestureIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_gestureType == VideoGestureType.brightness) ...[
            const Icon(Icons.brightness_6, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              '亮度: ${(_currentValue * 100).toStringAsFixed(0)}%',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            _buildProgressBar(_currentValue),
          ] else if (_gestureType == VideoGestureType.volume) ...[
            Icon(
              _currentValue == 0 ? Icons.volume_off : Icons.volume_up,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              '音量: ${(_currentValue * 100).toStringAsFixed(0)}%',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            _buildProgressBar(_currentValue),
          ] else if (_gestureType == VideoGestureType.seek && _isSeeking) ...[
            const Icon(Icons.fast_forward, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              _formatDuration(_seekPosition),
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            Text(
              '/ ${_formatDuration(widget.totalDuration)}',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressBar(double value) {
    return SizedBox(
      width: 100,
      child: LinearProgressIndicator(
        value: value,
        backgroundColor: Colors.white.withValues(alpha: 0.3),
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
        minHeight: 4,
      ),
    );
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
