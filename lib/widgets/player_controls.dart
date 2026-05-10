import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../providers/audio_provider.dart';

class PlayerControls extends StatelessWidget {
  final AudioProvider provider;

  const PlayerControls({required this.provider});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final inactiveColor = isDark ? Colors.grey : Colors.black45;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(
                Icons.shuffle,
                color: provider.isShuffleEnabled ? primary : inactiveColor,
              ),
              onPressed: () => provider.toggleShuffle(),
            ),
            SizedBox(width: 40),
            _buildRepeatButton(primary, inactiveColor),
          ],
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(Icons.skip_previous, color: onSurface, size: 40),
              onPressed: () => provider.previous(),
            ),
            StreamBuilder<bool>(
              stream: provider.playingStream,
              builder: (context, snapshot) {
                final isPlaying = snapshot.data ?? false;
                return Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primary,
                  ),
                  child: IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 40,
                    ),
                    onPressed: () => provider.playPause(),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.skip_next, color: onSurface, size: 40),
              onPressed: () => provider.next(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRepeatButton(Color primary, Color inactiveColor) {
    IconData iconData;
    Color color;

    switch (provider.loopMode) {
      case LoopMode.off:
        iconData = Icons.repeat;
        color = inactiveColor;
        break;
      case LoopMode.all:
        iconData = Icons.repeat;
        color = primary;
        break;
      case LoopMode.one:
        iconData = Icons.repeat_one;
        color = primary;
        break;
    }

    return IconButton(
      icon: Icon(iconData, color: color),
      onPressed: () => provider.toggleRepeat(),
    );
  }
}
