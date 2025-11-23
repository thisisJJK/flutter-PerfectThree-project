// 파일 위치: lib/features/goals/viewmodel/goal_viewmodel.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/logger.dart';
import '../../../../data/models/goal.dart';
import '../../../../data/repositories/goal_repository.dart';

part 'goal_viewmodel.g.dart';

/// [GoalViewModel]
/// 목표 리스트의 상태를 관리하고, 핵심 비즈니스 로직(3일 체크, 리셋 등)을 수행합니다.
@riverpod
class GoalViewModel extends _$GoalViewModel {
  late GoalRepository _repository;

  /// 1. 초기화 (build)
  /// 앱이 시작되거나 이 화면이 로드될 때 실행됩니다.
  @override
  Future<List<Goal>> build() async {
    // Repository를 가져옵니다.
    _repository = ref.watch(goalRepositoryProvider);

    // 저장된 목표들을 불러옵니다.
    List<Goal> goals = await _repository.getGoals();

    // 날짜가 바뀌었는지 확인하고 리셋 로직을 실행합니다.
    goals = await _checkDailyReset(goals);

    return goals;
  }

  /// 2. 목표 추가 (Create)
  Future<void> addGoal(String title) async {
    state = const AsyncValue.loading(); // 로딩 상태로 변경 (UI 반응용)

    try {
      final newGoal = Goal.create(
        id: const Uuid().v4(), // 고유 ID 생성
        title: title,
      );

      // DB에 저장
      await _repository.saveGoal(newGoal);

      // 상태 새로고침 (목록 다시 불러오기)
      ref.invalidateSelf();
      CustomLogger.info("새 목표 추가됨: $title");
    } catch (e, stackTrace) {
      CustomLogger.error("목표 추가 중 에러", e, stackTrace);
      state = AsyncValue.error(e, stackTrace); // 에러 상태 전파
    }
  }

  /// 3. 체크박스 토글 (Update)
  /// [dayIndex]: 0 (1일차), 1 (2일차), 2 (3일차)
  Future<void> toggleCheck(String goalId, int dayIndex) async {
    // 현재 상태가 데이터가 아니면 무시
    if (!state.hasValue) return;

    try {
      // 현재 리스트에서 해당 목표 찾기
      final currentGoals = state.value!;
      final targetGoal = currentGoals.firstWhere((g) => g.id == goalId);

      // 체크 상태 변경 (불변성 유지를 위해 복사본 생성)
      List<bool> newChecks = List.from(targetGoal.checks);

      if (dayIndex == 2 &&
          newChecks[dayIndex - 1] == true &&
          newChecks[dayIndex - 2] == true) {
        newChecks[dayIndex] = !newChecks[dayIndex]; // 토글 (true <-> false)
      } else if (dayIndex == 2 &&
          newChecks[dayIndex - 1] == false &&
          newChecks[dayIndex - 2] == false) {
        return;
      } else if (newChecks[dayIndex + 1] == false) {
        if (dayIndex == 0 || dayIndex > 0 && newChecks[dayIndex - 1] == true) {
          newChecks[dayIndex] = !newChecks[dayIndex]; // 토글 (true <-> false)
        } else {
          return;
        }
      }

      // 업데이트된 목표 객체 생성
      final updatedGoal = targetGoal.copyWith(
        checks: newChecks,
        lastUpdatedDate: DateTime.now(), // 마지막 수정 시간 갱신
      );

      // DB 저장
      await _repository.saveGoal(updatedGoal);

      // 중요: 로컬 상태만 즉시 업데이트 (UI 반응 속도를 위해)
      // 리스트에서 해당 목표만 교체하여 새로운 리스트 생성
      final newGoalList = currentGoals.map((g) {
        return g.id == goalId ? updatedGoal : g;
      }).toList();

      state = AsyncValue.data(newGoalList);

      CustomLogger.debug(
        "체크박스 변경: ${updatedGoal.title} [$dayIndex] -> ${newChecks[dayIndex]}",
      );
    } catch (e, stackTrace) {
      CustomLogger.error("체크박스 토글 실패", e, stackTrace);
    }
  }

  /// 4. 목표 삭제 (Delete)
  Future<void> deleteGoal(String goalId) async {
    try {
      await _repository.deleteGoal(goalId);

      // 상태에서 해당 목표 제거 (UI 즉시 반영)
      if (state.hasValue) {
        final newGoalList = state.value!.where((g) => g.id != goalId).toList();
        state = AsyncValue.data(newGoalList);
      }
      CustomLogger.info("목표 삭제됨: $goalId");
    } catch (e, stackTrace) {
      CustomLogger.error("목표 삭제 실패", e, stackTrace);
    }
  }

  /// [핵심 로직] 날짜 변경 및 3일 리셋 체크
  /// 앱 실행 시 호출되어, "3일 다 채운 목표"가 "다음 날"이 되었는지 확인합니다.
  Future<List<Goal>> _checkDailyReset(List<Goal> goals) async {
    // ignore: unused_local_variable
    bool listChanged = false;
    List<Goal> processedGoals = [];
    final now = DateTime.now();

    for (var goal in goals) {
      // 3일 모두 체크되었는지 확인
      bool isCompleted = goal.checks.every((check) => check == true);

      if (isCompleted) {
        // 마지막 업데이트 날짜와 오늘 날짜가 다르면 (즉, 하루가 지났으면)
        if (!_isSameDay(goal.lastUpdatedDate, now)) {
          CustomLogger.info("🔄 3일 반복 성공! 리셋 진행: ${goal.title}");

          // 성공 횟수 증가 + 체크박스 초기화
          final resetGoal = goal.copyWith(
            successCount: goal.successCount + 1,
            checks: [false, false, false],
            lastUpdatedDate: now,
          );

          // DB 업데이트
          await _repository.saveGoal(resetGoal);
          processedGoals.add(resetGoal);
          listChanged = true;
          continue;
        }
      }
      processedGoals.add(goal);
    }

    return processedGoals;
  }

  /// 두 날짜가 같은 날인지 확인하는 헬퍼 함수
  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }
}
