import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/playback_state_model.dart';
import '../providers/audio_provider.dart';
import '../screens/now_playing_screen.dart';
import '../widgets/album_art.dart';

class MiniPlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NowPlayingScreen()),
        );
      },
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Consumer<AudioProvider>(
          builder: (context, provider, child) {
            final song = provider.currentSong;

            if (song == null) return SizedBox.shrink();

            return Column(
              children: [
                StreamBuilder<PlaybackState>(
                  stream: provider.playbackStateStream,
                  builder: (context, snapshot) {
                    final progress = snapshot.data?.progress ?? 0.0;
                    return LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[800],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                      minHeight: 2,
                    );
                  },
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        AlbumArt(albumArt: song.albumArt, size: 50),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                style: TextStyle(fontWeight: FontWeight.w500),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                song.artist,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.6),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        StreamBuilder<bool>(
                          stream: provider.playingStream,
                          builder: (context, snapshot) {
                            final isPlaying = snapshot.data ?? false;
                            return IconButton(
                              icon: Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow,
                                size: 32,
                              ),
                              onPressed: () => provider.playPause(),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.skip_next),
                          onPressed: () => provider.next(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
