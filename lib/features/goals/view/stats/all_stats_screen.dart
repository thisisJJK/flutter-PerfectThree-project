import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perfect_three/core/theme/app_colors.dart';
import 'package:perfect_three/core/theme/app_spacing.dart';
import 'package:perfect_three/core/theme/app_theme.dart';
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
            return Center(
              child: Text(
                '아직 달성한 목표가 없습니다.',
                style: Font.main.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
            );
          }

          // Calculate derived statistics
          final totalActiveDays = uniqueDays.length;
          final longestStreak = _calculateLongestStreak(
            uniqueDays.toList()..sort(),
          );
          final currentStreak = _calculateCurrentStreak(
            uniqueDays.toList(),
          );

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
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.screenPadding,
              AppSpacing.screenPadding,
              88,
            ),
            children: [
              // Heatmap Visualization
              Text(
                '활동 히트맵',
                style: Font.main.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              _buildHeatmap(context, dailySuccessCounts, isDark),
              const SizedBox(height: AppSpacing.l),

              Text(
                '전체 분석',
                style: Font.main.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              // Stats Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.s,
                crossAxisSpacing: AppSpacing.s,
                childAspectRatio: 1.3,
                children: [
                  StatCard(
                    label: '총 누적 성공',
                    value: '$totalSuccesses회',
                    icon: Icons.check_circle_outline_rounded,
                    color: AppColors.success,
                    isDark: isDark,
                  ),
                  StatCard(
                    label: '활동 일수',
                    value: '$totalActiveDays일',
                    icon: Icons.calendar_today_rounded,
                    color: AppColors.info,
                    isDark: isDark,
                  ),
                  StatCard(
                    label: '최장 연속',
                    value: '$longestStreak일',
                    icon: Icons.emoji_events_outlined,
                    color: AppColors.warning,
                    isDark: isDark,
                  ),
                  StatCard(
                    label: '현재 연속',
                    value: '$currentStreak일',
                    icon: Icons.local_fire_department_rounded,
                    color: AppColors.error,
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Weekday Analysis
              Text(
                '요일별 분석',
                style: Font.main.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              _buildWeekdayChart(
                context,
                weekdayStats,
                mostProductiveWeekday,
                isDark,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Category Breakdown
              if (categorySuccessCounts.length > 1) ...[
                Text(
                  '카테고리별 분포',
                  style: Font.main.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                _buildCategoryBreakdown(
                  context,
                  categorySuccessCounts,
                  totalSuccesses,
                  isDark,
                ),
                const SizedBox(height: AppSpacing.xl),
              ],

              // Goal Breakdown
              Text(
                '루틴별 누적 현황',
                style: Font.main.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              ...sortedEntries.map((entry) {
                final goal = goals.firstWhere((g) => g.title == entry.key);
                final categoryColor = AppColors.getCategoryColor(goal.category);

                return Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.s),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radius),
                    side: BorderSide(
                      color: isDark ? AppColors.dividerDark : AppColors.divider,
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.m,
                      vertical: AppSpacing.xs,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                      ),
                      child: Text(
                        goal.category,
                        style: Font.main.copyWith(
                          color: categoryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    title: Text(
                      entry.key,
                      style: Font.main.copyWith(fontWeight: FontWeight.w600),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.primaryDark.withValues(alpha: 0.1)
                            : AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.triangle_fill,
                            size: 10,
                            color: isDark
                                ? AppColors.primaryDark
                                : AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${entry.value}',
                            style: Font.main.copyWith(
                              color: isDark
                                  ? AppColors.primaryDark
                                  : AppColors.primary,
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
      return isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.grey.shade200;
    }

    final baseColor = isDark ? AppColors.primaryDark : AppColors.primary;
    if (count == 1) return baseColor.withValues(alpha: 0.33);
    if (count == 2) return baseColor.withValues(alpha: 0.66);
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
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        side: BorderSide(
          color: isDark ? AppColors.dividerDark : AppColors.divider,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  size: 18,
                  color: Colors.amber,
                ),
                const SizedBox(width: 8),
                Text(
                  '가장 생산적인 요일: ${weekdays[mostProductiveDay - 1]}요일',
                  style: Font.main.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
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
                          style: Font.main.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isMostProductive
                                ? Colors.amber
                                : isDark
                                ? AppColors.primaryDark.withValues(alpha: 0.7)
                                : AppColors.primary.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: height.clamp(15, 80),
                          decoration: BoxDecoration(
                            color: isMostProductive
                                ? Colors.amber
                                : isDark
                                ? AppColors.primaryDark.withValues(alpha: 0.5)
                                : AppColors.primary.withValues(alpha: 0.5),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          weekdays[index],
                          style: Font.main.copyWith(
                            fontSize: 11,
                            fontWeight: isMostProductive
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
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

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        side: BorderSide(
          color: isDark ? AppColors.dividerDark : AppColors.divider,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          children: sortedCategories.map((entry) {
            final category = entry.key;
            final count = entry.value;
            final percentage = (count / total * 100);
            final color = AppColors.getCategoryColor(category);

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
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            category,
                            style: Font.main.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$count회 (${percentage.toStringAsFixed(1)}%)',
                        style: Font.main.copyWith(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
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
                          ? Colors.white.withValues(alpha: 0.1)
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
