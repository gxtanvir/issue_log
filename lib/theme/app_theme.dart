import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/button_theme.dart';

class AppTheme {
  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      textTheme: GoogleFonts.robotoTextTheme(),
      brightness: Brightness.light,
      // scaffoldBackgroundColor: const Color.fromARGB(20, 106, 168, 204),
      appBarTheme: AppBarThemeData().copyWith(
        backgroundColor: const Color.fromARGB(255, 56, 75, 112),
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      elevatedButtonTheme: elevatedButtonTheme,
    );
  }
}
