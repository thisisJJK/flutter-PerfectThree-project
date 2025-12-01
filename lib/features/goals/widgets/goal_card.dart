import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:perfect_three/core/theme/app_colors.dart';
import 'package:perfect_three/core/theme/app_spacing.dart';
import 'package:perfect_three/core/theme/provider/theme_provider.dart';
import 'package:perfect_three/features/goals/viewmodel/goal_viewmodel.dart';
import 'package:perfect_three/shared/utils/date_utils.dart';

import '../../../../data/models/goal.dart';

class GoalCard extends ConsumerWidget {
  final Goal goal;
  final double? elevation;

  const GoalCard({super.key, required this.goal, this.elevation = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    final themeMode = ref.watch(themeModeNotifierProvider).value;
    final isDark = themeMode == ThemeMode.dark;
    final category = goal.category;

    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.lg,
      ),
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        side: BorderSide(
          color: colorScheme.onPrimaryContainer.withValues(alpha: 0.1),
        ),
      ),

      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.getCategoryColor(
                            category,
                          ).withValues(alpha: 0.3)
                        : AppColors.getCategoryColor(
                            category,
                          ).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppSpacing.radius),
                  ),
                  child: Text(category),
                ),
                Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? colorScheme.inversePrimary.withValues(alpha: 0.5)
                        : colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(AppSpacing.radius),
                  ),
                  child: Text("🔥누적 ${goal.successCount}회"),
                ),

                SizedBox(width: 8),

                GestureDetector(
                  onTap: () {
                    _showDeleteDialog(context, ref, goal);
                  },
                  child: Icon(Icons.delete_outlined),
                ),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '• ${goal.title}',
                    style: TextStyle(fontSize: 17),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(3, (index) {
                    final isChecked = goal.checks[index];
                    final bool lastDay = goal.lastDay;
                    final now = DateUtils.now();
                    DateTime createdDay = DateUtils.dateOnly(goal.createdAt);
                    bool isMustCheckToday =
                        DateUtils.differenceDay(now, createdDay) % 3 == index;
                    bool isLast =
                        DateUtils.differenceDay(now, createdDay) % 3 == 2;

                    return Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            ref
                                .read(goalViewModelProvider.notifier)
                                .toggleCheck(goal, index);

                            if (index == 2 && lastDay && isLast) {
                              //재도전 여부 다이얼로그
                              _showRetryDialog(context, ref, goal);
                            }
                          },
                          child: Column(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: isChecked && isMustCheckToday
                                      ? Border.all(width: 0)
                                      : Border.all(
                                          width: 2,
                                          color: colorScheme.onPrimaryContainer
                                              .withValues(alpha: 0.5),
                                        ),
                                  color: isChecked
                                      ? colorScheme.primary
                                      : colorScheme.surfaceContainerHigh,
                                  boxShadow: isChecked
                                      ? [
                                          BoxShadow(
                                            color: colorScheme.primary
                                                .withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: isChecked
                                    ? Icon(
                                        Icons.check,
                                        color: isChecked
                                            ? colorScheme.onPrimary
                                            : Colors.transparent,
                                        size: 26,
                                      )
                                    : isMustCheckToday
                                    ? Center(
                                        child: Text(
                                          (index + 1).toString(),
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: colorScheme
                                                .onPrimaryContainer
                                                .withValues(alpha: 0.3),
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 5),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void _showRetryDialog(BuildContext context, WidgetRef ref, Goal goal) async {
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;

  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      final double width = 110;
      final double height = 45;
      return AlertDialog(
        title: Text('Perfect Three 성공!'),
        content: Text('내 루틴으로 만들었어요!\n이어서 계속 하시겠어요?'),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  //재도전
                  //리셋
                  ref
                      .read(goalViewModelProvider.notifier)
                      .resetAfterCompletedGoal(goal);
                  context.pop();
                },
                child: Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: colorScheme.primaryContainer,
                  ),
                  child: Center(
                    child: Text(
                      '계속하기',
                      style: textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  //내 습관으로 이동
                  //isOnging = false
                  ref
                      .read(goalViewModelProvider.notifier)
                      .toggleIsOngoing(goal, false);

                  context.pop();
                },
                child: Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 0.2,
                      color: colorScheme.onSurface,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '그만하기',
                      style: textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}

void _showDeleteDialog(BuildContext context, WidgetRef ref, Goal goal) async {
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;

  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      final double width = 110;
      final double height = 45;
      return AlertDialog(
        title: Text('루틴 삭제'),
        content: Text('성공하지 못한 루틴은 \n삭제하면 되돌릴 수 없어요.\n정말 삭제하시겠어요?'),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  ref.read(goalViewModelProvider.notifier).deleteGoal(goal.id);
                  context.pop();
                },
                child: Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.red,
                  ),
                  child: Center(
                    child: Text(
                      '삭제하기',
                      style: textTheme.bodyMedium!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  context.pop();
                },
                child: Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 0.2,
                      color: colorScheme.onSurface,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '취소하기',
                      style: textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}
