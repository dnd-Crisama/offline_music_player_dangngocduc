import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../services/playlist_service.dart';
import '../widgets/song_tile.dart';

enum _FilterTab { all, songs, artists, albums }

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final PlaylistService _service = PlaylistService();
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focus = FocusNode();
  late final TabController _tabCtrl;

  List<SongModel> _allSongs = [];
  List<SongModel> _results = [];
  bool _loading = false;
  bool _initialised = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _tabCtrl.addListener(() => setState(() {}));
    _loadAll();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    _focus.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    final songs = await _service.getAllSongs();
    if (mounted) {
      setState(() {
        _allSongs = songs;
        _loading = false;
        _initialised = true;
      });
    }
  }

  void _onQueryChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      final lower = q.toLowerCase().trim();
      setState(() {
        if (lower.isEmpty) {
          _results = [];
        } else {
          _results = _allSongs.where((s) {
            return s.title.toLowerCase().contains(lower) ||
                s.artist.toLowerCase().contains(lower) ||
                (s.album?.toLowerCase().contains(lower) ?? false);
          }).toList();
        }
      });
    });
  }

  List<SongModel> get _filtered {
    switch (_tabCtrl.index) {
      case 1:
        return _results;
      case 2:
        final seen = <String>{};
        return _results.where((s) => seen.add(s.artist.toLowerCase())).toList();
      case 3:
        final seen = <String>{};
        return _results
            .where((s) => s.album != null && seen.add(s.album!.toLowerCase()))
            .toList();
      default:
        return _results;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(context),
            _buildTabBar(context),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _ctrl.text.isEmpty
                  ? _buildBrowseHint()
                  : _filtered.isEmpty
                  ? _buildNoResults()
                  : _buildResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.09),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _ctrl,
                focusNode: _focus,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Songs, artists, albums…',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 15,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.white38),
                  suffixIcon: _ctrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: Colors.white38,
                            size: 18,
                          ),
                          onPressed: () {
                            _ctrl.clear();
                            _onQueryChanged('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 13,
                    horizontal: 4,
                  ),
                ),
                onChanged: _onQueryChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    const tabs = ['All', 'Songs', 'Artists', 'Albums'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(tabs.length, (i) {
            final selected = _tabCtrl.index == i;
            return GestureDetector(
              onTap: () => _tabCtrl.animateTo(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF1DB954)
                      : Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tabs[i],
                  style: TextStyle(
                    color: selected ? Colors.black : Colors.white70,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildResults() {
    final list = _filtered;
    return ListView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: list.length,
      itemBuilder: (context, i) {
        final song = list[i];
        return Consumer<AudioProvider>(
          builder: (_, provider, __) => SongTile(
            song: song,
            onTap: () {
              provider.setPlaylist(list, i);
            },
          ),
        );
      },
    );
  }

  Widget _buildBrowseHint() {
    if (!_initialised) return const SizedBox.shrink();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.white.withOpacity(0.12)),
          const SizedBox(height: 16),
          Text(
            'Search your library',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_allSongs.length} songs available',
            style: TextStyle(
              color: Colors.white.withOpacity(0.25),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sentiment_dissatisfied_outlined,
            size: 56,
            color: Colors.white.withOpacity(0.15),
          ),
          const SizedBox(height: 16),
          Text(
            'No results for "${_ctrl.text}"',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try a different search term.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.25),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
