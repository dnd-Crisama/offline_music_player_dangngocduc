import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                            color: const Color(0xFF1DB954),
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
              color: isCurrentSong ? const Color(0xFF1DB954) : Colors.white,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            song.artist,
            style: TextStyle(
              color: isCurrentSong
                  ? const Color(0xFF1DB954).withOpacity(0.7)
                  : Colors.grey,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (audioProvider.isFavorite(song.id))
                const Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.favorite,
                    color: Color(0xFF1DB954),
                    size: 14,
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
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
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
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
                      color: Colors.white24,
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
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                song.artist,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(color: Colors.white12),

                  ListTile(
                    leading: Icon(
                      audioProvider.isFavorite(song.id)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: audioProvider.isFavorite(song.id)
                          ? const Color(0xFF1DB954)
                          : Colors.white70,
                    ),
                    title: Text(
                      audioProvider.isFavorite(song.id)
                          ? 'Remove from Favourites'
                          : 'Add to Favourites',
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      audioProvider.toggleFavorite(song.id);
                      Navigator.pop(context);
                    },
                  ),

                  if (playlistProvider.playlists.isNotEmpty)
                    ...playlistProvider.playlists.map((playlist) {
                      return ListTile(
                        leading: const Icon(
                          Icons.playlist_add,
                          color: Colors.white70,
                        ),
                        title: Text(
                          'Add to "${playlist.name}"',
                          style: const TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          playlistProvider.addSongToPlaylist(playlist.id, song);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added to ${playlist.name}'),
                              backgroundColor: const Color(0xFF1DB954),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          Navigator.pop(context);
                        },
                      );
                    }),

                  ListTile(
                    leading: const Icon(
                      Icons.add_circle_outline,
                      color: Color(0xFF1DB954),
                    ),
                    title: const Text(
                      'Create new playlist',
                      style: TextStyle(color: Color(0xFF1DB954)),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showCreatePlaylistDialog(context, playlistProvider);
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
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF282828),
        title: const Text(
          'New Playlist',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Playlist name',
            hintStyle: const TextStyle(color: Colors.white38),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1DB954)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1DB954),
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
