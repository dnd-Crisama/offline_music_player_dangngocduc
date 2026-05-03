class PlaybackState {
  final Duration position;
  final Duration duration;
  final bool isPlaying;

  PlaybackState({
    required this.position,
    required this.duration,
    required this.isPlaying,
  });

  double get progress {
    if (duration.inMilliseconds > 0) {
      return position.inMilliseconds / duration.inMilliseconds;
    }
    return 0.0;
  }
}
