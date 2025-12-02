import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

/// iOS 스타일 폰트 시스템
/// SF Pro Display/Text 스타일 (Inter 폰트 사용)
class Font {
  Font._();

  // iOS 본문 텍스트용 (SF Pro Text 스타일)
  static TextStyle get main => GoogleFonts.inter(
    letterSpacing: -0.3, // iOS 스타일 자간
  );

  // iOS 헤더용 (SF Pro Display 스타일)
  static TextStyle get display => GoogleFonts.inter(
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5, // iOS 디스플레이 자간
  );

  // 한글 전용 폰트 (필요시)
  static TextStyle get korean => GoogleFonts.notoSansKr();

  // 제목용 (Jua - 기존 호환성)
  static TextStyle get jua => GoogleFonts.jua();
}

/// iOS 스타일 테마
class AppTheme {
  /// 라이트 모드 테마 - iOS 스타일
  static ThemeData light = ThemeData(
    fontFamily: GoogleFonts.inter().fontFamily,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      error: AppColors.error,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.textPrimary,
      onError: AppColors.white,
    ),
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,

    // iOS 스타일 AppBar
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0, // iOS 스타일 - 스크롤시에도 그림자 없음
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 34, // iOS Large Title 크기
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: AppColors.textPrimary,
      ),
    ),

    // iOS 스타일 카드
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shadowColor: AppColors.shadowLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        side: BorderSide(
          color: AppColors.divider.withValues(alpha: 0.3),
          width: 0.5, // iOS 스타일 얇은 테두리
        ),
      ),
      margin: EdgeInsets.zero,
    ),

    // iOS 스타일 구분선
    dividerColor: AppColors.divider,
    dividerTheme: DividerThemeData(
      color: AppColors.divider,
      thickness: 0.5, // iOS 스타일 얇은 구분선
      space: 1,
    ),

    useMaterial3: true,
  );

  /// 다크 모드 테마 - iOS 스타일
  static ThemeData dark = ThemeData(
    fontFamily: GoogleFonts.inter().fontFamily,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryDarkColor,
      secondary: AppColors.accentLight,
      surface: AppColors.surfaceDark,
      error: AppColors.error,
      onPrimary: AppColors.black,
      onSecondary: AppColors.black,
      onSurface: AppColors.textPrimaryDark,
      onError: AppColors.black,
    ),
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.backgroundDark,

    // iOS 스타일 AppBar (다크)
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppColors.backgroundDark,
      foregroundColor: AppColors.textPrimaryDark,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 34, // iOS Large Title 크기
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: AppColors.textPrimaryDark,
      ),
    ),

    // iOS 스타일 카드 (다크)
    cardTheme: CardThemeData(
      color: AppColors.surfaceDark,
      elevation: 0,
      shadowColor: AppColors.shadowDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        side: BorderSide(
          color: AppColors.dividerDark.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      margin: EdgeInsets.zero,
    ),

    // iOS 스타일 구분선 (다크)
    dividerColor: AppColors.dividerDark,
    dividerTheme: DividerThemeData(
      color: AppColors.dividerDark,
      thickness: 0.5,
      space: 1,
    ),

    useMaterial3: true,
  );
}
