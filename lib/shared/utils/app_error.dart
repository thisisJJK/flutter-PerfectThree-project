// lib/core/utils/app_error.dart

// 앱 내에서 발생하는 커스텀 에러들을 정의하는 클래스입니다.
// 이 클래스를 사용하면 어떤 종류의 에러가 발생했는지 명확하게 알 수 있습니다.
class AppError implements Exception {
  // 에러를 식별하는 코드 또는 키
  final String code;
  // 사용자에게 보여줄 메시지 (현지화 키를 사용할 수 있습니다)
  final String message;
  // 실제 발생한 원본 에러 (선택 사항)
  final dynamic originalError;

  // 생성자
  AppError({required this.code, required this.message, this.originalError});

  // 오류 내용을 문자열로 표현하여 로그 출력 등에 사용합니다.
  @override
  String toString() {
    return 'AppError($code): $message${originalError != null ? ' - Original Error: $originalError' : ''}';
  }
}

// 목표 관련 에러 (예: 목표를 찾을 수 없을 때)
class GoalError extends AppError {
  GoalError({required super.code, required super.message, super.originalError});
}

// Hive 데이터베이스 관련 에러
class DatabaseError extends AppError {
  DatabaseError({
    required super.code,
    required super.message,
    super.originalError,
  });
}

// 필요한 경우 다른 종류의 에러 클래스를 추가할 수 있습니다.
