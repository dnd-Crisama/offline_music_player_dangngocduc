import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../services/playlist_service.dart';
import '../services/permission_service.dart';
import '../widgets/song_tile.dart';

enum SortOption { TITLE, ARTIST, ALBUM }

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PlaylistService _playlistService = PlaylistService();
  final PermissionService _permissionService = PermissionService();
  final TextEditingController _searchController = TextEditingController();

  List<SongModel> _songs = [];
  List<SongModel> _filteredSongs = [];
  bool _isLoading = true;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    _hasPermission = await _permissionService.requestStoragePermission();

    if (_hasPermission) {
      await _permissionService.requestAudioPermission();
      await _loadSongs();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadSongs() async {
    try {
      final songs = await _playlistService.getAllSongs();
      setState(() {
        _songs = songs;
        _filteredSongs = songs;
      });
      _filterSongs(_searchController.text);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading songs: $e')));
    }
  }

  void _filterSongs(String query) {
    setState(() {
      _filteredSongs = _songs.where((song) {
        final lowerQuery = query.toLowerCase();
        return song.title.toLowerCase().contains(lowerQuery) ||
            song.artist.toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }

  void _sortSongs(SortOption sortType) {
    setState(() {
      if (sortType == SortOption.TITLE) {
        _filteredSongs.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
      } else if (sortType == SortOption.ARTIST) {
        _filteredSongs.sort(
          (a, b) => a.artist.toLowerCase().compareTo(b.artist.toLowerCase()),
        );
      } else if (sortType == SortOption.ALBUM) {
        _filteredSongs.sort(
          (a, b) => (a.album ?? '').toLowerCase().compareTo(
            (b.album ?? '').toLowerCase(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search songs...',
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: _filterSongs,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : !_hasPermission
                  ? _buildPermissionDenied()
                  : _songs.isEmpty
                  ? _buildNoSongs()
                  : _buildSongList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'My Music',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          PopupMenuButton<SortOption>(
            onSelected: _sortSongs,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: SortOption.TITLE,
                child: Text('Sort by Title'),
              ),
              PopupMenuItem(
                value: SortOption.ARTIST,
                child: Text('Sort by Artist'),
              ),
              PopupMenuItem(
                value: SortOption.ALBUM,
                child: Text('Sort by Album'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSongList() {
    return RefreshIndicator(
      onRefresh: _loadSongs,
      child: ListView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: _filteredSongs.length,
        itemBuilder: (context, index) {
          final song = _filteredSongs[index];
          return SongTile(
            song: song,
            onTap: () {
              context.read<AudioProvider>().setPlaylist(_filteredSongs, index);
            },
          );
        },
      ),
    );
  }

  Widget _buildPermissionDenied() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.music_off, size: 80, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            'Storage Permission Required',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 10),
          Text(
            'Please grant storage permission to access music',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await openAppSettings();
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSongs() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.music_note, size: 80, color: Colors.grey),
          SizedBox(height: 20),
          Text('No Music Found', style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 10),
          Text('Add some music files to your device'),
        ],
      ),
    );
  }
}
