import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perfect_three/core/theme/app_spacing.dart';
import 'package:perfect_three/features/goals/viewmodel/goal_viewmodel.dart';

import '../../../../data/models/goal.dart';

class GoalCard extends ConsumerWidget {
  final Goal goal;

  const GoalCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isGoalCompleted = goal.checks.every((c) => c);

    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.md,
      ),

      color: isGoalCompleted
          ? colorScheme.primaryContainer.withOpacity(0.4)
          : Theme.of(context).cardColor,

      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radius),
      ),

      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    goal.title,
                    overflow: TextOverflow.ellipsis,

                    style: textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    "🔥연속 ${goal.successCount}회",

                    style: textTheme.labelLarge!.copyWith(
                      color: colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(3, (index) {
                final isChecked = goal.checks[index];

                return GestureDetector(
                  onTap: () {
                    ref
                        .read(goalViewModelProvider.notifier)
                        .toggleCheck(goal.id, index);
                  },
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,

                          color: isChecked
                              ? colorScheme.primary
                              : colorScheme.surfaceContainerHigh,
                          boxShadow: isChecked
                              ? [
                                  BoxShadow(
                                    color: colorScheme.primary.withOpacity(0.3),
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
                              : colorScheme.onSurfaceVariant.withOpacity(0.4),
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        "Day ${index + 1}",

                        style: textTheme.labelMedium!.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
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
