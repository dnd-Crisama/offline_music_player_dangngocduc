import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/audio_provider.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final audioProvider = context.read<AudioProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Dark Mode'),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
          ),
          ListTile(
            title: Text('Accent Color'),
            trailing: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: themeProvider.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Pick a color'),
                    content: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children:
                          [
                            Colors.blue,
                            Colors.red,
                            Colors.green,
                            Colors.purple,
                            Colors.orange,
                            Color(0xFF1DB954),
                          ].map((color) {
                            return GestureDetector(
                              onTap: () {
                                themeProvider.setPrimaryColor(color);
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  );
                },
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Text(
              'Volume',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: StreamBuilder<double>(
              stream: Stream.value(1.0),
              builder: (context, snapshot) {
                return Slider(
                  value: snapshot.data ?? 1.0,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (value) {
                    audioProvider.setVolume(value);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
