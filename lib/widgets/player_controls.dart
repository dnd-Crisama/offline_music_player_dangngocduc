import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../providers/audio_provider.dart';

class PlayerControls extends StatelessWidget {
  final AudioProvider provider;

  const PlayerControls({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(
                Icons.shuffle,
                color: provider.isShuffleEnabled
                    ? Color(0xFF1DB954)
                    : Colors.grey,
              ),
              onPressed: () => provider.toggleShuffle(),
            ),
            SizedBox(width: 40),
            _buildRepeatButton(),
          ],
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(Icons.skip_previous, color: Colors.white, size: 40),
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
                    color: Color(0xFF1DB954),
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
              icon: Icon(Icons.skip_next, color: Colors.white, size: 40),
              onPressed: () => provider.next(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRepeatButton() {
    IconData iconData;
    Color color;

    switch (provider.loopMode) {
      case LoopMode.off:
        iconData = Icons.repeat;
        color = Colors.grey;
        break;
      case LoopMode.all:
        iconData = Icons.repeat;
        color = Color(0xFF1DB954);
        break;
      case LoopMode.one:
        iconData = Icons.repeat_one;
        color = Color(0xFF1DB954);
        break;
    }

    return IconButton(
      icon: Icon(iconData, color: color),
      onPressed: () => provider.toggleRepeat(),
    );
  }
}
