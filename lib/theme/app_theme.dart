import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: Colors.red,
      scaffoldBackgroundColor: Colors.white,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        color: Colors.red,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        displayMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: Colors.red,
        textTheme: ButtonTextTheme.primary,
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: Colors.red,
        secondary: Colors.redAccent,
        brightness: Brightness.light,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey[200]!,
        disabledColor: Colors.grey[300]!,
        selectedColor: Colors.red,
        secondarySelectedColor: Colors.redAccent,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        labelStyle: const TextStyle(color: Colors.black87),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        brightness: Brightness.light,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: Colors.red,
      scaffoldBackgroundColor: const Color(0xFF121212),
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        color: Colors.grey[900]!,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displayMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.white60),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: Colors.red,
        textTheme: ButtonTextTheme.primary,
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: Colors.red,
        secondary: Colors.redAccent,
        brightness: Brightness.dark,
        surface: const Color(0xFF1E1E1E),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey[800]!,
        disabledColor: Colors.grey[700]!,
        selectedColor: Colors.red,
        secondarySelectedColor: Colors.redAccent,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        labelStyle: const TextStyle(color: Colors.white70),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        brightness: Brightness.dark,
      ),
      cardColor: const Color(0xFF1E1E1E),
      dividerColor: Colors.grey[800],
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  // Utility class to check if current theme is dark
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
}
