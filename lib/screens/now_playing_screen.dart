import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:share_plus/share_plus.dart';
import '../models/song_model.dart';
import '../models/playback_state_model.dart';
import '../providers/audio_provider.dart';
import '../providers/playlist_provider.dart';
import '../widgets/progress_bar.dart';
import '../widgets/album_art.dart';
import '../widgets/equalizer_animation.dart';
import '../widgets/marquee_text.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<AudioProvider>(
      builder: (context, provider, _) {
        final song = provider.currentSong;
        if (isDark && song != null) _extractColors(song);

        final bgColor = isDark ? Colors.transparent : null;
        final gradient = isDark
            ? BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.45, 1.0],
                  colors: [_topColor, _bottomColor, const Color(0xFF0A0A0A)],
                ),
              )
            : null;

        return Scaffold(
          backgroundColor: bgColor,
          body: isDark
              ? AnimatedContainer(
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeInOut,
                  decoration: gradient!,
                  child: song == null
                      ? Center(
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
                )
              : song == null
              ? Center(
                  child: Text(
                    'No song playing',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                )
              : FadeTransition(
                  opacity: _enterFade,
                  child: SlideTransition(
                    position: _enterSlide,
                    child: _Body(
                      song: song,
                      provider: provider,
                      topColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
        );
      },
    );
  }
}

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;
    final subColor = isDark
        ? Colors.white.withOpacity(0.65)
        : Theme.of(context).colorScheme.onSurface.withOpacity(0.65);

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

class _AppBar extends StatelessWidget {
  final SongModel song;
  final AudioProvider provider;

  const _AppBar({required this.song, required this.provider});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;
    final subColor = isDark
        ? Colors.white54
        : Theme.of(context).colorScheme.onSurface.withOpacity(0.54);

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.keyboard_arrow_down, color: textColor, size: 32),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'NOW PLAYING',
                  style: TextStyle(
                    color: subColor,
                    fontSize: 11,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  song.album ?? 'Unknown Album',
                  style: TextStyle(
                    color: textColor,
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
            icon: Icon(Icons.more_vert, color: textColor),
            onPressed: () => _showOptionsSheet(context, provider),
          ),
        ],
      ),
    );
  }

  void _showOptionsSheet(BuildContext context, AudioProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF282828) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Wrap(
        children: [
          ListTile(
            leading: Icon(Icons.share, color: onSurface.withOpacity(0.7)),
            title: Text('Share', style: TextStyle(color: onSurface)),
            onTap: () {
              Navigator.pop(context);
              _shareSong(context);
            },
          ),
          ListTile(
            leading: Icon(
              provider.isFavorite(song.id)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: provider.isFavorite(song.id)
                  ? primary
                  : onSurface.withOpacity(0.7),
            ),
            title: Text(
              provider.isFavorite(song.id)
                  ? 'Remove from Favourites'
                  : 'Add to Favourites',
              style: TextStyle(color: onSurface),
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

  void _shareSong(BuildContext context) {
    final text = 'Listening to ${song.title} by ${song.artist}';
    Share.share(text);
  }
}

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

class _SongInfoRow extends StatelessWidget {
  final SongModel song;
  final AudioProvider provider;

  const _SongInfoRow({required this.song, required this.provider});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;
    final subColor = isDark
        ? Colors.white.withOpacity(0.65)
        : Theme.of(context).colorScheme.onSurface.withOpacity(0.65);
    final primary = Theme.of(context).colorScheme.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MarqueeText(
                text: song.title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                availableWidth: MediaQuery.of(context).size.width - 96,
              ),
              const SizedBox(height: 4),
              Text(
                song.artist,
                style: TextStyle(color: subColor, fontSize: 15),
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
                  ? primary
                  : (isDark ? Colors.white60 : Colors.black45),
              size: 28,
            ),
          ),
        ),
      ],
    );
  }
}

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

class _MainControls extends StatelessWidget {
  final AudioProvider provider;

  const _MainControls({required this.provider});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;
    final primary = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _IconToggle(
              icon: Icons.shuffle,
              active: provider.isShuffleEnabled,
              activeColor: primary,
              inactiveColor: isDark ? Colors.white60 : Colors.black45,
              onTap: provider.toggleShuffle,
            ),
            IconButton(
              icon: Icon(Icons.skip_previous, color: textColor, size: 36),
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
                      color: isDark ? Colors.white : primary,
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? Colors.white : primary).withOpacity(
                            0.25,
                          ),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      playing ? Icons.pause : Icons.play_arrow,
                      color: isDark ? Colors.black : Colors.white,
                      size: 38,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.skip_next, color: textColor, size: 36),
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
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _IconToggle({
    required this.icon,
    required this.active,
    required this.activeColor,
    required this.inactiveColor,
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
            color: active ? activeColor : inactiveColor,
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
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: activeColor,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final isOn = provider.loopMode != LoopMode.off;
    final inactiveColor = isDark ? Colors.white60 : Colors.black45;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        IconButton(
          icon: Icon(
            provider.loopMode == LoopMode.one ? Icons.repeat_one : Icons.repeat,
            color: isOn ? primary : inactiveColor,
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
              decoration: BoxDecoration(shape: BoxShape.circle, color: primary),
            ),
          ),
      ],
    );
  }
}

class _VolumeRow extends StatelessWidget {
  final AudioProvider provider;

  const _VolumeRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white54 : Colors.black45;
    final activeTrack = isDark
        ? Colors.white
        : Theme.of(context).colorScheme.primary;
    final inactiveTrack = isDark ? Colors.white24 : Colors.black12;
    final thumbColor = isDark
        ? Colors.white
        : Theme.of(context).colorScheme.primary;

    return Row(
      children: [
        Icon(
          provider.currentVolume == 0 ? Icons.volume_off : Icons.volume_down,
          color: iconColor,
          size: 18,
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: activeTrack,
              inactiveTrackColor: inactiveTrack,
              thumbColor: thumbColor,
              overlayColor: inactiveTrack,
            ),
            child: Slider(
              value: provider.currentVolume,
              min: 0.0,
              max: 1.0,
              onChanged: provider.setVolume,
            ),
          ),
        ),
        Icon(Icons.volume_up, color: iconColor, size: 18),
      ],
    );
  }
}

class _BottomIconRow extends StatelessWidget {
  final AudioProvider provider;

  const _BottomIconRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final inactiveColor = isDark ? Colors.white60 : Colors.black45;
    final inactiveLabel = isDark ? Colors.white54 : Colors.black38;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _BottomIcon(
          icon: Icons.bedtime_outlined,
          label: provider.sleepTimerRemaining != null
              ? '${provider.sleepTimerRemaining!.inMinutes}m'
              : null,
          active: provider.sleepTimerRemaining != null,
          activeColor: primary,
          inactiveColor: inactiveColor,
          inactiveLabelColor: inactiveLabel,
          onTap: () => _showSleepTimerDialog(context, provider),
        ),
        _BottomIcon(
          icon: Icons.speed,
          label: provider.playbackSpeed != 1.0
              ? '${provider.playbackSpeed}x'
              : null,
          active: provider.playbackSpeed != 1.0,
          activeColor: primary,
          inactiveColor: inactiveColor,
          inactiveLabelColor: inactiveLabel,
          onTap: () => _showSpeedDialog(context, provider),
        ),
        _BottomIcon(
          icon: Icons.lyrics_outlined,
          active: false,
          activeColor: primary,
          inactiveColor: inactiveColor,
          inactiveLabelColor: inactiveLabel,
          onTap: () => _showLyricsDialog(context),
        ),
        StreamBuilder<bool>(
          stream: provider.playingStream,
          builder: (_, snap) {
            final isPlaying = snap.data ?? false;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: EqualizerAnimation(
                isPlaying: isPlaying,
                color: primary,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final cardBg = Theme.of(context).cardColor;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF282828) : Colors.white,
        title: Text(
          'Sleep Timer',
          style: TextStyle(color: onSurface, fontWeight: FontWeight.bold),
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
                    color: primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primary.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.timer, color: primary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Stops in ${provider.sleepTimerRemaining!.inMinutes}m '
                        '${provider.sleepTimerRemaining!.inSeconds.remainder(60)}s',
                        style: TextStyle(color: primary),
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
                    foregroundColor: onSurface,
                    side: BorderSide(color: onSurface.withOpacity(0.3)),
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
            child: Text('Close', style: TextStyle(color: primary)),
          ),
        ],
      ),
    );
  }

  void _showSpeedDialog(BuildContext context, AudioProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF282828) : Colors.white,
        title: Text(
          'Playback Speed',
          style: TextStyle(color: onSurface, fontWeight: FontWeight.bold),
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
                  color: selected ? primary : onSurface.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? primary : onSurface.withOpacity(0.24),
                  ),
                ),
                child: Text(
                  '${s}x',
                  style: TextStyle(
                    color: selected ? Colors.white : onSurface,
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
            child: Text('Done', style: TextStyle(color: primary)),
          ),
        ],
      ),
    );
  }

  void _showLyricsDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF282828) : Colors.white,
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
                    color: onSurface.withOpacity(0.24),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Lyrics',
                style: TextStyle(
                  color: onSurface,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  controller: ctrl,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.lyrics_outlined,
                            color: onSurface.withOpacity(0.24),
                            size: 56,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No lyrics available',
                            style: TextStyle(
                              color: onSurface.withOpacity(0.54),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Lyrics will appear here when available.',
                            style: TextStyle(
                              color: onSurface.withOpacity(0.38),
                            ),
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
  final Color activeColor;
  final Color inactiveColor;
  final Color inactiveLabelColor;
  final VoidCallback onTap;

  const _BottomIcon({
    required this.icon,
    required this.onTap,
    required this.active,
    required this.activeColor,
    required this.inactiveColor,
    required this.inactiveLabelColor,
    this.label,
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
            Icon(icon, color: active ? activeColor : inactiveColor, size: 22),
            if (label != null) ...[
              const SizedBox(height: 2),
              Text(
                label!,
                style: TextStyle(
                  color: active ? activeColor : inactiveLabelColor,
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
