import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

enum AppThemeMode { light, dark, custom }

class ThemeController extends ChangeNotifier {
  AppThemeMode _currentMode = AppThemeMode.dark;

  AppThemeMode get currentMode => _currentMode;

  void setMode(AppThemeMode mode) {
    if (_currentMode != mode) {
      _currentMode = mode;
      notifyListeners();
    }
  }

  ThemeData get currentTheme {
    switch (_currentMode) {
      case AppThemeMode.light:
        return _lightTheme;
      case AppThemeMode.custom:
        return _customTheme;
      case AppThemeMode.dark:
        return _darkTheme;
    }
  }

  // ChatTheme get chatTheme {
  //   switch (_currentMode) {
  //     case AppThemeMode.light:
  //       return  DefaultChatTheme(
  //         backgroundColor: Color(0xFFF5F5F5),
  //         primaryColor: Color(0xFF10A37F),
  //         secondaryColor: Colors.white,
  //         inputBackgroundColor: Colors.white,
  //         inputTextColor: Colors.black,
  //         receivedMessageBodyTextStyle: TextStyle(
  //           color: Colors.black,
  //           fontSize: 16,
  //         ),
  //         sentMessageBodyTextStyle: TextStyle(
  //           color: Colors.white,
  //           fontSize: 16,
  //         ),
  //       );
  //     case AppThemeMode.custom:
  //       return const DarkAppChatTheme(

  //         backgroundColor: Color(0xFF0F172A),
  //         primaryColor: Color(0xFF38BDF8),
  //         secondaryColor: Color(0xFF1E293B),
  //         inputBackgroundColor: Color(0xFF1E293B),
  //         inputTextColor: Colors.white,
  //       );
  //     case AppThemeMode.dark:
  //     default:
  //       return const DarkChatTheme(
  //         backgroundColor: Color(0xFF343541),
  //         primaryColor: Color(0xFF19C37D),
  //         secondaryColor: Color(0xFF444654),
  //         inputBackgroundColor: Color(0xFF40414F),
  //         inputTextColor: Colors.white,
  //       );
  //   }
  // }

  static final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF343541),
    primaryColor: const Color(0xFF19C37D),
    cardColor: const Color(0xFF444654),
    dialogBackgroundColor: const Color(0xFF202123),
    dividerColor: Colors.white24,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF19C37D),
      surface: Color(0xFF343541),
      secondary: Color(0xFF444654),
      tertiary: Color(0xFF202123),
      onSurface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF343541),
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF40414F),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: Colors.grey),
    ),
    useMaterial3: true,
    fontFamily: 'Roboto',
  );

  static final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    primaryColor: const Color(0xFF10A37F),
    cardColor: Colors.white,
    dialogBackgroundColor: Colors.white,
    dividerColor: Colors.black12,
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF10A37F),
      surface: Colors.white,
      secondary: Color(0xFFEEEEEE),
      tertiary: Color(0xFFF5F5F5),
      onSurface: Colors.black87,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.black87),
      titleTextStyle: TextStyle(
        color: Colors.black87,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      elevation: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      hintStyle: TextStyle(color: Colors.grey),
    ),
    useMaterial3: true,
    fontFamily: 'Roboto',
  );

  static final ThemeData _customTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0F172A),
    primaryColor: const Color(0xFF38BDF8),
    cardColor: const Color(0xFF1E293B),
    dialogBackgroundColor: const Color(0xFF020617),
    dividerColor: Colors.white10,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF38BDF8),
      surface: Color(0xFF0F172A),
      secondary: Color(0xFF1E293B),
      tertiary: Color(0xFF1E293B),
      onSurface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0F172A),
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E293B),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.white10),
      ),
      hintStyle: TextStyle(color: Colors.blueGrey),
    ),
    useMaterial3: true,
    fontFamily: 'Roboto',
  );
}
