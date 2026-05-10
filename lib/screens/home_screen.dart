import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../providers/theme_provider.dart';
import '../services/playlist_service.dart';
import '../services/permission_service.dart';
import '../widgets/song_tile.dart';
import '../screens/now_playing_screen.dart';

enum SortOption { title, artist, album }

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PlaylistService _playlistService = PlaylistService();
  final PermissionService _permissionService = PermissionService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<SongModel> _songs = [];
  List<SongModel> _filteredSongs = [];
  bool _isLoading = true;
  bool _hasPermission = false;
  SortOption _currentSort = SortOption.title;
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    _hasPermission = await _permissionService.requestStoragePermission();
    if (_hasPermission) {
      await _permissionService.requestAudioPermission();
      await _loadSongs();
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadSongs() async {
    try {
      final songs = await _playlistService.getAllSongs();
      if (mounted) {
        setState(() {
          _songs = songs;
          _filteredSongs = songs;
        });
        _applySort();
        context.read<AudioProvider>().restoreLastSession(songs);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading songs: $e')));
      }
    }
  }

  void _filterSongs(String query) {
    setState(() {
      _filteredSongs = _songs.where((song) {
        final q = query.toLowerCase();
        return song.title.toLowerCase().contains(q) ||
            song.artist.toLowerCase().contains(q) ||
            (song.album?.toLowerCase().contains(q) ?? false);
      }).toList();
      _applySort(notify: false);
    });
  }

  void _applySort({bool notify = true}) {
    _filteredSongs.sort((a, b) {
      switch (_currentSort) {
        case SortOption.title:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case SortOption.artist:
          return a.artist.toLowerCase().compareTo(b.artist.toLowerCase());
        case SortOption.album:
          return (a.album ?? '').toLowerCase().compareTo(
            (b.album ?? '').toLowerCase(),
          );
      }
    });
    if (notify && mounted) setState(() {});
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : !_hasPermission
            ? _buildPermissionDenied()
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final tp = context.read<ThemeProvider>();

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(child: _buildHeader()),

        Consumer<AudioProvider>(
          builder: (_, provider, __) {
            final recent = provider.recentlyPlayed;
            if (recent.isEmpty)
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            return SliverToBoxAdapter(
              child: _buildHorizontalSection(
                title: 'Recently Played',
                songs: recent,
                provider: provider,
              ),
            );
          },
        ),

        Consumer<AudioProvider>(
          builder: (_, provider, __) {
            final favs = provider.getFavoriteSongs(_songs);
            if (favs.isEmpty)
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            return SliverToBoxAdapter(
              child: _buildHorizontalSection(
                title: 'Favourites',
                songs: favs,
                provider: provider,
              ),
            );
          },
        ),

        SliverToBoxAdapter(child: _buildSearchBar()),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _filteredSongs.isEmpty
                      ? 'No results'
                      : '${_filteredSongs.length} songs',
                  style: TextStyle(
                    color: onSurface.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
                Row(
                  children: [
                    Consumer<AudioProvider>(
                      builder: (_, provider, __) => GestureDetector(
                        onTap: () {
                          if (_filteredSongs.isEmpty) return;
                          final idx =
                              DateTime.now().millisecondsSinceEpoch %
                              _filteredSongs.length;
                          provider.setPlaylist(_filteredSongs, idx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NowPlayingScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.shuffle,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Shuffle',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<SortOption>(
                      icon: Icon(
                        Icons.sort,
                        color: onSurface.withOpacity(0.54),
                        size: 20,
                      ),
                      color: Theme.of(context).cardColor,
                      onSelected: (opt) {
                        setState(() => _currentSort = opt);
                        _applySort();
                      },
                      itemBuilder: (_) => [
                        _sortItem(SortOption.title, 'Title'),
                        _sortItem(SortOption.artist, 'Artist'),
                        _sortItem(SortOption.album, 'Album'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        _songs.isEmpty
            ? SliverToBoxAdapter(child: _buildNoSongs())
            : SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final song = _filteredSongs[index];
                  return Consumer<AudioProvider>(
                    builder: (_, provider, __) => SongTile(
                      song: song,
                      onTap: () => provider.setPlaylist(_filteredSongs, index),
                    ),
                  );
                }, childCount: _filteredSongs.length),
              ),

        const SliverToBoxAdapter(child: SizedBox(height: 160)),
      ],
    );
  }

  PopupMenuItem<SortOption> _sortItem(SortOption opt, String label) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final primary = Theme.of(context).colorScheme.primary;
    return PopupMenuItem<SortOption>(
      value: opt,
      child: Row(
        children: [
          Icon(
            _currentSort == opt
                ? Icons.radio_button_checked
                : Icons.radio_button_off,
            color: primary,
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(color: onSurface)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: TextStyle(
                  color: onSurface.withOpacity(0.65),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'My Music',
                style: TextStyle(
                  color: onSurface,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              _showSearch ? Icons.search_off : Icons.search,
              color: onSurface,
            ),
            onPressed: () => setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) {
                _searchController.clear();
                _filterSongs('');
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final tp = context.read<ThemeProvider>();

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: _showSearch
          ? Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(color: onSurface),
                decoration: InputDecoration(
                  hintText: 'Search songs, artists, albums...',
                  hintStyle: TextStyle(color: onSurface.withOpacity(0.35)),
                  prefixIcon: Icon(
                    Icons.search,
                    color: onSurface.withOpacity(0.38),
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: onSurface.withOpacity(0.38),
                            size: 18,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _filterSongs('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: tp.searchFieldBgColor(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: _filterSongs,
              ),
            )
          : const SizedBox(height: 4),
    );
  }

  Widget _buildHorizontalSection({
    required String title,
    required List<SongModel> songs,
    required AudioProvider provider,
  }) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final cardBg = Theme.of(context).cardColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Text(
            title,
            style: TextStyle(
              color: onSurface,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 138,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: songs.length,
            itemBuilder: (context, i) {
              final song = songs[i];
              return GestureDetector(
                onTap: () {
                  provider.setPlaylist(songs, i);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => NowPlayingScreen()),
                  );
                },
                child: Container(
                  width: 110,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 110,
                        height: 90,
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _RecentlyPlayedArt(song: song),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        song.title,
                        style: TextStyle(
                          color: onSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        song.artist,
                        style: TextStyle(
                          color: onSurface.withOpacity(0.54),
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionDenied() {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final primary = Theme.of(context).colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_off, size: 72, color: onSurface.withOpacity(0.24)),
            const SizedBox(height: 20),
            Text(
              'Storage Access Required',
              style: TextStyle(
                color: onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Please grant storage permission to access your music library.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: onSurface.withOpacity(0.54),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: openAppSettings,
              icon: const Icon(Icons.settings_outlined),
              label: const Text('Open Settings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSongs() {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final primary = Theme.of(context).colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const SizedBox(height: 48),
            Icon(
              Icons.music_note,
              size: 72,
              color: onSurface.withOpacity(0.24),
            ),
            const SizedBox(height: 20),
            Text(
              'No Music Found',
              style: TextStyle(
                color: onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Add MP3 files to your device or place them in\nassets/audio/sample_songs/',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: onSurface.withOpacity(0.54),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 28),
            OutlinedButton.icon(
              onPressed: _loadSongs,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: OutlinedButton.styleFrom(
                foregroundColor: primary,
                side: BorderSide(color: primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentlyPlayedArt extends StatelessWidget {
  final SongModel song;

  const _RecentlyPlayedArt({required this.song});

  @override
  Widget build(BuildContext context) {
    if (song.albumArt != null && !kIsWeb) {
      return Image.file(
        File(song.albumArt!),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Center(
          child: Icon(
            Icons.music_note,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.24),
            size: 36,
          ),
        ),
      );
    }
    return Center(
      child: Icon(
        Icons.music_note,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.24),
        size: 36,
      ),
    );
  }
}
