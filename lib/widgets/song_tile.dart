import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import '../models/song_model.dart';
import '../providers/playlist_provider.dart';
import '../widgets/album_art.dart';

class SongTile extends StatelessWidget {
  final SongModel song;
  final VoidCallback onTap;

  const SongTile({required this.song, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: AlbumArt(albumArt: song.albumArt, size: 50),
      title: Text(
        song.title,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.artist,
        style: TextStyle(color: Colors.grey),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: Icon(Icons.more_vert, color: Colors.grey),
        onPressed: () {
          _showOptionsMenu(context);
        },
      ),
      onTap: onTap,
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF282828),
      builder: (context) {
        return Consumer<PlaylistProvider>(
          builder: (context, playlistProvider, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Add to Playlist',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...playlistProvider.playlists.map((playlist) {
                  return ListTile(
                    title: Text(
                      playlist.name,
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      playlistProvider.addSongToPlaylist(playlist.id, song);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
                ListTile(
                  title: Text(
                    'Create new playlist',
                    style: TextStyle(color: Color(0xFF1DB954)),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showCreatePlaylistDialog(context, playlistProvider);
                  },
                ),
              ],
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
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFF282828),
          title: Text('Create Playlist', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Playlist name',
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  await playlistProvider.createPlaylist(controller.text);
                  final newPlaylist = playlistProvider.playlists.last;
                  playlistProvider.addSongToPlaylist(newPlaylist.id, song);
                  Navigator.pop(context);
                }
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
