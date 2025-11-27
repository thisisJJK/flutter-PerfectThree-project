// 파일 위치: lib/features/goals/viewmodel/goal_viewmodel.dart

import 'package:perfect_three/core/utils/date_utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../data/models/goal.dart';
import '../../../../data/repositories/goal_repository.dart';
import '../../../core/utils/custom_logger.dart';

part 'goal_viewmodel.g.dart';

@riverpod
class GoalViewModel extends _$GoalViewModel {
  late GoalRepository _repository;
  String _category = '일상';
  bool isStatsScreen = false;

  @override
  Future<List<Goal>> build() async {
    final goals = await getGoals();
    state = AsyncValue.data(goals);
    return goals;
  }

  Future<List<Goal>> getGoals() async {
    _repository = ref.watch(goalRepositoryProvider);
    await _resetFailedGoals();
    List<Goal> updatedGoals = await _repository.getGoals();
    return updatedGoals;
  }

  Future<void> addGoal(String title) async {
    state = const AsyncValue.loading();

    try {
      final now = DateUtils.now();
      final current = state.value ?? [];
      final newGoal = Goal.create(
        id: const Uuid().v4(), // 고유 ID 생성
        title: title,
        isOngoing: true,
        sortOrder: 0,
        createdAt: now,
        category: _category,
      );

      final updated = [
        newGoal,
        for (var goal in current) goal.copyWith(sortOrder: goal.sortOrder + 1),
      ];

      // DB에 저장
      await _repository.saveGoals(updated);

      // 상태 새로고침 (목록 다시 불러오기)
      ref.invalidateSelf();
      CustomLogger.info("새 목표 추가됨: $title");
    } catch (e, stackTrace) {
      CustomLogger.error("목표 추가 중 에러", e, stackTrace);
      state = AsyncValue.error(e, stackTrace); // 에러 상태 전파
    }
  }

  Future<void> toggleCheck(Goal currentGoal, int dayIndex) async {
    // 현재 상태가 데이터가 아니면 무시
    if (!state.hasValue) return;

    try {
      List<bool> newChecks = List.from(currentGoal.checks);
      int newSuccessCount = currentGoal.successCount;

      final now = DateUtils.now();
      DateTime createdDay = DateUtils.dateOnly(currentGoal.createdAt);
      bool isSame = DateUtils.differenceDay(now, createdDay) % 3 == dayIndex;

      if (isSame) {
        if (dayIndex == 0 || dayIndex == 1) {
          newChecks[dayIndex] = !newChecks[dayIndex];
          if (dayIndex == 1) {
            currentGoal.lastDay = !currentGoal.lastDay;
          }
        } else if (dayIndex == 2 && newChecks[1]) {
          newChecks[dayIndex] = !newChecks[dayIndex];
          currentGoal.lastDay = !currentGoal.lastDay;
        }
      } else {
        CustomLogger.warn('루틴 날짜가 아님');
        return;
      }
      final updatedGoal = currentGoal.copyWith(
        checks: newChecks,
        successCount: newSuccessCount,
        lastUpdatedDate: now,
      );
      // DB 저장
      await _repository.saveGoal(updatedGoal);
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

  Future<void> deleteGoal(String goalId) async {
    try {
      await _repository.deleteGoal(goalId);
      if (state.hasValue) {
        final newGoalList = state.value!.where((g) => g.id != goalId).toList();
        state = AsyncValue.data(newGoalList);
      }
      CustomLogger.info("목표 삭제됨: $goalId");
    } catch (e, stackTrace) {
      CustomLogger.error("목표 삭제 실패", e, stackTrace);
    }
  }

  Future<void> resetAfterCompletedGoal(Goal currentGoal) async {
    try {
      final updatedGoal = currentGoal.copyWith(
        checks: [false, false, false],
        successCount: currentGoal.successCount + 1,
        lastUpdatedDate: DateUtils.now(),
        createdAt: DateUtils.now(),
        lastDay: false,
      );

      // DB 저장
      await _repository.saveGoal(updatedGoal);
      final currentGoals = state.value!;
      final goalIndex = currentGoals.indexWhere((g) => g.id == currentGoal.id);
      final newGoalList = List<Goal>.from(currentGoals);
      newGoalList[goalIndex] = updatedGoal;

      state = AsyncValue.data(newGoalList);

      CustomLogger.debug("리셋 완료: ${updatedGoal.title}}");
    } catch (e, stackTrace) {
      CustomLogger.error("리셋 실패", e, stackTrace);
    }
  }

  Future<void> _resetFailedGoals() async {
    try {
      List<Goal> goals = await _repository.getGoals();
      final failedGoals = await _repository.getFailedGoals(goals);

      if (failedGoals!.isEmpty) {
        CustomLogger.info("리셋할 목표가 없습니다. 로직 종료.");
        return;
      }

      for (Goal goal in failedGoals) {
        final updatedGoal = goal.copyWith(
          checks: [false, false, false],
          successCount: goal.successCount,
          lastUpdatedDate: DateUtils.now(),
          createdAt: DateUtils.now(),
        );

        await _repository.saveGoal(updatedGoal);
        final List<Goal> currentGoals = await _repository.getGoals();
        if (currentGoals.isNotEmpty) {
          final goalIndex = currentGoals.indexWhere((g) => g.id == goal.id);
          final newGoalList = List<Goal>.from(currentGoals);
          newGoalList[goalIndex] = updatedGoal;

          state = AsyncValue.data(newGoalList);
        }

        CustomLogger.debug("실패 목표 리셋 완료}");
      }
    } catch (e, st) {
      CustomLogger.error("실패 목표 리셋 실패", e, st);
    }
  }

  Future<void> reorder(
    int oldIndex,
    int newIndex,
    List<Goal> ongoingGoals,
  ) async {
    if (newIndex > oldIndex) newIndex -= 1;
    final goal = ongoingGoals.removeAt(oldIndex);
    ongoingGoals.insert(newIndex, goal);

    final updated = [
      for (int i = 0; i < ongoingGoals.length; i++)
        ongoingGoals[i].copyWith(sortOrder: i),
    ];
    await _repository.saveGoals(updated);

    state = AsyncValue.data(updated);
  }

  Future<void> categoryFilter(String category) async {
    try {
      final goals = await getGoals();
      final List<Goal> filtered = goals
          .where((g) => g.category == category)
          .toList();

      state = AsyncValue.data(filtered);
      CustomLogger.info('카테고리 필터 성공 $filtered');
    } catch (e, t) {
      CustomLogger.error('카테고리 핉터 실패 e: $e ,t: $t');
    }
  }

  List<Goal> filterOngoing(List<Goal> goals, bool isOngoing) {
    final ongoingGoals = goals.where((g) => g.isOngoing == isOngoing).toList();

    return ongoingGoals;
  }

  String updateCategory(String category) {
    _category = category;
    return _category;
  }

  Future<void> toggleIsOngoing(Goal currentGoal, bool isRetry) async {
    try {
      final updatedGoal = currentGoal.copyWith(
        isOngoing: currentGoal.isOngoing = !currentGoal.isOngoing,
        successCount: isRetry
            ? currentGoal.successCount
            : currentGoal.successCount + 1,
        checks: [false, false, false],
        lastUpdatedDate: DateUtils.now(),
        lastDay: false,
      );
      // DB 저장
      await _repository.saveGoal(updatedGoal);
      ref.invalidateSelf();
      CustomLogger.info('진행 토글 성공');
    } catch (e, t) {
      CustomLogger.error('진행 토글 실패 e: $e , t: $t');
    }
  }

  void toggleIsStatsScreen(int value) {
    if (value == 2) {
      isStatsScreen = true;
    } else {
      isStatsScreen = false;
    }
  }
}
