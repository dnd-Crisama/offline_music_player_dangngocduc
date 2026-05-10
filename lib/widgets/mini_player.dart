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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final cardBg = Theme.of(context).cardColor;

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
                color: isDark ? const Color(0xFF282828) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.45 : 0.15),
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
                          backgroundColor: isDark
                              ? Colors.white12
                              : Colors.black12,
                          valueColor: AlwaysStoppedAnimation<Color>(primary),
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
                                          color: primary,
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
                                          style: TextStyle(
                                            color: onSurface,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          song.artist,
                                          style: TextStyle(
                                            color: onSurface.withOpacity(0.55),
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
                              Padding(
                                padding: const EdgeInsets.only(right: 2),
                                child: Icon(
                                  Icons.favorite,
                                  color: primary,
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
                                    color: onSurface,
                                    size: 28,
                                  ),
                                  onPressed: provider.playPause,
                                  visualDensity: VisualDensity.compact,
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.skip_next,
                                color: onSurface,
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
