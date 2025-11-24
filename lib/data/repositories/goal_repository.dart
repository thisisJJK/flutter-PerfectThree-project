import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:perfect_three/core/utils/app_error.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/utils/custom_logger.dart';
import '../models/goal.dart';

part 'goal_repository.g.dart';

/// [GoalRepository]
/// Hive DB와 직접 통신하며 목표 데이터를 CRUD(생성, 조회, 수정, 삭제)하는 클래스입니다.
class GoalRepository {
  static const String boxName = 'goals_box';

  // Hive Box를 엽니다. (앱 시작 시 초기화 필요)
  Future<Box<Goal>> _openBox() async {
    try {
      if (!Hive.isBoxOpen(boxName)) {
        return await Hive.openBox<Goal>(boxName);
      }
      return Hive.box<Goal>(boxName);
    } catch (e, stackTrace) {
      CustomLogger.error("Hive Box 열기 실패", e, stackTrace);
      throw DatabaseError(code: 'DB_OPEN_FAILED', message: '데이터베이스를 열 수 없습니다.');
    }
  }

  /// 모든 목표 가져오기
  Future<List<Goal>> getGoals() async {
    try {
      final box = await _openBox();
      final goals = box.values.toList();

      goals.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      CustomLogger.info("모든 목표를 성공적으로 로드했습니다.");

      return goals;
    } catch (e, stackTrace) {
      CustomLogger.error("목표 불러오기 실패", e, stackTrace);
      return [];
    }
  }

  /// 목표 저장 (추가 및 수정)
  /// id가 이미 존재하면 덮어쓰고(수정), 없으면 새로 만듭니다.
  Future<void> saveGoal(Goal goal) async {
    try {
      final box = await _openBox();
      await box.put(goal.id, goal); // key를 ID로 사용하여 저장
      CustomLogger.info("목표 저장 완료: ${goal.title}");
    } catch (e, stackTrace) {
      CustomLogger.error("목표 저장 실패", e, stackTrace);
      rethrow; // ViewModel에서 에러 처리를 할 수 있도록 던짐
    }
  }

  /// 목표 삭제
  Future<void> deleteGoal(String id) async {
    try {
      final box = await _openBox();
      await box.delete(id);
      CustomLogger.info("목표 삭제 완료: $id");
    } catch (e, stackTrace) {
      CustomLogger.error("목표 삭제 실패", e, stackTrace);
      rethrow;
    }
  }

  //일괄 저장 (Reorder 용도)
  Future<void> saveGoals(List<Goal> goals) async {
    try {
      final box = await _openBox();
      for (var goal in goals) {
        await box.put(goal.id, goal);
      }
      CustomLogger.info("일괄 저장 완료");
    } catch (e, stackTrace) {
      CustomLogger.error("목표 삭제 실패", e, stackTrace);
    }
  }
}

// Riverpod Generator를 사용하여 Provider 생성
// 이제 앱 어디서든 ref.watch(goalRepositoryProvider)로 이 저장소를 쓸 수 있습니다.
@Riverpod(keepAlive: true)
GoalRepository goalRepository(GoalRepositoryRef ref) {
  return GoalRepository();
}
