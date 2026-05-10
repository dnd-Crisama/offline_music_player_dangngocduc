import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/audio_provider.dart';
import '../services/playlist_service.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _SectionHeader(title: 'APPEARANCE'),

          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: Text(
              themeProvider.isDarkMode
                  ? 'Dark theme active'
                  : 'Light theme active',
              style: TextStyle(color: onSurface.withOpacity(0.5), fontSize: 12),
            ),
            secondary: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
            value: themeProvider.isDarkMode,
            onChanged: (_) => themeProvider.toggleTheme(),
          ),

          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Accent Colour'),
            trailing: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: themeProvider.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: onSurface.withOpacity(0.3), width: 2),
              ),
            ),
            onTap: () => _showColorPicker(context, themeProvider),
          ),

          const Divider(height: 1, indent: 16, endIndent: 16),

          _SectionHeader(title: 'PLAYBACK'),

          Consumer<AudioProvider>(
            builder: (context, audioProvider, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      children: [
                        const Icon(Icons.volume_up_outlined, size: 18),
                        const SizedBox(width: 8),
                        const Text('Volume'),
                        const Spacer(),
                        Text(
                          '${(audioProvider.currentVolume * 100).round()}%',
                          style: TextStyle(
                            color: onSurface.withOpacity(0.5),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Slider(
                    value: audioProvider.currentVolume,
                    min: 0.0,
                    max: 1.0,
                    onChanged: audioProvider.setVolume,
                  ),
                ],
              );
            },
          ),

          Consumer<AudioProvider>(
            builder: (context, audioProvider, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        const Icon(Icons.speed, size: 18),
                        const SizedBox(width: 8),
                        const Text('Playback Speed'),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${audioProvider.playbackSpeed}x',
                            style: TextStyle(
                              color: primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 8,
                      children: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
                        final selected =
                            (audioProvider.playbackSpeed - speed).abs() < 0.01;
                        return ChoiceChip(
                          label: Text('${speed}x'),
                          selected: selected,
                          onSelected: (_) =>
                              audioProvider.setPlaybackSpeed(speed),
                          selectedColor: primary,
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : null,
                            fontWeight: selected ? FontWeight.w600 : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            },
          ),

          const Divider(height: 1, indent: 16, endIndent: 16),

          _SectionHeader(title: 'LIBRARY'),

          FutureBuilder<int>(
            future: _getTotalSongCount(),
            builder: (context, snap) {
              final count = snap.data ?? 0;
              return ListTile(
                leading: const Icon(Icons.library_music_outlined),
                title: const Text('Total Songs'),
                trailing: Text(
                  count.toString(),
                  style: TextStyle(color: onSurface.withOpacity(0.5)),
                ),
              );
            },
          ),

          Consumer<AudioProvider>(
            builder: (context, audioProvider, _) {
              return ListTile(
                leading: const Icon(Icons.favorite_outline),
                title: const Text('Favourites'),
                trailing: Text(
                  '${audioProvider.favoriteSongIds.length}',
                  style: TextStyle(color: onSurface.withOpacity(0.5)),
                ),
              );
            },
          ),

          Consumer<AudioProvider>(
            builder: (context, audioProvider, _) {
              return ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Recently Played'),
                trailing: Text(
                  '${audioProvider.recentlyPlayed.length}',
                  style: TextStyle(color: onSurface.withOpacity(0.5)),
                ),
              );
            },
          ),

          Consumer<AudioProvider>(
            builder: (context, audioProvider, _) {
              final current = audioProvider.currentSong;
              if (current == null) return const SizedBox.shrink();
              return ListTile(
                leading: const Icon(Icons.play_circle_outline),
                title: const Text('Last Played'),
                subtitle: Text(
                  '${current.title} - ${current.artist}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: onSurface.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),

          const Divider(height: 1, indent: 16, endIndent: 16),

          _SectionHeader(title: 'ABOUT'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Version'),
            trailing: Text(
              '1.0.0',
              style: TextStyle(color: onSurface.withOpacity(0.5)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.music_note_outlined),
            title: const Text('Audio Engine'),
            trailing: Text(
              'just_audio + audio_service',
              style: TextStyle(
                color: onSurface.withOpacity(0.5),
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Future<int> _getTotalSongCount() async {
    final service = PlaylistService();
    final songs = await service.getAllSongs();
    return songs.length;
  }

  void _showColorPicker(BuildContext context, ThemeProvider themeProvider) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final colours = [
      const Color(0xFF1DB954),
      Colors.blue,
      Colors.purple,
      Colors.red,
      Colors.orange,
      Colors.cyan,
      Colors.pink,
      const Color(0xFFE8C951),
    ];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Choose Accent Colour'),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colours.map((color) {
            final selected = themeProvider.primaryColor == color;
            return GestureDetector(
              onTap: () {
                themeProvider.setPrimaryColor(color);
                Navigator.pop(context);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? onSurface : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: selected
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
