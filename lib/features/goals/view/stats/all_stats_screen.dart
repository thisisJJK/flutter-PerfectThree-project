import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perfect_three/core/theme/app_spacing.dart';
import 'package:perfect_three/core/theme/provider/theme_provider.dart';
import 'package:perfect_three/features/goals/viewmodel/goal_viewmodel.dart';
import 'package:perfect_three/features/goals/widgets/stat_card.dart';
import 'package:perfect_three/shared/utils/date_utils.dart' as app_date;

class AllStatsScreen extends ConsumerWidget {
  const AllStatsScreen({super.key});

  int _calculateLongestStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;

    final sortedDates = dates.toList()..sort();
    int maxStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < sortedDates.length; i++) {
      final diff = sortedDates[i].difference(sortedDates[i - 1]).inDays;
      if (diff == 1) {
        currentStreak++;
        maxStreak = max(maxStreak, currentStreak);
      } else {
        currentStreak = 1;
      }
    }

    return maxStreak;
  }

  int _calculateCurrentStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;

    final now = app_date.DateUtils.now();
    final today = app_date.DateUtils.dateOnly(now);
    final sortedDates = dates.toList()..sort((a, b) => b.compareTo(a));

    // Check if there's a success today or yesterday
    final mostRecent = app_date.DateUtils.dateOnly(sortedDates.first);
    final daysSinceRecent = today.difference(mostRecent).inDays;

    if (daysSinceRecent > 1) return 0; // Streak broken

    int streak = 0;
    DateTime checkDate = today;

    for (var date in sortedDates) {
      final dateOnly = app_date.DateUtils.dateOnly(date);
      if (dateOnly.isAtSameMomentAs(checkDate)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (dateOnly.isBefore(checkDate)) {
        break;
      }
    }

    return streak;
  }

  Map<int, int> _analyzeByWeekday(List<DateTime> dates) {
    Map<int, int> weekdayCounts = {};
    for (var date in dates) {
      weekdayCounts[date.weekday] = (weekdayCounts[date.weekday] ?? 0) + 1;
    }
    return weekdayCounts;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalViewModelProvider);
    final themeMode = ref.watch(themeModeNotifierProvider).value;
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      body: goalsAsync.when(
        data: (goals) {
          // Calculate comprehensive statistics
          int totalSuccesses = 0;
          Map<String, int> goalSuccessCounts = {};
          Map<DateTime, int> dailySuccessCounts = {};
          Map<String, int> categorySuccessCounts = {};
          List<DateTime> allSuccessDates = [];
          Set<DateTime> uniqueDays = {};

          for (var goal in goals) {
            int count = goal.successCount;
            if (count > 0) {
              goalSuccessCounts[goal.title] = count;
              totalSuccesses += count;

              // Category breakdown
              categorySuccessCounts[goal.category] =
                  (categorySuccessCounts[goal.category] ?? 0) + count;
            }

            // Aggregate by date for Heatmap and other calculations
            for (var date in goal.successDates) {
              final dateKey = app_date.DateUtils.dateOnly(date);
              dailySuccessCounts[dateKey] =
                  (dailySuccessCounts[dateKey] ?? 0) + 1;
              allSuccessDates.add(dateKey);
              uniqueDays.add(dateKey);
            }
          }

          if (totalSuccesses == 0) {
            return const Center(child: Text('아직 달성한 목표가 없습니다.'));
          }

          // Calculate derived statistics
          final totalActiveDays = uniqueDays.length;
          final longestStreak = _calculateLongestStreak(
            uniqueDays.toList()..sort(),
          );
          final currentStreak = _calculateCurrentStreak(
            uniqueDays.toList(),
          );

          // Calculate overall success rate
          final now = app_date.DateUtils.now();
          final oldestDate = uniqueDays.isEmpty
              ? now
              : uniqueDays.reduce((a, b) => a.isBefore(b) ? a : b);
          final totalDays = now.difference(oldestDate).inDays + 1;
          final activeGoalsCount = goals.where((g) => g.isOngoing).length;
          final possibleChecks = totalDays * activeGoalsCount * 3;
          final overallSuccessRate = possibleChecks > 0
              ? (totalSuccesses / possibleChecks * 100)
              : 0.0;

          // Weekly average
          final totalWeeks = (totalDays / 7).ceil();
          final weeklyAverage = totalWeeks > 0
              ? (totalSuccesses / totalWeeks)
              : 0.0;

          // Weekday analysis
          final weekdayStats = _analyzeByWeekday(allSuccessDates);
          final mostProductiveWeekday = weekdayStats.isEmpty
              ? 1
              : weekdayStats.entries
                    .reduce((a, b) => a.value > b.value ? a : b)
                    .key;

          // Sort goals by success count
          final sortedEntries = goalSuccessCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 72),

            children: [
              // Heatmap Visualization
              const Text(
                '활동 히트맵',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildHeatmap(context, dailySuccessCounts, isDark),
              const SizedBox(height: 24),
              // Stats Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  StatCard(
                    label: '총 누적 성공',
                    value: '$totalSuccesses회',
                    icon: Icons.check_circle,
                  ),
                  StatCard(
                    label: '활동 일수',
                    value: '$totalActiveDays일',
                    icon: Icons.calendar_month,
                  ),
                  StatCard(
                    label: '전체 성공률',
                    value: '${overallSuccessRate.toStringAsFixed(1)}%',
                    icon: Icons.percent,
                  ),
                  StatCard(
                    label: '최장 연속',
                    value: '$longestStreak일',
                    icon: Icons.emoji_events,
                    color: Colors.amber,
                  ),
                  StatCard(
                    label: '현재 연속',
                    value: '$currentStreak일',
                    icon: Icons.local_fire_department,
                    color: currentStreak > 0 ? Colors.orange : Colors.grey,
                  ),
                  StatCard(
                    label: '주평균',
                    value: weeklyAverage.toStringAsFixed(1),
                    icon: Icons.show_chart,
                    subtitle: '회/주',
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Weekday Analysis
              const Text(
                '요일별 분석',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildWeekdayChart(
                context,
                weekdayStats,
                mostProductiveWeekday,
                isDark,
              ),
              const SizedBox(height: 24),

              // Category Breakdown
              if (categorySuccessCounts.length > 1) ...[
                const Text(
                  '카테고리별 분포',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildCategoryBreakdown(
                  context,
                  categorySuccessCounts,
                  totalSuccesses,
                  isDark,
                ),
                const SizedBox(height: 24),
              ],

              // Goal Breakdown
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
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radius,
                        ),
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
                        color: Theme.of(
                          context,
                        ).primaryColor.withOpacity(0.1),
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
    const int weeksToShow = 16;
    const double cellSize = 20.0;
    const double cellSpacing = 4.0;

    final now = app_date.DateUtils.now();
    final startDate = now.subtract(Duration(days: (weeksToShow * 7) - 1));
    final adjustedStartDate = startDate.subtract(
      Duration(days: startDate.weekday % 7),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
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

              if (date.isAfter(now)) {
                return Container(
                  width: cellSize,
                  height: cellSize,
                  margin: const EdgeInsets.all(cellSpacing / 2),
                  decoration: const BoxDecoration(
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
    if (count == 1) return baseColor.withOpacity(0.3);
    if (count == 2) return baseColor.withOpacity(0.6);
    return baseColor;
  }

  Widget _buildWeekdayChart(
    BuildContext context,
    Map<int, int> weekdayStats,
    int mostProductiveDay,
    bool isDark,
  ) {
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final maxCount = weekdayStats.isEmpty ? 1 : weekdayStats.values.reduce(max);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.star,
                  size: 16,
                  color: Colors.amber,
                ),
                const SizedBox(width: 8),
                Text(
                  '가장 생산적인 요일: ${weekdays[mostProductiveDay - 1]}요일',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final weekday = index + 1;
                final count = weekdayStats[weekday] ?? 0;
                final height = maxCount > 0 ? (count / maxCount * 80) : 0.0;
                final isMostProductive = weekday == mostProductiveDay;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Column(
                      children: [
                        Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isMostProductive
                                ? Colors.amber
                                : Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: height.clamp(15, 80),
                          decoration: BoxDecoration(
                            color: isMostProductive
                                ? Colors.amber
                                : Theme.of(context).primaryColor,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          weekdays[index],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isMostProductive
                                ? FontWeight.bold
                                : FontWeight.normal,
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

  Widget _buildCategoryBreakdown(
    BuildContext context,
    Map<String, int> categoryStats,
    int total,
    bool isDark,
  ) {
    final sortedCategories = categoryStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: sortedCategories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value.key;
            final count = entry.value.value;
            final percentage = (count / total * 100);
            final color = colors[index % colors.length];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            category,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$count회 (${percentage.toStringAsFixed(1)}%)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
