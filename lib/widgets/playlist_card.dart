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
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(Icons.playlist_play, color: primary),
      ),
      title: Text(
        playlist.name,
        style: TextStyle(color: onSurface, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        '${playlist.songIds.length} songs',
        style: TextStyle(color: onSurface.withOpacity(0.55)),
      ),
      trailing: IconButton(
        icon: Icon(Icons.delete, color: onSurface.withOpacity(0.55)),
        onPressed: onDelete,
      ),
      onTap: onTap,
    );
  }
}
