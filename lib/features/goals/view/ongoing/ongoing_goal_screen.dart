import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:perfect_three/core/theme/app_colors.dart';
import 'package:perfect_three/core/theme/app_spacing.dart';
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
          final selectedCategory = ref.watch(categoryFilterProvider);
          final allOngoingGoals = ref
              .read(goalViewModelProvider.notifier)
              .filterOngoing(goals, true);

          final ongoingGoals = selectedCategory == '전체'
              ? allOngoingGoals
              : allOngoingGoals
                    .where((g) => g.category == selectedCategory)
                    .toList();
          // 목표 리스트 렌더링 - 카테고리 칩 포함
          return Column(
            children: [
              // 카테고리 칩
              Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.screenPadding,
                  top: AppSpacing.m,
                  bottom: AppSpacing.s,
                ),
                child: CategoryChips(isOngoing: true),
              ),
              // 목표 리스트 또는 빈 상태
              Expanded(
                child: ongoingGoals.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.flag_outlined, size: 66),
                            const SizedBox(height: 16),
                            Text(
                              "아직 목표가 없어요.\n새로운 3일 도전을 시작해보세요!",
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        onReorder: (oldIndex, newIndex) {
                          ref
                              .read(goalViewModelProvider.notifier)
                              .reorder(oldIndex, newIndex, ongoingGoals);
                        },
                        proxyDecorator: (child, index, animation) {
                          return AnimatedBuilder(
                            animation: animation,
                            builder: (BuildContext context, Widget? child) {
                              final double animValue = Curves.easeInOut
                                  .transform(
                                    animation.value,
                                  );
                              final double scale = lerpDouble(
                                1,
                                1.03,
                                animValue,
                              )!;
                              return Transform.scale(
                                scale: scale,
                                child: Material(
                                  color: Colors.transparent,
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: GoalCard(
                                      goal: ongoingGoals[index],
                                    ),
                                  ),
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
      floatingActionButton: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              context.push('/add');
            },
            customBorder: const CircleBorder(),
            child: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}
