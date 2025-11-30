// lib/core/utils/custom_logger.dart

import 'dart:developer' as developer; // Dart의 기본 로그 기능을 사용합니다.

// 앱 전체에서 사용할 커스터마이징된 로거 클래스입니다.
// 개발 단계(디버그 모드)에서만 로그를 출력하도록 설정할 수 있습니다.
class CustomLogger {
  // 로그 메시지의 접두사 (앱 이름 등을 사용하여 로그 필터링에 유용합니다)
  static const String _tag = "PerfectThreeLog"; 

  // 디버그 레벨 로그
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    // developer.log를 사용하여 더 상세한 로그 정보를 기록합니다.
    developer.log(
      message,
      name: '$_tag.DEBUG', // 로그 이름
      error: error, // 관련 오류 객체
      stackTrace: stackTrace, // 스택 트레이스
    );
  }

  // 정보 레벨 로그
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: '$_tag.INFO',
      error: error,
      stackTrace: stackTrace,
    );
  }

  // 경고 레벨 로그
  static void warn(String message, [dynamic error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: '$_tag.WARN',
      error: error,
      stackTrace: stackTrace,
    );
  }

  // 에러 레벨 로그
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    // 에러 로그는 중요하므로 더 눈에 띄게 출력할 수 있습니다.
    developer.log(
      "❌ $message", // 에러임을 시각적으로 강조합니다.
      name: '$_tag.ERROR',
      error: error,
      stackTrace: stackTrace,
    );
  }
}