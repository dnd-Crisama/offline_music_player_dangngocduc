import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/audio_player_service.dart';
import 'services/storage_service.dart';
import 'providers/audio_provider.dart';
import 'providers/playlist_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/playlist_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/mini_player.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final storageService = StorageService();
    final audioPlayerService = AudioPlayerService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => AudioProvider(audioPlayerService, storageService),
        ),
        ChangeNotifierProvider(create: (_) => PlaylistProvider(storageService)),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Offline Music Player',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.currentTheme,
            home: MainScreen(),
          );
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    PlaylistScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _screens[_currentIndex],
          Consumer<AudioProvider>(
            builder: (context, provider, child) {
              if (provider.currentSong == null) {
                return SizedBox.shrink();
              }
              return Positioned(
                left: 0,
                right: 0,
                bottom: 60,
                child: MiniPlayer(),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.playlist_play),
            label: 'Playlists',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
