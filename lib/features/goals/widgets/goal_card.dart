import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:perfect_three/core/theme/app_colors.dart';
import 'package:perfect_three/core/theme/app_spacing.dart';
import 'package:perfect_three/core/theme/app_theme.dart';
import 'package:perfect_three/core/theme/provider/theme_provider.dart';
import 'package:perfect_three/features/goals/viewmodel/goal_viewmodel.dart';
import 'package:perfect_three/shared/utils/date_utils.dart';

import '../../../../data/models/goal.dart';

/// iOS 스타일 목표 카드
class GoalCard extends ConsumerWidget {
  final Goal goal;

  const GoalCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeNotifierProvider).value;
    final isDark = themeMode == ThemeMode.dark;
    final category = goal.category;
    final categoryColor = AppColors.getCategoryColor(category);

    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 6, // 더 작은 수직 여백
        horizontal: AppSpacing.screenPadding,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        border: Border.all(
          color: (isDark ? AppColors.dividerDark : AppColors.divider)
              .withValues(alpha: 0.3),
          width: 0.5,
        ),
        // iOS 스타일 부드러운 그림자
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m), // l에서 m으로 감소
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                  ),
                  child: Text(
                    category,
                    style: Font.main.copyWith(
                      color: categoryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: -0.1,
                    ),
                  ),
                ),
                Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceElevatedDark
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                  ),
                  child: Text(
                    "🔥 ${goal.successCount}회 성공",
                    style: Font.main.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textSecondary,
                      letterSpacing: -0.1,
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.s),
                InkWell(
                  onTap: () {
                    _showDeleteDialog(context, ref, goal, isDark);
                  },
                  borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      size: 20,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.s), // m에서 s로 감소
            Text(
              goal.title,
              style: Font.display.copyWith(
                fontSize: 17, // 20에서 17로 감소
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: AppSpacing.m), // l에서 m으로 감소
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(3, (index) {
                final isChecked = goal.checks[index];
                final bool lastDay = goal.lastDay;
                final now = DateUtils.now();
                DateTime createdDay = DateUtils.dateOnly(goal.createdAt);
                bool isMustCheckToday =
                    DateUtils.differenceDay(now, createdDay) % 3 == index;
                bool isLast = DateUtils.differenceDay(now, createdDay) % 3 == 2;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      ref
                          .read(goalViewModelProvider.notifier)
                          .toggleCheck(goal, index);

                      if (index == 2 && lastDay && isLast) {
                        _showRetryDialog(context, ref, goal, isDark);
                      }
                    },
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          width: 46, // 52에서 46으로 감소
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isChecked
                                ? categoryColor
                                : (isMustCheckToday
                                      ? categoryColor.withValues(alpha: 0.12)
                                      : (isDark
                                            ? AppColors.backgroundSecondaryDark
                                            : AppColors.backgroundSecondary)),
                            border: Border.all(
                              width: isChecked ? 0 : 2,
                              color: isChecked
                                  ? Colors.transparent
                                  : (isMustCheckToday
                                        ? categoryColor
                                        : (isDark
                                              ? AppColors.dividerDark
                                              : AppColors.divider)),
                            ),
                            // iOS 스타일 부드러운 그림자
                            boxShadow: isChecked
                                ? [
                                    BoxShadow(
                                      color: categoryColor.withValues(
                                        alpha: 0.35,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: isChecked
                                ? Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 26, // 30에서 26으로 감소
                                  )
                                : Text(
                                    (index + 1).toString(),
                                    style: Font.display.copyWith(
                                      fontSize: 18, // 20에서 18로 감소
                                      fontWeight: FontWeight.w700,
                                      color: isMustCheckToday
                                          ? categoryColor
                                          : (isDark
                                                ? AppColors.textTertiaryDark
                                                : AppColors.textTertiary),
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          index == 0 ? "1일차" : (index == 1 ? "2일차" : "3일차"),
                          style: Font.main.copyWith(
                            fontSize: 12,
                            color: isMustCheckToday
                                ? categoryColor
                                : (isDark
                                      ? AppColors.textTertiaryDark
                                      : AppColors.textTertiary),
                            fontWeight: isMustCheckToday
                                ? FontWeight.w600
                                : FontWeight.w500,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

void _showRetryDialog(
  BuildContext context,
  WidgetRef ref,
  Goal goal,
  bool isDark,
) async {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          '🎉 3일 성공!',
          style: Font.main.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Text(
          '축하합니다! 루틴을 성공적으로 마쳤어요.\n이어서 계속 도전하시겠어요?',
          style: Font.main,
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref
                  .read(goalViewModelProvider.notifier)
                  .toggleIsOngoing(goal, false);
              context.pop();
            },
            child: Text(
              '그만하기',
              style: Font.main.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              ref
                  .read(goalViewModelProvider.notifier)
                  .resetAfterCompletedGoal(goal);
              context.pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusS),
              ),
            ),
            child: Text(
              '계속하기',
              style: Font.main.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    },
  );
}

void _showDeleteDialog(
  BuildContext context,
  WidgetRef ref,
  Goal goal,
  bool isDark,
) async {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          '루틴 삭제',
          style: Font.main.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Text('정말 삭제하시겠어요?\n삭제된 루틴은 복구할 수 없습니다.', style: Font.main),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
            },
            child: Text(
              '취소',
              style: Font.main.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(goalViewModelProvider.notifier).deleteGoal(goal.id);
              context.pop();
            },
            child: Text(
              '삭제',
              style: Font.main.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
}
