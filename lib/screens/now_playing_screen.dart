import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../models/playback_state_model.dart';
import '../providers/audio_provider.dart';
import '../widgets/player_controls.dart';
import '../widgets/progress_bar.dart';
import '../widgets/album_art.dart';

class NowPlayingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AudioProvider>(
        builder: (context, provider, child) {
          final song = provider.currentSong;

          if (song == null) {
            return Center(child: Text('No song playing'));
          }

          return SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AlbumArt(albumArt: song.albumArt, size: 300),
                        SizedBox(height: 40),
                        _buildSongInfo(context, song),
                        SizedBox(height: 40),
                        StreamBuilder<PlaybackState>(
                          stream: provider.playbackStateStream,
                          builder: (context, snapshot) {
                            final state = snapshot.data;
                            return ProgressBar(
                              position: state?.position ?? Duration.zero,
                              duration: state?.duration ?? Duration.zero,
                              onSeek: (position) {
                                provider.seek(position);
                              },
                            );
                          },
                        ),
                        SizedBox(height: 20),
                        PlayerControls(provider: provider),
                        SizedBox(height: 20),
                        _buildAdvancedControls(context, provider),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.keyboard_arrow_down, size: 32),
            onPressed: () => Navigator.pop(context),
          ),
          Text('Now Playing', style: Theme.of(context).textTheme.titleMedium),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              _showOptionsMenu(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSongInfo(BuildContext context, SongModel song) {
    return Column(
      children: [
        Text(
          song.title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 8),
        Text(
          song.artist,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAdvancedControls(BuildContext context, AudioProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(
            Icons.timer,
            color: provider.sleepTimerRemaining != null
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          onPressed: () {
            _showSleepTimerDialog(context, provider);
          },
        ),
        IconButton(
          icon: Icon(
            Icons.lyrics,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          onPressed: () {
            _showLyricsDialog(context);
          },
        ),
      ],
    );
  }

  void _showSleepTimerDialog(BuildContext context, AudioProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Sleep Timer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (provider.sleepTimerRemaining != null)
                Text(
                  'Remaining: ${provider.sleepTimerRemaining!.inMinutes} min ${provider.sleepTimerRemaining!.inSeconds.remainder(60)} sec',
                ),
              SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      provider.setSleepTimer(Duration(minutes: 15));
                      Navigator.pop(context);
                    },
                    child: Text('15m'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      provider.setSleepTimer(Duration(minutes: 30));
                      Navigator.pop(context);
                    },
                    child: Text('30m'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      provider.setSleepTimer(Duration(minutes: 60));
                      Navigator.pop(context);
                    },
                    child: Text('60m'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                provider.cancelSleepTimer();
                Navigator.pop(context);
              },
              child: Text('Cancel Timer'),
            ),
          ],
        );
      },
    );
  }

  void _showLyricsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Lyrics'),
          content: Text(
            'No lyrics available for this song.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.share),
              title: Text('Share'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
