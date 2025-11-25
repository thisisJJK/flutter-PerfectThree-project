import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:perfect_three/core/theme/app_typography.dart';
import 'package:perfect_three/data/models/goal.dart';
import 'package:perfect_three/features/goals/viewmodel/goal_viewmodel.dart';
import 'package:perfect_three/features/goals/widgets/category_chips.dart';
import 'package:perfect_three/features/goals/widgets/goal_card.dart';

class OngoingGoalScreen extends ConsumerWidget {
  const OngoingGoalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ViewModel 상태 구독
    final goalsAsync = ref.watch(goalViewModelProvider);
    return Scaffold(
      body: goalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('에러: $err')),
        data: (goals) {
          final ongoingGoals = _filterOngoing(goals);
          if (ongoingGoals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flag_outlined, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    "아직 목표가 없어요.\n새로운 3일 도전을 시작해보세요!",
                    textAlign: TextAlign.center,
                    style: AppTypography.body,
                  ),
                ],
              ),
            );
          }
          // 목표 리스트 렌더링
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 8, 0),
                child: CategoryChips(isOngoing: true),
              ),
              Expanded(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.only(bottom: 80), // FAB와 겹치지 않게 여백
                  onReorder: (oldIndex, newIndex) {
                    ref
                        .read(goalViewModelProvider.notifier)
                        .reorder(oldIndex, newIndex, ongoingGoals);
                  },
                  proxyDecorator: (child, index, animation) {
                    return AnimatedBuilder(
                      animation: animation,
                      builder: (BuildContext context, Widget? child) {
                        final double animValue = Curves.easeInOut.transform(
                          animation.value,
                        );
                        final double elevation = lerpDouble(1, 6, animValue)!;
                        final double scale = lerpDouble(1, 1.03, animValue)!;
                        return Transform.scale(
                          scale: scale,
                          child: GoalCard(
                            goal: ongoingGoals[index],
                            elevation: elevation,
                          ),
                        );
                      },
                    );
                  },
                  itemCount: ongoingGoals.length,
                  itemBuilder: (context, index) {
                    final goal = ongoingGoals[index];
                    return GoalCard(
                      goal: goal,
                      key: ValueKey(ongoingGoals[index].id),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/add'); // 라우터로 이동
        },

        child: const Icon(Icons.add),
      ),
    );
  }
}

List<Goal> _filterOngoing(List<Goal> goals) {
  final ongoingGoals = goals.where((g) => g.isOngoing == true).toList();

  return ongoingGoals;
}
