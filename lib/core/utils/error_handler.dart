import 'logger.dart';

/// [ErrorHandler]
/// 앱 전역에서 발생하는 에러를 중앙에서 관리하는 클래스입니다.
class ErrorHandler {
  /// 에러를 로깅하고, 사용자에게 보여줄 메시지를 반환하거나 처리합니다.
  static void handleError(dynamic error,
      {StackTrace? stackTrace, String? message}) {
    // 1. 개발자를 위해 로그 출력
    CustomLogger.error(message ?? "알 수 없는 에러 발생", error, stackTrace);

    // 2. 필요하다면 여기서 사용자에게 보여줄 스낵바(Toast) 등을 띄우는 로직 추가 가능
    // (Context가 필요한 경우 등은 추후 구현)
  }
}
