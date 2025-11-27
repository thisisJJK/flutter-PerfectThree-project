import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perfect_three/core/theme/app_spacing.dart';
import 'package:perfect_three/core/theme/provider/theme_provider.dart';
import 'package:perfect_three/data/models/goal.dart';

class MyHabitCard extends ConsumerWidget {
  final Goal goal;
  final double? elevation;

  const MyHabitCard({super.key, required this.goal, this.elevation = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    final themeMode = ref.watch(themeModeNotifierProvider).value;
    final isDark = themeMode == ThemeMode.dark;
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
    );
  }
}
