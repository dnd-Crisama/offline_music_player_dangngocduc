import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:on_audio_query/on_audio_query.dart' as on_audio_query;
import '../models/song_model.dart';

class PlaylistService {
  final on_audio_query.OnAudioQuery? _audioQuery = kIsWeb
      ? null
      : on_audio_query.OnAudioQuery();

  Future<List<SongModel>> getAllSongs() async {
    if (kIsWeb) {
      return _getAssetSongs();
    }

    try {
      if (_audioQuery == null) return _getAssetSongs();
      final audioList = await _audioQuery!.querySongs(
        sortType: on_audio_query.SongSortType.TITLE,
        orderType: on_audio_query.OrderType.ASC_OR_SMALLER,
        uriType: on_audio_query.UriType.EXTERNAL,
        ignoreCase: true,
      );

      if (audioList.isEmpty) {
        return _getAssetSongs();
      }

      return audioList.map((audio) => SongModel.fromAudioQuery(audio)).toList();
    } catch (e) {
      return _getAssetSongs();
    }
  }

  List<SongModel> _getAssetSongs() {
    return [
      SongModel(
        id: 'asset_1',
        title: 'Sample Song 1',
        artist: 'Artist 1',
        album: 'Album 1',
        filePath: 'assets/audio/sample_songs/song1.mp3',
        duration: Duration(minutes: 3, seconds: 30),
        isAsset: true,
      ),
      SongModel(
        id: 'asset_2',
        title: 'Sample Song 2',
        artist: 'Artist 2',
        album: 'Album 2',
        filePath: 'assets/audio/sample_songs/song2.mp3',
        duration: Duration(minutes: 4, seconds: 15),
        isAsset: true,
      ),
      SongModel(
        id: 'asset_3',
        title: 'Sample Song 3',
        artist: 'Artist 3',
        album: 'Album 3',
        filePath: 'assets/audio/sample_songs/song3.mp3',
        duration: Duration(minutes: 2, seconds: 50),
        isAsset: true,
      ),
    ];
  }

  Future<List<SongModel>> getSongsByArtist(String artist) async {
    final allSongs = await getAllSongs();
    return allSongs.where((song) => song.artist == artist).toList();
  }

  Future<List<SongModel>> getSongsByAlbum(String album) async {
    final allSongs = await getAllSongs();
    return allSongs.where((song) => song.album == album).toList();
  }

  Future<List<SongModel>> searchSongs(String query) async {
    final allSongs = await getAllSongs();
    final lowerQuery = query.toLowerCase();

    return allSongs.where((song) {
      return song.title.toLowerCase().contains(lowerQuery) ||
          song.artist.toLowerCase().contains(lowerQuery) ||
          (song.album?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }
}
