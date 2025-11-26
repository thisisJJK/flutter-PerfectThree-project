import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class Font {
  Font._();
  static TextStyle get jua => GoogleFonts.jua();
}

class AppTheme {
  static ThemeData light = ThemeData(
    fontFamily: Font.jua.fontFamily,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
    ),
    // textTheme: GoogleFonts.juaTextTheme(),
    cardColor: AppColors.card,
    dividerColor: AppColors.divider,
    useMaterial3: true,
  );

  static ThemeData dark = ThemeData(
    fontFamily: Font.jua.fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryDark,
      brightness: Brightness.dark,
    ),
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.backgroundDark,
      foregroundColor: AppColors.textPrimaryDark,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(),
    cardColor: AppColors.cardDark,
    dividerColor: AppColors.dividerDark,
    useMaterial3: true,
  );
}
