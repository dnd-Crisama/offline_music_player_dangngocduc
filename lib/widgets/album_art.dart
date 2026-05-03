import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';

class AlbumArt extends StatelessWidget {
  final String? albumArt;
  final double size;

  const AlbumArt({required this.albumArt, this.size = 50});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.08),
        color: Color(0xFF282828),
      ),
      child: _buildImage(),
    );
  }

  Widget _buildImage() {
    if (albumArt == null) {
      return Image.asset(
        'assets/images/default_album_art.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(Icons.music_note, color: Colors.grey, size: size * 0.5),
          );
        },
      );
    }

    if (kIsWeb) {
      return Image.network(
        albumArt!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/images/default_album_art.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Icon(
                  Icons.music_note,
                  color: Colors.grey,
                  size: size * 0.5,
                ),
              );
            },
          );
        },
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.08),
      child: Image.file(
        File(albumArt!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/images/default_album_art.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Icon(
                  Icons.music_note,
                  color: Colors.grey,
                  size: size * 0.5,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
