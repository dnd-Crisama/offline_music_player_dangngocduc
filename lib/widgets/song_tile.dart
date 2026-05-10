import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../providers/playlist_provider.dart';
import '../widgets/album_art.dart';
import '../widgets/equalizer_animation.dart';

class SongTile extends StatelessWidget {
  final SongModel song;
  final VoidCallback onTap;

  const SongTile({required this.song, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Consumer<AudioProvider>(
      builder: (context, audioProvider, _) {
        final isCurrentSong = audioProvider.currentSong?.id == song.id;
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 6,
          ),
          leading: SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: AlbumArt(albumArt: song.albumArt, size: 50),
                ),
                if (isCurrentSong)
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: StreamBuilder<bool>(
                        stream: audioProvider.playingStream,
                        builder: (_, snap) {
                          final playing = snap.data ?? false;
                          return EqualizerAnimation(
                            isPlaying: playing,
                            color: primary,
                            width: 24,
                            height: 20,
                            barCount: 4,
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
          title: Text(
            song.title,
            style: TextStyle(
              color: isCurrentSong ? primary : onSurface,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            song.artist,
            style: TextStyle(
              color: isCurrentSong
                  ? primary.withOpacity(0.7)
                  : onSurface.withOpacity(0.55),
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (audioProvider.isFavorite(song.id))
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(Icons.favorite, color: primary, size: 14),
                ),
              IconButton(
                icon: Icon(Icons.more_vert, color: onSurface.withOpacity(0.55)),
                onPressed: () => _showOptionsMenu(context, audioProvider),
              ),
            ],
          ),
          onTap: onTap,
        );
      },
    );
  }

  void _showOptionsMenu(BuildContext context, AudioProvider audioProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer<PlaylistProvider>(
          builder: (context, playlistProvider, _) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: onSurface.withOpacity(0.24),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: AlbumArt(albumArt: song.albumArt, size: 46),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                style: TextStyle(
                                  color: onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                song.artist,
                                style: TextStyle(
                                  color: onSurface.withOpacity(0.54),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: onSurface.withOpacity(0.12)),
                  ListTile(
                    leading: Icon(
                      audioProvider.isFavorite(song.id)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: audioProvider.isFavorite(song.id)
                          ? primary
                          : onSurface.withOpacity(0.7),
                    ),
                    title: Text(
                      audioProvider.isFavorite(song.id)
                          ? 'Remove from Favourites'
                          : 'Add to Favourites',
                      style: TextStyle(color: onSurface),
                    ),
                    onTap: () {
                      audioProvider.toggleFavorite(song.id);
                      Navigator.pop(context);
                    },
                  ),
                  if (playlistProvider.playlists.isNotEmpty)
                    ...playlistProvider.playlists.map((playlist) {
                      return ListTile(
                        leading: Icon(
                          Icons.playlist_add,
                          color: onSurface.withOpacity(0.7),
                        ),
                        title: Text(
                          'Add to "${playlist.name}"',
                          style: TextStyle(color: onSurface),
                        ),
                        onTap: () {
                          playlistProvider.addSongToPlaylist(playlist.id, song);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added to ${playlist.name}'),
                              backgroundColor: primary,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          Navigator.pop(context);
                        },
                      );
                    }),
                  ListTile(
                    leading: Icon(Icons.add_circle_outline, color: primary),
                    title: Text(
                      'Create new playlist',
                      style: TextStyle(color: primary),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showCreatePlaylistDialog(context, playlistProvider);
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.share,
                      color: onSurface.withOpacity(0.7),
                    ),
                    title: Text('Share', style: TextStyle(color: onSurface)),
                    onTap: () {
                      Navigator.pop(context);
                      Share.share(
                        'Listening to ${song.title} by ${song.artist}',
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCreatePlaylistDialog(
    BuildContext context,
    PlaylistProvider playlistProvider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF282828) : Colors.white,
        title: Text(
          'New Playlist',
          style: TextStyle(color: onSurface, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: TextStyle(color: onSurface),
          decoration: InputDecoration(
            hintText: 'Playlist name',
            hintStyle: TextStyle(color: onSurface.withOpacity(0.38)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: onSurface.withOpacity(0.24)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: onSurface.withOpacity(0.54)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () async {
              if (ctrl.text.trim().isNotEmpty) {
                await playlistProvider.createPlaylist(ctrl.text.trim());
                final newPlaylist = playlistProvider.playlists.last;
                playlistProvider.addSongToPlaylist(newPlaylist.id, song);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
