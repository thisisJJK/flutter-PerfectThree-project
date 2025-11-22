
import 'package:logger/logger.dart';

/// [CustomLogger]
/// 앱 전체에서 사용할 커스텀 로거 클래스입니다.
/// 
/// 사용법:
/// CustomLogger.debug("디버그 메시지");
/// CustomLogger.error("에러 발생", errorObject);
class CustomLogger {
  // Logger 인스턴스 생성 (예쁜 출력을 위해 PrettyPrinter 사용)
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0, // 불필요한 스택 트레이스 숨김
      errorMethodCount: 8, // 에러 발생 시 스택 트레이스 라인 수
      lineLength: 120, // 로그 한 줄의 길이
      colors: true, // 알록달록한 컬러 출력
      printEmojis: true, // 이모지 사용
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, // 시간 표시
    ),
  );

  /// 디버그 레벨 로그 (개발 중 일반적인 정보 확인용)
  static void debug(String message) {
    _logger.d("🐛 DEBUG: $message");
  }

  /// 인포 레벨 로그 (중요한 흐름 확인용)
  static void info(String message) {
    _logger.i("ℹ️ INFO: $message");
  }

  /// 워닝 레벨 로그 (잠재적인 문제 확인용)
  static void warning(String message) {
    _logger.w("⚠️ WARNING: $message");
  }

  /// 에러 레벨 로그 (심각한 오류 발생 시)
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e("🚨 ERROR: $message", error: error, stackTrace: stackTrace);
  }
}