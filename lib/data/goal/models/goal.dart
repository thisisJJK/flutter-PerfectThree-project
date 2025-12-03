import 'package:hive/hive.dart';
import 'package:perfect_three/shared/utils/date_utils.dart';

part 'goal.g.dart';

/// [Goal]
/// 사용자의 목표 정보를 담는 데이터 모델입니다.
/// Hive 데이터베이스에 저장하기 위해 @HiveType을 사용합니다.
@HiveType(typeId: 0) // typeId는 모델마다 고유해야 합니다. (0번 할당)
class Goal extends HiveObject {
  @HiveField(0)
  final String id; // 고유 ID (UUID)

  @HiveField(1)
  String title; // 목표 이름

  @HiveField(2)
  List<bool> checks; // 3일 체크 현황 [true, false, false]

  @HiveField(3)
  int successCount; // 3일 성공 누적 횟수

  @HiveField(4)
  DateTime lastUpdatedDate; // 마지막으로 체크한 날짜

  @HiveField(5)
  bool isOngoing; // 진행중인지

  @HiveField(6)
  int sortOrder; // 순서 정렬용

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  bool lastDay;

  @HiveField(9)
  String category;

  @HiveField(10)
  List<DateTime> successDates; // 성공한 날짜 기록

  Goal({
    required this.id,
    required this.title,
    required this.checks,
    this.successCount = 0,
    required this.lastUpdatedDate,
    required this.isOngoing,
    required this.sortOrder,
    required this.createdAt,
    this.lastDay = false,
    required this.category,
    required this.successDates,
  });

  /// 초기 목표 생성을 위한 팩토리 메서드
  factory Goal.create({
    required String id,
    required String title,
    required bool isOngoing,
    required int sortOrder,
    required DateTime createdAt,
    required String category,
  }) {
    return Goal(
      id: id,
      title: title,
      checks: [false, false, false], // 처음엔 모두 미달성
      successCount: 0,
      lastUpdatedDate: DateUtils.now(),
      isOngoing: isOngoing,
      sortOrder: sortOrder,
      createdAt: createdAt,
      lastDay: false,
      category: category,
      successDates: [],
    );
  }

  // 데이터를 수정할 때 원본을 건드리지 않고 새로운 복사본을 만드는 메서드 (불변성 유지)
  Goal copyWith({
    String? title,
    List<bool>? checks,
    int? successCount,
    DateTime? lastUpdatedDate,
    bool? isOngoing,
    int? sortOrder,
    DateTime? createdAt,
    bool? lastDay,
    String? category,
    List<DateTime>? successDates,
  }) {
    return Goal(
      id: id, // ID는 변경 불가
      title: title ?? this.title,
      checks: checks ?? this.checks,
      successCount: successCount ?? this.successCount,
      lastUpdatedDate: lastUpdatedDate ?? this.lastUpdatedDate,
      isOngoing: isOngoing ?? this.isOngoing,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      lastDay: lastDay ?? this.lastDay,
      category: category ?? this.category,
      successDates: successDates ?? this.successDates,
    );
  }
}
