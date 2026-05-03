import 'package:flutter/material.dart';
import '../models/playlist_model.dart';

class PlaylistCard extends StatelessWidget {
  final PlaylistModel playlist;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const PlaylistCard({
    required this.playlist,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Color(0xFF282828),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(Icons.playlist_play, color: Colors.white),
      ),
      title: Text(
        playlist.name,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        '${playlist.songIds.length} songs',
        style: TextStyle(color: Colors.grey),
      ),
      trailing: IconButton(
        icon: Icon(Icons.delete, color: Colors.grey),
        onPressed: onDelete,
      ),
      onTap: onTap,
    );
  }
}
