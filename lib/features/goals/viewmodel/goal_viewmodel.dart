// 파일 위치: lib/features/goals/viewmodel/goal_viewmodel.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../data/models/goal.dart';
import '../../../../data/repositories/goal_repository.dart';
import '../../../core/utils/custom_logger.dart';

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
  Future<void> toggleCheck(Goal currentGoal, int dayIndex) async {
    // 현재 상태가 데이터가 아니면 무시
    if (!state.hasValue) return;

    final now = DateTime.now();

    try {
      // 체크 상태 변경 (불변성 유지를 위해 복사본 생성)
      List<bool> newChecks = List.from(currentGoal.checks);
      int newSuccessCount = currentGoal.successCount;

      if (dayIndex == 0 && newChecks[1] == false && newChecks[2] == false) {
        newChecks[dayIndex] = !newChecks[dayIndex];
      } else if (dayIndex == 1 &&
          newChecks[0] == true &&
          newChecks[2] == false) {
        newChecks[dayIndex] = !newChecks[dayIndex];
      } else if (dayIndex == 2 &&
          newChecks[0] == true &&
          newChecks[1] == true) {
        if (newChecks[2] == false) newSuccessCount++;
        if (newChecks[2] == true) newSuccessCount--;
        newChecks[dayIndex] = !newChecks[dayIndex];

        //
      }

      // 업데이트된 목표 객체 생성
      final updatedGoal = currentGoal.copyWith(
        checks: newChecks,

        successCount: newSuccessCount,
        lastUpdatedDate: now,
      );

      // DB 저장
      await _repository.saveGoal(updatedGoal);

      // 중요: 로컬 상태만 즉시 업데이트 (UI 반응 속도를 위해)
      // 리스트에서 해당 목표만 교체하여 새로운 리스트 생성
      final currentGoals = state.value!;
      final goalIndex = currentGoals.indexWhere((g) => g.id == currentGoal.id);
      final newGoalList = List<Goal>.from(currentGoals);
      newGoalList[goalIndex] = updatedGoal;

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
}
