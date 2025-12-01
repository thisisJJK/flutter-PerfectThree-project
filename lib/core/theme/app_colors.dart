import 'package:flutter/material.dart';

class AppColors {
  // Light
  static const background = Color(0xFFF8F9FA);
  static const textPrimary = Color(0xFF1C1C1E);
  static const textSecondary = Color(0xFF6E6E73);
  static const primary = Color(0xFF4CAF50);
  static const accent = Color(0xFF00A8E8);
  static const divider = Color(0xFFE5E5EA);
  static const card = Colors.white;

  // Dark
  static const backgroundDark = Color(0xFF121212);
  static const textPrimaryDark = Color(0xFFF8F9FA);
  static const textSecondaryDark = Color(0xFFB0B0B0);
  static const primaryDark = Color(0xFF81C784);
  static const accentDark = Color(0xFF00B0FF);
  static const dividerDark = Color(0xFF303030);
  static const cardDark = Color(0xFF1E1E1E);

  // Category Colors
  static const Map<String, Color> categoryColors = {
    '일상': Color(0xFF42A5F5), // Blue
    '아침': Color(0xFFFFA726), // Orange
    '점심': Color.fromARGB(255, 255, 234, 45), // Yellow
    '저녁': Color(0xFF5C6BC0), // Indigo
    '운동': Color(0xFFEF5350), // Red
    '업무': Color(0xFF26C6DA), // Cyan
    '자기계발': Color(0xFFAB47BC), // Purple
    '기타': Color(0xFFBDBDBD), // Grey
    '전체': primary, // Default
  };

  static Color getCategoryColor(String category) {
    return categoryColors[category] ?? primary;
  }
}
