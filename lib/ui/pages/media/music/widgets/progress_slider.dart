import 'package:flutter/material.dart';

/// 进度条组件
class ProgressSlider extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeStart;

  const ProgressSlider({
    super.key,
    required this.position,
    required this.duration,
    this.onChanged,
    this.onChangeStart,
  });

  @override
  State<ProgressSlider> createState() => _ProgressSliderState();
}

class _ProgressSliderState extends State<ProgressSlider> {
  bool _isDragging = false;
  double _dragValue = 0.0;

  double get _progress {
    if (_isDragging) return _dragValue;
    if (widget.duration.inMilliseconds <= 0) return 0.0;
    return widget.position.inMilliseconds / widget.duration.inMilliseconds;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: SliderComponentShape.noOverlay,
            activeTrackColor: Theme.of(context).colorScheme.primary,
            inactiveTrackColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            thumbColor: Theme.of(context).colorScheme.primary,
          ),
          child: Slider(
            value: _progress.clamp(0.0, 1.0),
            onChanged: (value) {
              setState(() {
                _isDragging = true;
                _dragValue = value;
              });
              widget.onChangeStart?.call(value);
            },
            onChangeEnd: (value) {
              setState(() {
                _isDragging = false;
              });
              widget.onChanged?.call(value);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(widget.position),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                _formatDuration(widget.duration),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
