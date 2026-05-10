import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/playlist_model.dart';
import '../models/song_model.dart';
import '../providers/playlist_provider.dart';
import '../providers/audio_provider.dart';
import '../services/playlist_service.dart';
import '../widgets/song_tile.dart';

class PlaylistScreen extends StatefulWidget {
  @override
  _PlaylistScreenState createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final PlaylistService _playlistService = PlaylistService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Playlists'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showCreatePlaylistDialog(context),
          ),
        ],
      ),
      body: Consumer<PlaylistProvider>(
        builder: (context, provider, child) {
          if (provider.playlists.isEmpty) {
            return Center(
              child: Text(
                'No playlists yet',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: provider.playlists.length,
            itemBuilder: (context, index) {
              return _buildPlaylistCard(
                context,
                provider.playlists[index],
                provider,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPlaylistCard(
    BuildContext context,
    PlaylistModel playlist,
    PlaylistProvider provider,
  ) {
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.playlist_play, color: primary),
        ),
        title: Text(
          playlist.name,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${playlist.songIds.length} songs',
          style: TextStyle(color: onSurface.withOpacity(0.6)),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () => provider.deletePlaylist(playlist.id),
        ),
        onTap: () => _showPlaylistSongs(context, playlist),
      ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final primary = Theme.of(context).colorScheme.primary;
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create Playlist'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Playlist name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  context.read<PlaylistProvider>().createPlaylist(
                    controller.text,
                  );
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

  void _showPlaylistSongs(BuildContext context, PlaylistModel playlist) async {
    final allSongs = await _playlistService.getAllSongs();
    final List<SongModel> playlistSongs = allSongs
        .where((song) => playlist.songIds.contains(song.id))
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(playlist.name)),
          body: playlistSongs.isEmpty
              ? Center(
                  child: Text(
                    'No songs in this playlist',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: playlistSongs.length,
                  itemBuilder: (context, index) {
                    final song = playlistSongs[index];
                    return ListTile(
                      leading: Icon(Icons.music_note),
                      title: Text(song.title),
                      subtitle: Text(
                        song.artist,
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      onTap: () {
                        context.read<AudioProvider>().setPlaylist(
                          playlistSongs,
                          index,
                        );
                      },
                      trailing: IconButton(
                        icon: Icon(
                          Icons.remove_circle_outline,
                          color: Colors.redAccent,
                        ),
                        onPressed: () {
                          context
                              .read<PlaylistProvider>()
                              .removeSongFromPlaylist(playlist.id, song.id);
                        },
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () async {
              final availableSongs = allSongs
                  .where((s) => !playlist.songIds.contains(s.id))
                  .toList();
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text(
                            'Add Songs',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Divider(),
                        Flexible(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: availableSongs.length,
                            itemBuilder: (context, index) {
                              final song = availableSongs[index];
                              return ListTile(
                                title: Text(song.title),
                                subtitle: Text(
                                  song.artist,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                                trailing: Icon(
                                  Icons.add,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                onTap: () {
                                  context
                                      .read<PlaylistProvider>()
                                      .addSongToPlaylist(playlist.id, song);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
