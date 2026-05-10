import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:palette_generator/palette_generator.dart';
import '../models/song_model.dart';
import '../models/playback_state_model.dart';
import '../providers/audio_provider.dart';
import '../widgets/progress_bar.dart';
import '../widgets/album_art.dart';
import '../widgets/equalizer_animation.dart';

class NowPlayingScreen extends StatefulWidget {
  @override
  _NowPlayingScreenState createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen>
    with TickerProviderStateMixin {
  Color _topColor = const Color(0xFF1E3A2F);
  Color _bottomColor = const Color(0xFF121212);
  String? _colorSongId;

  late final AnimationController _enterCtrl;
  late final Animation<double> _enterFade;
  late final Animation<Offset> _enterSlide;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..forward();
    _enterFade = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _enterSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  Future<void> _extractColors(SongModel song) async {
    if (_colorSongId == song.id) return;
    _colorSongId = song.id;

    if (!kIsWeb && song.albumArt != null) {
      try {
        final palette = await PaletteGenerator.fromImageProvider(
          FileImage(File(song.albumArt!)),
          size: const Size(100, 100),
        );
        if (!mounted) return;
        setState(() {
          _topColor =
              (palette.darkVibrantColor?.color ??
              palette.dominantColor?.color ??
              const Color(0xFF1E3A2F));
          _bottomColor = const Color(0xFF121212);
        });
        return;
      } catch (_) {}
    }
    if (mounted) {
      setState(() {
        _topColor = const Color(0xFF1E3A2F);
        _bottomColor = const Color(0xFF121212);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, provider, _) {
        final song = provider.currentSong;
        if (song != null) _extractColors(song);

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.45, 1.0],
                colors: [_topColor, _bottomColor, const Color(0xFF0A0A0A)],
              ),
            ),
            child: song == null
                ? const Center(
                    child: Text(
                      'No song playing',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : FadeTransition(
                    opacity: _enterFade,
                    child: SlideTransition(
                      position: _enterSlide,
                      child: _Body(
                        song: song,
                        provider: provider,
                        topColor: _topColor,
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _Body extends StatelessWidget {
  final SongModel song;
  final AudioProvider provider;
  final Color topColor;

  const _Body({
    required this.song,
    required this.provider,
    required this.topColor,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _AppBar(song: song, provider: provider),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const Spacer(flex: 1),
                  _AlbumArtCard(provider: provider, accentColor: topColor),
                  const Spacer(flex: 1),
                  _SongInfoRow(song: song, provider: provider),
                  const SizedBox(height: 20),
                  _ProgressSection(provider: provider),
                  const SizedBox(height: 4),
                  _MainControls(provider: provider),
                  const SizedBox(height: 16),
                  _VolumeRow(provider: provider),
                  const SizedBox(height: 12),
                  _BottomIconRow(provider: provider),
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── App bar ────────────────────────────────────────────────────────────────
class _AppBar extends StatelessWidget {
  final SongModel song;
  final AudioProvider provider;

  const _AppBar({required this.song, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 32,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              children: [
                const Text(
                  'NOW PLAYING',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  song.album ?? 'Unknown Album',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () => _showOptionsSheet(context, provider),
          ),
        ],
      ),
    );
  }

  void _showOptionsSheet(BuildContext context, AudioProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF282828),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.share, color: Colors.white70),
            title: const Text('Share', style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(
              provider.isFavorite(song.id)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: provider.isFavorite(song.id)
                  ? const Color(0xFF1DB954)
                  : Colors.white70,
            ),
            title: Text(
              provider.isFavorite(song.id)
                  ? 'Remove from Favourites'
                  : 'Add to Favourites',
              style: const TextStyle(color: Colors.white),
            ),
            onTap: () {
              provider.toggleFavorite(song.id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

// ── Album art with scale animation ────────────────────────────────────────
class _AlbumArtCard extends StatelessWidget {
  final AudioProvider provider;
  final Color accentColor;

  const _AlbumArtCard({required this.provider, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: provider.playingStream,
      builder: (context, snap) {
        final isPlaying = snap.data ?? false;
        return AnimatedScale(
          scale: isPlaying ? 1.0 : 0.86,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            width: double.infinity,
            height: MediaQuery.of(context).size.width - 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.5),
                  blurRadius: 50,
                  offset: const Offset(0, 24),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.6),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AlbumArt(
                albumArt: provider.currentSong?.albumArt,
                size: MediaQuery.of(context).size.width - 56,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Song info + heart ─────────────────────────────────────────────────────
class _SongInfoRow extends StatelessWidget {
  final SongModel song;
  final AudioProvider provider;

  const _SongInfoRow({required this.song, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                song.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                song.artist,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => provider.toggleFavorite(song.id),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              provider.isFavorite(song.id)
                  ? Icons.favorite
                  : Icons.favorite_border,
              key: ValueKey(provider.isFavorite(song.id)),
              color: provider.isFavorite(song.id)
                  ? const Color(0xFF1DB954)
                  : Colors.white60,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Progress bar ──────────────────────────────────────────────────────────
class _ProgressSection extends StatelessWidget {
  final AudioProvider provider;

  const _ProgressSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlaybackState>(
      stream: provider.playbackStateStream,
      builder: (context, snap) {
        final state = snap.data;
        return ProgressBar(
          position: state?.position ?? Duration.zero,
          duration: state?.duration ?? Duration.zero,
          onSeek: provider.seek,
        );
      },
    );
  }
}

// ── Main controls (prev / play / next + shuffle / repeat) ────────────────
class _MainControls extends StatelessWidget {
  final AudioProvider provider;

  const _MainControls({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // shuffle ─── ─── ─── play / pause ─── ─── ─── repeat
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _IconToggle(
              icon: Icons.shuffle,
              active: provider.isShuffleEnabled,
              onTap: provider.toggleShuffle,
            ),
            IconButton(
              icon: const Icon(
                Icons.skip_previous,
                color: Colors.white,
                size: 36,
              ),
              onPressed: provider.previous,
            ),
            StreamBuilder<bool>(
              stream: provider.playingStream,
              builder: (_, snap) {
                final playing = snap.data ?? false;
                return GestureDetector(
                  onTap: provider.playPause,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.25),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      playing ? Icons.pause : Icons.play_arrow,
                      color: Colors.black,
                      size: 38,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.skip_next, color: Colors.white, size: 36),
              onPressed: provider.next,
            ),
            _RepeatButton(provider: provider),
          ],
        ),
      ],
    );
  }
}

class _IconToggle extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _IconToggle({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        IconButton(
          icon: Icon(
            icon,
            color: active ? const Color(0xFF1DB954) : Colors.white60,
            size: 24,
          ),
          onPressed: onTap,
        ),
        if (active)
          Positioned(
            bottom: 4,
            child: Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1DB954),
              ),
            ),
          ),
      ],
    );
  }
}

class _RepeatButton extends StatelessWidget {
  final AudioProvider provider;

  const _RepeatButton({required this.provider});

  @override
  Widget build(BuildContext context) {
    final isOn = provider.loopMode != LoopMode.off;
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        IconButton(
          icon: Icon(
            provider.loopMode == LoopMode.one ? Icons.repeat_one : Icons.repeat,
            color: isOn ? const Color(0xFF1DB954) : Colors.white60,
            size: 24,
          ),
          onPressed: provider.toggleRepeat,
        ),
        if (isOn)
          Positioned(
            bottom: 4,
            child: Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1DB954),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Volume slider ─────────────────────────────────────────────────────────
class _VolumeRow extends StatelessWidget {
  final AudioProvider provider;

  const _VolumeRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          provider.currentVolume == 0 ? Icons.volume_off : Icons.volume_down,
          color: Colors.white54,
          size: 18,
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.white,
              overlayColor: Colors.white24,
            ),
            child: Slider(
              value: provider.currentVolume,
              min: 0.0,
              max: 1.0,
              onChanged: provider.setVolume,
            ),
          ),
        ),
        const Icon(Icons.volume_up, color: Colors.white54, size: 18),
      ],
    );
  }
}

// ── Bottom icon row: timer | speed | lyrics | equalizer ──────────────────
class _BottomIconRow extends StatelessWidget {
  final AudioProvider provider;

  const _BottomIconRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Sleep timer
        _BottomIcon(
          icon: Icons.bedtime_outlined,
          label: provider.sleepTimerRemaining != null
              ? '${provider.sleepTimerRemaining!.inMinutes}m'
              : null,
          active: provider.sleepTimerRemaining != null,
          onTap: () => _showSleepTimerDialog(context, provider),
        ),
        // Speed
        _BottomIcon(
          icon: Icons.speed,
          label: provider.playbackSpeed != 1.0
              ? '${provider.playbackSpeed}x'
              : null,
          active: provider.playbackSpeed != 1.0,
          onTap: () => _showSpeedDialog(context, provider),
        ),
        // Lyrics
        _BottomIcon(
          icon: Icons.lyrics_outlined,
          onTap: () => _showLyricsDialog(context),
        ),
        // Equalizer animation acting as a visual only button
        StreamBuilder<bool>(
          stream: provider.playingStream,
          builder: (_, snap) {
            final isPlaying = snap.data ?? false;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: EqualizerAnimation(
                isPlaying: isPlaying,
                color: const Color(0xFF1DB954),
                width: 22,
                height: 18,
                barCount: 4,
              ),
            );
          },
        ),
      ],
    );
  }

  void _showSleepTimerDialog(BuildContext context, AudioProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF282828),
        title: const Text(
          'Sleep Timer',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (provider.sleepTimerRemaining != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1DB954).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF1DB954).withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.timer,
                        color: Color(0xFF1DB954),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Stops in ${provider.sleepTimerRemaining!.inMinutes}m '
                        '${provider.sleepTimerRemaining!.inSeconds.remainder(60)}s',
                        style: const TextStyle(color: Color(0xFF1DB954)),
                      ),
                    ],
                  ),
                ),
              ),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [15, 30, 45, 60].map((min) {
                return OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    provider.setSleepTimer(Duration(minutes: min));
                    Navigator.pop(context);
                  },
                  child: Text('$min min'),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          if (provider.sleepTimerRemaining != null)
            TextButton(
              onPressed: () {
                provider.cancelSleepTimer();
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel Timer',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF1DB954)),
            ),
          ),
        ],
      ),
    );
  }

  void _showSpeedDialog(BuildContext context, AudioProvider provider) {
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF282828),
        title: const Text(
          'Playback Speed',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: speeds.map((s) {
            final selected = (provider.playbackSpeed - s).abs() < 0.01;
            return GestureDetector(
              onTap: () {
                provider.setPlaybackSpeed(s);
                Navigator.pop(context);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF1DB954)
                      : Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? const Color(0xFF1DB954) : Colors.white24,
                  ),
                ),
                child: Text(
                  '${s}x',
                  style: TextStyle(
                    color: selected ? Colors.black : Colors.white,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Done',
              style: TextStyle(color: Color(0xFF1DB954)),
            ),
          ),
        ],
      ),
    );
  }

  void _showLyricsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF282828),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (_, ctrl) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Lyrics',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  controller: ctrl,
                  children: const [
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.lyrics_outlined,
                            color: Colors.white24,
                            size: 56,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No lyrics available',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Lyrics will appear here when available.',
                            style: TextStyle(color: Colors.white38),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomIcon extends StatelessWidget {
  final IconData icon;
  final String? label;
  final bool active;
  final VoidCallback onTap;

  const _BottomIcon({
    required this.icon,
    required this.onTap,
    this.label,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: active ? const Color(0xFF1DB954) : Colors.white60,
              size: 22,
            ),
            if (label != null) ...[
              const SizedBox(height: 2),
              Text(
                label!,
                style: TextStyle(
                  color: active ? const Color(0xFF1DB954) : Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
