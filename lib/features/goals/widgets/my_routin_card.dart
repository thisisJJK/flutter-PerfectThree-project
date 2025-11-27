import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:perfect_three/core/theme/app_spacing.dart';
import 'package:perfect_three/core/theme/provider/theme_provider.dart';
import 'package:perfect_three/data/models/goal.dart';
import 'package:perfect_three/features/goals/viewmodel/goal_viewmodel.dart';

class MyRoutinCard extends ConsumerWidget {
  final Goal goal;
  final double? elevation;

  const MyRoutinCard({super.key, required this.goal, this.elevation = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    final themeMode = ref.watch(themeModeNotifierProvider).value;
    final isDark = themeMode == ThemeMode.dark;
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              //재도전 다이얼로그
              _showRetryDialog(context, ref, goal);
            },
            child: Card(
              margin: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.sm,
                AppSpacing.sm,
              ),
              elevation: elevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radius),
                side: BorderSide(
                  color: colorScheme.onPrimaryContainer.withValues(alpha: 0.1),
                ),
              ),

              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    //•
                    Text('•'),
                    SizedBox(width: 4),
                    //카테고리
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? colorScheme.tertiary.withValues(alpha: 0.4)
                            : Colors.deepPurple.shade100,
                        borderRadius: BorderRadius.circular(AppSpacing.radius),
                      ),
                      child: Text(goal.category),
                    ),
                    SizedBox(width: 8),

                    //타이틀
                    Text(goal.title, style: TextStyle(fontSize: 18)),
                    Spacer(),
                    //연속 횟수
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
                      child: Text("🔥연속 ${goal.successCount}회"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.lg),
          child: GestureDetector(
            onTap: () {
              //삭제 다이얼로그
              _showDeleteDialog(context, ref, goal);
            },
            child: Icon(Icons.delete_outline_rounded),
          ),
        ),
      ],
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
        title: Text('루틴 시작'),
        content: Text('계속 이어서 루틴을 이어나가 보세요'),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  ref
                      .read(goalViewModelProvider.notifier)
                      .toggleIsOngoing(goal, true);
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
                      '시작하기',
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
        content: Text('삭제하면 되돌릴 수 없어요'),
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
