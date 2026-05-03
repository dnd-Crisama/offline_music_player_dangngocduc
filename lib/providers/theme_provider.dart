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
          thumbColor: MaterialStateProperty.all(Colors.white),
          trackColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) return _primaryColor;
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
      );
    } else {
      return ThemeData(
        brightness: Brightness.light,
        primaryColor: _primaryColor,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.light(
          primary: _primaryColor,
          secondary: _primaryColor,
          surface: Colors.white,
          onSurface: Colors.black87,
          onPrimary: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardColor: Colors.grey[200],
        dialogBackgroundColor: Colors.white,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black87),
          titleLarge: TextStyle(color: Colors.black87),
          titleMedium: TextStyle(color: Colors.black87),
        ),
        listTileTheme: ListTileThemeData(
          textColor: Colors.black87,
          iconColor: Colors.black54,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: _primaryColor,
          unselectedItemColor: Colors.grey,
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: _primaryColor,
          thumbColor: _primaryColor,
          inactiveTrackColor: Colors.grey[300],
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.all(Colors.white),
          trackColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) return _primaryColor;
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
      );
    }
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
