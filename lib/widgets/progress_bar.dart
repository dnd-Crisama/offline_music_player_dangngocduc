import 'package:flutter/material.dart';
import '../utils/duration_formatter.dart';

class ProgressBar extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final Function(Duration) onSeek;

  const ProgressBar({
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 3,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 16),
            activeTrackColor: primary,
            inactiveTrackColor: isDark ? Colors.grey[800] : Colors.grey[300],
            thumbColor: isDark ? Colors.white : primary,
            overlayColor: primary.withOpacity(0.3),
          ),
          child: Slider(
            value: position.inMilliseconds.toDouble(),
            min: 0.0,
            max: duration.inMilliseconds.toDouble() > 0
                ? duration.inMilliseconds.toDouble()
                : 1.0,
            onChanged: (value) {
              onSeek(Duration(milliseconds: value.toInt()));
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DurationFormatter.format(position),
                style: TextStyle(
                  color: onSurface.withOpacity(0.55),
                  fontSize: 12,
                ),
              ),
              Text(
                DurationFormatter.format(duration),
                style: TextStyle(
                  color: onSurface.withOpacity(0.55),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
