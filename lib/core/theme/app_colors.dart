import 'package:flutter/material.dart';

/// iOS 스타일 색상 시스템
/// Apple Human Interface Guidelines 기반
class AppColors {
  // Base Colors
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);

  // Light Mode - iOS 스타일
  static const background = Color(0xFFF2F2F7); // iOS 시스템 배경 (System Gray 6)
  static const backgroundSecondary = Color(0xFFFFFFFF); // 순백색 배경
  static const surface = Color(0xFFFFFFFF);
  static const surfaceElevated = Color(0xFFFAFAFA); // 약간 올라온 표면

  static const textPrimary = Color(0xFF000000); // iOS 기본 텍스트
  static const textSecondary = Color(
    0xFF3C3C43,
  ); // iOS Secondary Label (60% opacity)
  static const textTertiary = Color(0xFF8E8E93); // iOS Tertiary Label
  static const textQuaternary = Color(0xFFC7C7CC); // iOS Quaternary Label

  static const divider = Color(0xFFE5E5EA); // iOS Separator
  static const dividerOpaque = Color(0xFFC6C6C8); // iOS Opaque Separator

  // Dark Mode - iOS 스타일
  static const backgroundDark = Color(0xFF000000); // iOS 다크 배경
  static const backgroundSecondaryDark = Color(
    0xFF1C1C1E,
  ); // iOS System Gray 6 Dark
  static const surfaceDark = Color(0xFF1C1C1E);
  static const surfaceElevatedDark = Color(
    0xFF2C2C2E,
  ); // iOS System Gray 5 Dark

  static const textPrimaryDark = Color(0xFFFFFFFF);
  static const textSecondaryDark = Color(
    0xFFEBEBF5,
  ); // iOS Secondary Label Dark (60% opacity)
  static const textTertiaryDark = Color(0xFFAEAEB2); // iOS Tertiary Label Dark
  static const textQuaternaryDark = Color(
    0xFF636366,
  ); // iOS Quaternary Label Dark

  static const dividerDark = Color(0xFF38383A); // iOS Separator Dark
  static const dividerOpaqueDark = Color(
    0xFF48484A,
  ); // iOS Opaque Separator Dark

  // iOS System Colors - Accent
  static const iosBlue = Color(0xFF007AFF); // iOS 시스템 블루
  static const iosGreen = Color(0xFF34C759); // iOS 시스템 그린
  static const iosIndigo = Color(0xFF5856D6); // iOS 시스템 인디고
  static const iosOrange = Color(0xFFFF9500); // iOS 시스템 오렌지
  static const iosPink = Color(0xFFFF2D55); // iOS 시스템 핑크
  static const iosPurple = Color(0xFFAF52DE); // iOS 시스템 퍼플
  static const iosRed = Color(0xFFFF3B30); // iOS 시스템 레드
  static const iosTeal = Color(0xFF5AC8FA); // iOS 시스템 틸
  static const iosYellow = Color(0xFFFFCC00); // iOS 시스템 옐로우

  // Brand Colors - 오션 블루 테마
  static const primary = iosBlue; // iOS 블루 사용
  static const primaryLight = Color(0xFF0A84FF); // iOS Blue Dark (밝은 버전)
  static const primaryDarkColor = Color(0xFF0A84FF); // 다크모드용 밝은 블루
  static const primaryDark = primaryDarkColor;

  static const accent = iosTeal; // iOS 틸 사용
  static const accentLight = Color(0xFF64D2FF); // 밝은 틸

  // Semantic Colors - iOS 스타일
  static const success = iosGreen;
  static const error = iosRed;
  static const warning = iosOrange;
  static const info = iosBlue;

  // Category Colors - iOS 시스템 컬러 사용
  static const Map<String, Color> categoryColors = {
    '일상': iosTeal, // Teal
    '아침': iosOrange, // Orange
    '점심': iosYellow, // Yellow
    '저녁': iosIndigo, // Indigo
    '운동': iosRed, // Red
    '업무': iosBlue, // Blue
    '자기계발': iosPurple, // Purple
    '기타': Color(0xFF8E8E93), // iOS Gray
    '전체': primary, // Default
  };

  // iOS 스타일 그림자 색상
  static const shadowLight = Color(0x1A000000); // 10% 불투명도
  static const shadowMedium = Color(0x33000000); // 20% 불투명도
  static const shadowDark = Color(0x4D000000); // 30% 불투명도

static Color getCategoryColor(String category) {
    return categoryColors[category] ?? primary;
  }
}
