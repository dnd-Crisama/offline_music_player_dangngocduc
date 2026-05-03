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
    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 3,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 16),
            activeTrackColor: Color(0xFF1DB954),
            inactiveTrackColor: Colors.grey[800],
            thumbColor: Colors.white,
            overlayColor: Color(0xFF1DB954).withOpacity(0.3),
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
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                DurationFormatter.format(duration),
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
