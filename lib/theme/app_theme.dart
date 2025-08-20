import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/button_theme.dart';

class AppTheme {
  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      textTheme: GoogleFonts.robotoTextTheme(),
      brightness: Brightness.light,
      elevatedButtonTheme: elevatedButtonTheme,
    );
  }
}
