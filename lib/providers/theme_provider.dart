import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? true;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _themeMode == ThemeMode.dark);
    notifyListeners();
  }

  // Light Theme
  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F7FA),
    primaryColor: const Color(0xFF3E5EF1),
    fontFamily: 'Inter',
    
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF3E5EF1),
      secondary: Color(0xFF3E5EF1),
      surface: Colors.white,
      background: Color(0xFFF5F7FA),
      error: Color(0xFFEF4444),
    ),
    
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF5F7FA),
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF1A202C)),
      titleTextStyle: TextStyle(
        color: Color(0xFF1A202C),
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
    ),
    
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: Color(0xFF1A202C),
        fontSize: 32,
        fontWeight: FontWeight.w700,
        fontFamily: 'Inter',
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        color: Color(0xFF1A202C),
        fontSize: 24,
        fontWeight: FontWeight.w700,
        fontFamily: 'Inter',
        letterSpacing: -0.3,
      ),
      displaySmall: TextStyle(
        color: Color(0xFF1A202C),
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
      bodyLarge: TextStyle(
        color: Color(0xFF1A202C),
        fontSize: 16,
        fontWeight: FontWeight.w400,
        fontFamily: 'Inter',
      ),
      bodyMedium: TextStyle(
        color: Color(0xFF718096),
        fontSize: 14,
        fontWeight: FontWeight.w400,
        fontFamily: 'Inter',
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3E5EF1),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3E5EF1), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );

  // Dark Theme
  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF1A1D2E),
    primaryColor: const Color(0xFF3E5EF1),
    fontFamily: 'Inter',
    
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF3E5EF1),
      secondary: Color(0xFF3E5EF1),
      surface: Color(0xFF2D3446),
      background: Color(0xFF1A1D2E),
      error: Color(0xFFEF4444),
    ),
    
    cardTheme: CardThemeData(
      color: const Color(0xFF2D3446),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF3D4556), width: 1),
      ),
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A1D2E),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
    ),
    
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        fontFamily: 'Inter',
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        fontFamily: 'Inter',
        letterSpacing: -0.3,
      ),
      displaySmall: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
      bodyLarge: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        fontFamily: 'Inter',
      ),
      bodyMedium: TextStyle(
        color: Color(0xFFA0AEC0),
        fontSize: 14,
        fontWeight: FontWeight.w400,
        fontFamily: 'Inter',
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3E5EF1),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2D3446),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3D4556)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3D4556)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3E5EF1), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );
}