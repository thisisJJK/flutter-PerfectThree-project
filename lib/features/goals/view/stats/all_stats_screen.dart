import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perfect_three/core/theme/app_spacing.dart';
import 'package:perfect_three/core/theme/provider/theme_provider.dart';
import 'package:perfect_three/features/goals/viewmodel/goal_viewmodel.dart';
import 'package:perfect_three/shared/utils/date_utils.dart' as app_date;

class AllStatsScreen extends ConsumerWidget {
  const AllStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalViewModelProvider);
    final themeMode = ref.watch(themeModeNotifierProvider).value;
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      body: goalsAsync.when(
        data: (goals) {
          // 1. Calculate total successes & Aggregate by Date
          int totalSuccesses = 0;
          Map<String, int> goalSuccessCounts = {};
          Map<DateTime, int> dailySuccessCounts = {};

          for (var goal in goals) {
            // Total count per goal
            int count = goal.successCount;
            if (count > 0) {
              goalSuccessCounts[goal.title] = count;
              totalSuccesses += count;
            }

            // Aggregate by date for Heatmap
            for (var date in goal.successDates) {
              final dateKey = app_date.DateUtils.dateOnly(date);
              dailySuccessCounts[dateKey] =
                  (dailySuccessCounts[dateKey] ?? 0) + 1;
            }
          }

          if (totalSuccesses == 0) {
            return const Center(child: Text('아직 달성한 목표가 없습니다.'));
          }

          // Sort goals by success count (descending)
          final sortedEntries = goalSuccessCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Total Count Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Text(
                        '총 누적 성공',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$totalSuccesses회',
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Heatmap Visualization
              const Text(
                '활동 히트맵',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildHeatmap(context, dailySuccessCounts, isDark),

              const SizedBox(height: 24),

              // Breakdown
              const Text(
                '목표별 누적 현황',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...sortedEntries.map((entry) {
                final goal = goals.firstWhere((g) => g.title == entry.key);
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Theme.of(
                                context,
                              ).colorScheme.tertiary.withValues(alpha: 0.4)
                            : Colors.deepPurple.shade100,
                        borderRadius: BorderRadius.circular(AppSpacing.radius),
                      ),
                      child: Text(goal.category),
                    ),
                    title: Text(entry.key),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.triangle_fill,
                            size: 12,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${entry.value}',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('에러가 발생했습니다: $err')),
      ),
    );
  }

  Widget _buildHeatmap(
    BuildContext context,
    Map<DateTime, int> dailyCounts,
    bool isDark,
  ) {
    // Configuration
    const int weeksToShow = 16; // Show last ~4 months
    const double cellSize = 20.0;
    const double cellSpacing = 4.0;

    final now = app_date.DateUtils.now();
    // End date is usually "next Saturday" or just today to align grid?
    // Let's align to end on today or this week.
    // To make it look like GitHub, we usually fill columns (weeks).

    // Calculate start date (weeksToShow weeks ago, adjusted to Sunday)
    final startDate = now.subtract(Duration(days: (weeksToShow * 7) - 1));
    // Adjust startDate to be a Sunday (or Monday depending on preference, let's say Sunday)
    final adjustedStartDate = startDate.subtract(
      Duration(days: startDate.weekday % 7),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true, // Scroll to end (today) by default
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(weeksToShow, (weekIndex) {
          return Column(
            children: List.generate(7, (dayIndex) {
              final date = adjustedStartDate.add(
                Duration(days: (weekIndex * 7) + dayIndex),
              );
              final dateKey = app_date.DateUtils.dateOnly(date);
              final count = dailyCounts[dateKey] ?? 0;

              // Don't show future dates
              if (date.isAfter(now)) {
                return Container(
                  width: cellSize,
                  height: cellSize,
                  margin: const EdgeInsets.all(cellSpacing / 2),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                );
              }

              return Tooltip(
                message:
                    '${date.year}-${date.month}-${date.day}: $count successes',
                child: Container(
                  width: cellSize,
                  height: cellSize,
                  margin: const EdgeInsets.all(cellSpacing / 2),
                  decoration: BoxDecoration(
                    color: _getColorForCount(context, count, isDark),
                    borderRadius: BorderRadius.circular(4),
                    border: count == 0
                        ? Border.all(
                            color: isDark ? Colors.white10 : Colors.black12,
                          )
                        : null,
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  Color _getColorForCount(BuildContext context, int count, bool isDark) {
    if (count == 0) {
      return isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200;
    }

    final baseColor = Theme.of(context).primaryColor;
    // Simple intensity scale
    if (count == 1) return baseColor.withOpacity(0.3);
    if (count == 2) return baseColor.withOpacity(0.6);
    return baseColor; // 3+
  }
}
