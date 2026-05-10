import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/playlist_model.dart';

class StorageService {
  static const String _playlistsKey = 'playlists';
  static const String _lastPlayedKey = 'last_played';
  static const String _shuffleKey = 'shuffle_enabled';
  static const String _repeatKey = 'repeat_mode';
  static const String _volumeKey = 'volume';
  static const String _favoritesKey = 'favorite_song_ids';
  static const String _recentlyPlayedKey = 'recently_played';
  static const String _playbackPositionKey = 'playback_position';
  static const String _playbackSongIdKey = 'playback_song_id';

  Future<void> savePlaylists(List<PlaylistModel> playlists) async {
    final prefs = await SharedPreferences.getInstance();
    final playlistsJson = playlists.map((p) => p.toJson()).toList();
    await prefs.setString(_playlistsKey, json.encode(playlistsJson));
  }

  Future<List<PlaylistModel>> getPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final playlistsString = prefs.getString(_playlistsKey);

    if (playlistsString != null) {
      final List<dynamic> playlistsJson = json.decode(playlistsString);
      return playlistsJson.map((json) => PlaylistModel.fromJson(json)).toList();
    }

    return [];
  }

  Future<void> saveLastPlayed(String songId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastPlayedKey, songId);
  }

  Future<String?> getLastPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastPlayedKey);
  }

  Future<void> saveShuffleState(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_shuffleKey, enabled);
  }

  Future<bool> getShuffleState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_shuffleKey) ?? false;
  }

  Future<void> saveRepeatMode(int mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_repeatKey, mode);
  }

  Future<int> getRepeatMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_repeatKey) ?? 0;
  }

  Future<void> saveVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_volumeKey, volume);
  }

  Future<double> getVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_volumeKey) ?? 1.0;
  }

  Future<void> saveFavorites(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_favoritesKey, json.encode(ids.toList()));
  }

  Future<Set<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_favoritesKey);
    if (str != null) {
      final List<dynamic> list = json.decode(str);
      return list.map((e) => e.toString()).toSet();
    }
    return {};
  }

  Future<void> saveRecentlyPlayedIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_recentlyPlayedKey, json.encode(ids));
  }

  Future<List<String>> getRecentlyPlayedIds() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_recentlyPlayedKey);
    if (str != null) {
      final List<dynamic> list = json.decode(str);
      return list.map((e) => e.toString()).toList();
    }
    return [];
  }

  Future<void> savePlaybackPosition(String songId, int positionMs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_playbackSongIdKey, songId);
    await prefs.setInt(_playbackPositionKey, positionMs);
  }

  Future<MapEntry<String, int>?> getPlaybackPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final songId = prefs.getString(_playbackSongIdKey);
    final pos = prefs.getInt(_playbackPositionKey);
    if (songId != null && pos != null) {
      return MapEntry(songId, pos);
    }
    return null;
  }

  Future<void> clearPlaybackPosition() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_playbackSongIdKey);
    await prefs.remove(_playbackPositionKey);
  }
}
