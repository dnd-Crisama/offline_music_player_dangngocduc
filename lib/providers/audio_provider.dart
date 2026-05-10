import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';
import '../models/playback_state_model.dart';
import '../services/audio_player_service.dart';
import '../services/storage_service.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayerService _audioService;
  final StorageService _storageService;
  final Random _random = Random();

  List<SongModel> _playlist = [];
  int _currentIndex = 0;
  bool _isShuffleEnabled = false;
  LoopMode _loopMode = LoopMode.off;
  Timer? _sleepTimer;
  Duration? _sleepTimerRemaining;

  double _currentVolume = 1.0;

  double _playbackSpeed = 1.0;

  final List<SongModel> _recentlyPlayed = [];

  final Set<String> _favoriteSongIds = {};

  AudioProvider(this._audioService, this._storageService) {
    _init();
  }

  List<SongModel> get playlist => _playlist;
  int get currentIndex => _currentIndex;
  SongModel? get currentSong =>
      _playlist.isEmpty ? null : _playlist[_currentIndex];
  bool get isShuffleEnabled => _isShuffleEnabled;
  LoopMode get loopMode => _loopMode;
  Duration? get sleepTimerRemaining => _sleepTimerRemaining;
  double get currentVolume => _currentVolume;
  double get playbackSpeed => _playbackSpeed;
  List<SongModel> get recentlyPlayed => List.unmodifiable(_recentlyPlayed);
  Set<String> get favoriteSongIds => Set.unmodifiable(_favoriteSongIds);
  bool isFavorite(String songId) => _favoriteSongIds.contains(songId);

  Stream<Duration> get positionStream => _audioService.positionStream;
  Stream<Duration?> get durationStream => _audioService.durationStream;
  Stream<bool> get playingStream => _audioService.playingStream;
  Stream<PlaybackState> get playbackStateStream =>
      _audioService.playbackStateStream;

  Future<void> _init() async {
    _isShuffleEnabled = await _storageService.getShuffleState();
    final repeatMode = await _storageService.getRepeatMode();
    _loopMode = LoopMode.values[repeatMode];
    await _audioService.setLoopMode(_loopMode);

    _currentVolume = await _storageService.getVolume();
    await _audioService.setVolume(_currentVolume);

    _audioService.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        next();
      }
    });

    notifyListeners();
  }

  // ── Playlist ───────────────────────────────────────────────────────────────
  Future<void> setPlaylist(List<SongModel> songs, int startIndex) async {
    _playlist = songs;
    _currentIndex = startIndex;
    await _playSongAtIndex(_currentIndex);
    notifyListeners();
  }

  Future<void> _playSongAtIndex(int index) async {
    if (index < 0 || index >= _playlist.length) return;

    _currentIndex = index;
    final song = _playlist[index];

    if (song.isAsset) {
      await _audioService.loadAssetAudio(song.filePath);
    } else {
      await _audioService.loadAudio(song.filePath);
    }

    await _audioService.play();
    await _storageService.saveLastPlayed(song.id);

    _recentlyPlayed.removeWhere((s) => s.id == song.id);
    _recentlyPlayed.insert(0, song);
    if (_recentlyPlayed.length > 20) _recentlyPlayed.removeLast();

    notifyListeners();
  }

  Future<void> playPause() async {
    if (_audioService.isPlaying) {
      await _audioService.pause();
    } else {
      await _audioService.play();
    }
    notifyListeners();
  }

  Future<void> next() async {
    if (_playlist.isEmpty) return;
    if (_loopMode == LoopMode.one) {
      await _playSongAtIndex(_currentIndex);
      return;
    }
    _currentIndex = _isShuffleEnabled
        ? _getRandomIndex()
        : (_currentIndex + 1) % _playlist.length;
    await _playSongAtIndex(_currentIndex);
  }

  Future<void> previous() async {
    if (_playlist.isEmpty) return;
    if (_audioService.currentPosition.inSeconds > 3) {
      await _audioService.seek(Duration.zero);
    } else {
      _currentIndex = _isShuffleEnabled
          ? _getRandomIndex()
          : (_currentIndex - 1 + _playlist.length) % _playlist.length;
      await _playSongAtIndex(_currentIndex);
    }
  }

  Future<void> seek(Duration position) async => _audioService.seek(position);

  Future<void> pause() async {
    await _audioService.pause();
    notifyListeners();
  }

  Future<void> toggleShuffle() async {
    _isShuffleEnabled = !_isShuffleEnabled;
    await _storageService.saveShuffleState(_isShuffleEnabled);
    notifyListeners();
  }

  Future<void> toggleRepeat() async {
    switch (_loopMode) {
      case LoopMode.off:
        _loopMode = LoopMode.all;
        break;
      case LoopMode.all:
        _loopMode = LoopMode.one;
        break;
      case LoopMode.one:
        _loopMode = LoopMode.off;
        break;
    }
    await _audioService.setLoopMode(_loopMode);
    await _storageService.saveRepeatMode(_loopMode.index);
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    _currentVolume = volume.clamp(0.0, 1.0);
    await _audioService.setVolume(_currentVolume);
    await _storageService.saveVolume(_currentVolume);
    notifyListeners();
  }

  Future<void> setPlaybackSpeed(double speed) async {
    _playbackSpeed = speed;
    await _audioService.setSpeed(speed);
    notifyListeners();
  }

  void toggleFavorite(String songId) {
    if (_favoriteSongIds.contains(songId)) {
      _favoriteSongIds.remove(songId);
    } else {
      _favoriteSongIds.add(songId);
    }
    notifyListeners();
  }

  List<SongModel> getFavoriteSongs(List<SongModel> allSongs) =>
      allSongs.where((s) => _favoriteSongIds.contains(s.id)).toList();

  void setSleepTimer(Duration duration) {
    _sleepTimer?.cancel();
    _sleepTimerRemaining = duration;
    notifyListeners();

    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final remaining = _sleepTimerRemaining;
      if (remaining == null || remaining.inSeconds <= 0) {
        timer.cancel();
        _sleepTimerRemaining = null;
        await pause();
        notifyListeners();
        return;
      }
      _sleepTimerRemaining = remaining - const Duration(seconds: 1);
      notifyListeners();
    });
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimerRemaining = null;
    notifyListeners();
  }

  int _getRandomIndex() {
    if (_playlist.length <= 1) return 0;
    int idx;
    do {
      idx = _random.nextInt(_playlist.length);
    } while (idx == _currentIndex);
    return idx;
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    _audioService.dispose();
    super.dispose();
  }
}
