/// iOS Human Interface Guidelines 기반 간격 시스템
class AppSpacing {
  // Spacing - iOS 표준
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double sm = 8.0; // Alias
  static const double m = 16.0;
  static const double md = 16.0; // Alias
  static const double l = 20.0; // iOS 표준 여백
  static const double lg = 24.0; // Alias
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Radius - iOS 스타일 (더 큰 둥글기)
  static const double radiusXs = 6.0;
  static const double radiusS = 10.0;
  static const double radius = 12.0; // iOS 기본
  static const double radiusL = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusXxl = 28.0; // iOS 큰 카드용

  // Layout
  static const double screenPadding = 16.0; // iOS 표준 화면 패딩
  static const double sectionSpacing = 20.0; // 섹션 간 간격

  // iOS 터치 영역 (최소 44pt)
  static const double minTouchTarget = 44.0;

  // iOS 네비게이션 바 높이
  static const double navBarHeight = 44.0;
  static const double largeNavBarHeight = 96.0;
}
