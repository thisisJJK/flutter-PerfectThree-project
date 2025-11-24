import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:perfect_three/core/theme/app_spacing.dart';
import 'package:perfect_three/core/theme/app_typography.dart';
import 'package:perfect_three/core/theme/provider/theme_provider.dart';
import 'package:perfect_three/features/goals/viewmodel/goal_viewmodel.dart';

import '../../../../data/models/goal.dart';

class GoalCard extends ConsumerWidget {
  final Goal goal;
  final double? elevation;

  const GoalCard({super.key, required this.goal, this.elevation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    final themeMode = ref.watch(themeModeNotifierProvider).value;
    final isDark = themeMode == ThemeMode.dark;

    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.md,
      ),
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radius),
      ),

      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? colorScheme.inversePrimary.withValues(alpha: 0.3)
                        : colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "🔥${goal.successCount}회 성공!",
                    style: AppTypography.caption,
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    // TODO : 알림 설정 여부
                  },
                  child: Icon(Icons.notifications_none),
                ),
                SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    // TODO : 수정 및 삭제
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
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body,
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(3, (index) {
                    final isChecked = goal.checks[index];
                    return Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            ref
                                .read(goalViewModelProvider.notifier)
                                .toggleCheck(goal, index);
                            if (index == 2 &&
                                !isChecked &&
                                goal.checks[1] == true) {
                              //재도전 여부 다이얼로그
                              _showRetryDialog(context, ref, goal);
                            }
                          },
                          child: Column(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
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
                                child: Icon(
                                  Icons.check,

                                  color: isChecked
                                      ? colorScheme.onPrimary
                                      : colorScheme.onSurfaceVariant.withValues(
                                          alpha: 0.4,
                                        ),
                                  size: 26,
                                ),
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
        content: Text('습관이 될 때까지 계속 도전해보세요!'),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  //리셋
                  ref.read(goalViewModelProvider.notifier).resetGoal(goal);
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
                      '재도전',
                      style: textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  //삭제
                  ref.read(goalViewModelProvider.notifier).deleteGoal(goal.id);
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
                      '끝내기',
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
        title: Text('목표 삭제하기'),
        content: Text('삭제하면 되돌릴 수 없어요.'),
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
                      '삭제',
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
                      '취소',
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
