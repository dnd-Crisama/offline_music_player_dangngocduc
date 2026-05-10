import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/playback_state_model.dart';
import '../providers/audio_provider.dart';
import '../screens/now_playing_screen.dart';
import '../widgets/album_art.dart';
import '../widgets/equalizer_animation.dart';

class MiniPlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, provider, _) {
        final song = provider.currentSong;
        if (song == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, anim, __) => NowPlayingScreen(),
              transitionsBuilder: (_, anim, __, child) {
                return SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: anim,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 380),
            ),
          ),
          child: Dismissible(
            key: const ValueKey('mini_player'),
            direction: DismissDirection.down,
            confirmDismiss: (_) async {
              provider.pause();
              return false;
            },
            child: Container(
              height: 70,
              margin: const EdgeInsets.fromLTRB(8, 0, 8, 4),
              decoration: BoxDecoration(
                color: const Color(0xFF282828),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.45),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Column(
                  children: [
                    StreamBuilder<PlaybackState>(
                      stream: provider.playbackStateStream,
                      builder: (_, snap) {
                        final progress = snap.data?.progress ?? 0.0;
                        return LinearProgressIndicator(
                          value: progress,
                          minHeight: 2,
                          backgroundColor: Colors.white12,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF1DB954),
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: AlbumArt(
                                albumArt: song.albumArt,
                                size: 44,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Row(
                                children: [
                                  StreamBuilder<bool>(
                                    stream: provider.playingStream,
                                    builder: (_, snap) {
                                      final playing = snap.data ?? false;
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8,
                                        ),
                                        child: EqualizerAnimation(
                                          isPlaying: playing,
                                          color: const Color(0xFF1DB954),
                                          width: 16,
                                          height: 14,
                                          barCount: 3,
                                        ),
                                      );
                                    },
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          song.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          song.artist,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.55,
                                            ),
                                            fontSize: 11,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (provider.isFavorite(song.id))
                              const Padding(
                                padding: EdgeInsets.only(right: 2),
                                child: Icon(
                                  Icons.favorite,
                                  color: Color(0xFF1DB954),
                                  size: 14,
                                ),
                              ),
                            StreamBuilder<bool>(
                              stream: provider.playingStream,
                              builder: (_, snap) {
                                final playing = snap.data ?? false;
                                return IconButton(
                                  icon: Icon(
                                    playing ? Icons.pause : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  onPressed: provider.playPause,
                                  visualDensity: VisualDensity.compact,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.skip_next,
                                color: Colors.white,
                                size: 24,
                              ),
                              onPressed: provider.next,
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
