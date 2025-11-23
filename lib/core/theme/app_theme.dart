import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
    ),
    textTheme: const TextTheme(
      bodyLarge: AppTypography.body,
      bodyMedium: AppTypography.body,
      bodySmall: AppTypography.caption,
    ),
    cardColor: AppColors.card,
    dividerColor: AppColors.divider,
    useMaterial3: true,
  );

  static ThemeData dark = ThemeData(
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
    textTheme: const TextTheme(
      bodyLarge: AppTypography.body, // 폰트 색상은 위 AppColors를 참조해서 다크 대응
      bodyMedium: AppTypography.body,
      bodySmall: AppTypography.caption,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(),
    cardColor: AppColors.cardDark,
    dividerColor: AppColors.dividerDark,
    useMaterial3: true,
  );
}
