import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  Color _primaryColor = Color(0xFF1DB954);
  bool _isDarkMode = true;

  Color get primaryColor => _primaryColor;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  ThemeData get currentTheme {
    if (_isDarkMode) {
      return ThemeData(
        brightness: Brightness.dark,
        primaryColor: _primaryColor,
        scaffoldBackgroundColor: Color(0xFF191414),
        colorScheme: ColorScheme.dark(
          primary: _primaryColor,
          secondary: _primaryColor,
          surface: Color(0xFF191414),
          onSurface: Colors.white,
          onPrimary: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF191414),
          foregroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardColor: Color(0xFF282828),
        dialogBackgroundColor: Color(0xFF282828),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
        ),
        listTileTheme: ListTileThemeData(
          textColor: Colors.white,
          iconColor: Colors.grey,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF191414),
          selectedItemColor: _primaryColor,
          unselectedItemColor: Colors.grey,
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: _primaryColor,
          thumbColor: Colors.white,
          inactiveTrackColor: Colors.grey,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.all(Colors.white),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return _primaryColor;
            return Colors.grey;
          }),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: _primaryColor),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Color(0xFF282828),
          contentTextStyle: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white70),
      );
    } else {
      return ThemeData(
        brightness: Brightness.light,
        primaryColor: _primaryColor,
        scaffoldBackgroundColor: Color(0xFFF8F8F8),
        colorScheme: ColorScheme.light(
          primary: _primaryColor,
          secondary: _primaryColor,
          surface: Colors.white,
          onSurface: Color(0xFF1A1A1A),
          onPrimary: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1A1A1A),
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF1A1A1A)),
          titleTextStyle: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardColor: Color(0xFFEEEEEE),
        dialogBackgroundColor: Colors.white,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF1A1A1A)),
          bodyMedium: TextStyle(color: Color(0xFF1A1A1A)),
          titleLarge: TextStyle(color: Color(0xFF1A1A1A)),
          titleMedium: TextStyle(color: Color(0xFF1A1A1A)),
        ),
        listTileTheme: ListTileThemeData(
          textColor: Color(0xFF1A1A1A),
          iconColor: Color(0xFF666666),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: _primaryColor,
          unselectedItemColor: Color(0xFF999999),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: _primaryColor,
          thumbColor: _primaryColor,
          inactiveTrackColor: Color(0xFFD0D0D0),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.all(Colors.white),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return _primaryColor;
            return Color(0xFFD0D0D0);
          }),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: _primaryColor),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Color(0xFF333333),
          contentTextStyle: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Color(0xFF666666)),
      );
    }
  }

  Color textColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  Color subtitleColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface.withOpacity(0.55);
  }

  Color hintColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface.withOpacity(0.35);
  }

  Color cardBgColor(BuildContext context) {
    return Theme.of(context).cardColor;
  }

  Color searchFieldBgColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.05);
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt('primary_color');
    if (colorValue != null) {
      _primaryColor = Color(colorValue);
    }
    _isDarkMode = prefs.getBool('is_dark_mode') ?? true;
    notifyListeners();
  }

  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('primary_color', color.value);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', _isDarkMode);
    notifyListeners();
  }
}
