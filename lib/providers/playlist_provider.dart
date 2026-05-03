import 'package:flutter/material.dart';
import '../models/playlist_model.dart';
import '../models/song_model.dart';
import '../services/storage_service.dart';

class PlaylistProvider extends ChangeNotifier {
  final StorageService _storageService;
  List<PlaylistModel> _playlists = [];

  PlaylistProvider(this._storageService) {
    _loadPlaylists();
  }

  List<PlaylistModel> get playlists => _playlists;

  Future<void> _loadPlaylists() async {
    _playlists = await _storageService.getPlaylists();
    notifyListeners();
  }

  Future<void> createPlaylist(String name) async {
    final playlist = PlaylistModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      songIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _playlists.add(playlist);
    await _storageService.savePlaylists(_playlists);
    notifyListeners();
  }

  Future<void> addSongToPlaylist(String playlistId, SongModel song) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      if (!_playlists[index].songIds.contains(song.id)) {
        _playlists[index].songIds.add(song.id);
        _playlists[index] = _playlists[index].copyWith(
          updatedAt: DateTime.now(),
        );
        await _storageService.savePlaylists(_playlists);
        notifyListeners();
      }
    }
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      _playlists[index].songIds.remove(songId);
      _playlists[index] = _playlists[index].copyWith(updatedAt: DateTime.now());
      await _storageService.savePlaylists(_playlists);
      notifyListeners();
    }
  }

  Future<void> deletePlaylist(String playlistId) async {
    _playlists.removeWhere((p) => p.id == playlistId);
    await _storageService.savePlaylists(_playlists);
    notifyListeners();
  }

  Future<void> renamePlaylist(String playlistId, String newName) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      _playlists[index] = _playlists[index].copyWith(
        name: newName,
        updatedAt: DateTime.now(),
      );
      await _storageService.savePlaylists(_playlists);
      notifyListeners();
    }
  }
}
