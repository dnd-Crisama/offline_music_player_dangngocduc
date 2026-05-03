import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';
import '../models/playback_state_model.dart';
import '../services/audio_player_service.dart';
import '../services/storage_service.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayerService _audioService;
  final StorageService _storageService;

  List<SongModel> _playlist = [];
  int _currentIndex = 0;
  bool _isShuffleEnabled = false;
  LoopMode _loopMode = LoopMode.off;
  Timer? _sleepTimer;
  Duration? _sleepTimerRemaining;

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

    final volume = await _storageService.getVolume();
    await _audioService.setVolume(volume);

    _audioService.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        next();
      }
    });
  }

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
    if (_isShuffleEnabled) {
      _currentIndex = _getRandomIndex();
    } else {
      _currentIndex = (_currentIndex + 1) % _playlist.length;
    }
    await _playSongAtIndex(_currentIndex);
  }

  Future<void> previous() async {
    if (_playlist.isEmpty) return;
    if (_audioService.currentPosition.inSeconds > 3) {
      await _audioService.seek(Duration.zero);
    } else {
      if (_isShuffleEnabled) {
        _currentIndex = _getRandomIndex();
      } else {
        _currentIndex =
            (_currentIndex - 1 + _playlist.length) % _playlist.length;
      }
      await _playSongAtIndex(_currentIndex);
    }
  }

  Future<void> seek(Duration position) async {
    await _audioService.seek(position);
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
    await _audioService.setVolume(volume);
    await _storageService.saveVolume(volume);
    notifyListeners();
  }

  void setSleepTimer(Duration duration) {
    _sleepTimer?.cancel();
    _sleepTimerRemaining = duration;
    notifyListeners();
    _sleepTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
      _sleepTimerRemaining = _sleepTimerRemaining! - Duration(seconds: 1);
      if (_sleepTimerRemaining!.inSeconds <= 0) {
        timer.cancel();
        _sleepTimerRemaining = null;
        await pause();
      }
      notifyListeners();
    });
  }

  Future<void> pause() async {
    await _audioService.pause();
    notifyListeners();
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimerRemaining = null;
    notifyListeners();
  }

  int _getRandomIndex() {
    final random = DateTime.now().millisecondsSinceEpoch % _playlist.length;
    return random;
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    _audioService.dispose();
    super.dispose();
  }
}
