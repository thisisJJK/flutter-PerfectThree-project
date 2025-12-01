import 'dart:math';

import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:perfect_three/core/theme/app_colors.dart';
import 'package:perfect_three/core/theme/app_spacing.dart';
import 'package:perfect_three/core/theme/provider/theme_provider.dart';
import 'package:perfect_three/features/goals/viewmodel/goal_viewmodel.dart';
import 'package:perfect_three/features/goals/widgets/stat_card.dart';
import 'package:perfect_three/shared/utils/date_utils.dart';

class MonthlyStatsScreen extends ConsumerStatefulWidget {
  const MonthlyStatsScreen({super.key});

  @override
  ConsumerState<MonthlyStatsScreen> createState() => _MonthlyStatsScreenState();
}

class _MonthlyStatsScreenState extends ConsumerState<MonthlyStatsScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateUtils.now();
  }

  void _changeMonth(int offset) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + offset,
      );
    });
  }

  int _calculateBestStreak(List<DateTime> dates) {
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

  Map<int, int> _getWeeklyBreakdown(List<DateTime> dates) {
    Map<int, int> weekCounts = {};

    for (var date in dates) {
      // Calculate week number in month (0-based)
      int weekInMonth = ((date.day - 1) / 7).floor();
      weekCounts[weekInMonth] = (weekCounts[weekInMonth] ?? 0) + 1;
    }

    return weekCounts;
  }

  @override
  Widget build(BuildContext context) {
    final goalsAsync = ref.watch(goalViewModelProvider);

    return Scaffold(
      body: Column(
        children: [
          // Month Selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => _changeMonth(-1),
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  DateFormat('yyyy년 MM월').format(_selectedMonth),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  onPressed: () => _changeMonth(1),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),

          // Stats Content
          Expanded(
            child: goalsAsync.when(
              data: (goals) {
                // Calculate statistics for this month
                int totalSuccesses = 0;
                Map<String, int> goalSuccessCounts = {};
                List<DateTime> allSuccessDates = [];
                Set<String> activeGoals = {};

                for (var goal in goals) {
                  int count = 0;
                  // ignore: unnecessary_null_comparison
                  if (goal.successDates != null) {
                    for (var date in goal.successDates) {
                      if (date.year == _selectedMonth.year &&
                          date.month == _selectedMonth.month) {
                        count++;
                        allSuccessDates.add(date);
                      }
                    }
                  }

                  if (count > 0) {
                    goalSuccessCounts[goal.title] = count;
                    totalSuccesses += count;
                    activeGoals.add(goal.id);
                  }
                }

                // Calculate previous month stats for comparison
                final prevMonth = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month - 1,
                );
                int prevMonthSuccesses = 0;
                for (var goal in goals) {
                  // ignore: unnecessary_null_comparison
                  if (goal.successDates != null) {
                    for (var date in goal.successDates) {
                      if (date.year == prevMonth.year &&
                          date.month == prevMonth.month) {
                        prevMonthSuccesses++;
                      }
                    }
                  }
                }

                if (totalSuccesses == 0) {
                  return const Center(child: Text('이 달의 달성 기록이 없습니다.'));
                }

                // Calculate derived stats
                final daysInMonth = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month + 1,
                  0,
                ).day;
                final now = DateUtils.now();
                final daysElapsed =
                    _selectedMonth.month == now.month &&
                        _selectedMonth.year == now.year
                    ? now.day
                    : daysInMonth;

                final activeGoalsCount = activeGoals.length;
                final possibleChecks = daysElapsed * activeGoalsCount * 3;
                final successRate = possibleChecks > 0
                    ? (totalSuccesses / possibleChecks * 100)
                    : 0.0;
                final dailyAverage = daysElapsed > 0
                    ? (totalSuccesses / daysElapsed)
                    : 0.0;
                final bestStreak = _calculateBestStreak(allSuccessDates);
                final monthDiff = totalSuccesses - prevMonthSuccesses;
                final weeklyBreakdown = _getWeeklyBreakdown(allSuccessDates);

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                  children: [
                    const Text(
                      '월간 분석',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Stats Grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      childAspectRatio: 1.5,
                      children: [
                        StatCard(
                          label: '총 성공',
                          value: '$totalSuccesses회',
                          icon: Icons.check_circle,
                          color: Colors.green,
                          isDark: true,
                        ),
                        // StatCard(
                        //   label: '성공률',
                        //   value: '${successRate.toStringAsFixed(1)}%',
                        //   icon: Icons.percent,
                        //   subtitle: '$possibleChecks회 중',
                        // ),
                        // StatCard(
                        //   label: '일평균',
                        //   value: dailyAverage.toStringAsFixed(1),
                        //   icon: Icons.calendar_today,
                        //   subtitle: '회/일',
                        // ),
                        StatCard(
                          label: '최고 연속',
                          value: '$bestStreak일',
                          icon: Icons.local_fire_department,
                          color: Colors.redAccent,
                          isDark: true,
                        ),
                        StatCard(
                          label: '활성 목표',
                          value: '$activeGoalsCount개',
                          icon: Icons.flag,
                          color: Colors.blue,
                          isDark: true,
                        ),
                        StatCard(
                          label: '전월 대비',
                          value: monthDiff >= 0 ? '+$monthDiff' : '$monthDiff',
                          icon: monthDiff >= 0
                              ? Icons.trending_up
                              : Icons.trending_down,
                          color: monthDiff >= 0 ? Colors.green : Colors.orange,
                          isDark: true,
                          // subtitle: '회',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Weekly Breakdown Chart
                    const Text(
                      '주간 분석',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildWeeklyChart(context, weeklyBreakdown),
                    const SizedBox(height: 24),

                    // Goal Breakdown
                    const Text(
                      '목표별 달성 현황',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...goalSuccessCounts.entries.map((entry) {
                      final goal = goals.firstWhere(
                        (g) => g.title == entry.key,
                      );
                      final colorScheme = Theme.of(context).colorScheme;
                      final themeMode = ref
                          .watch(themeModeNotifierProvider)
                          .value;
                      final isDark = themeMode == ThemeMode.dark;
                      final color = isDark
                          ? colorScheme.tertiary.withValues(alpha: 0.8)
                          : Colors.deepPurple.shade400;
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
                                  ? AppColors.getCategoryColor(
                                      goal.category,
                                    ).withValues(alpha: 0.3)
                                  : AppColors.getCategoryColor(
                                      goal.category,
                                    ).withValues(alpha: 0.2),
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
                              color: color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${entry.value}회',
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                              ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context, Map<int, int> weekCounts) {
    if (weekCounts.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxCount = weekCounts.values.reduce(max);
    final weeks = ['1주차', '2주차', '3주차', '4주차', '5주차'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(5, (index) {
                final count = weekCounts[index] ?? 0;
                final height = maxCount > 0 ? (count / maxCount * 100) : 0.0;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Column(
                      children: [
                        Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: height.clamp(20, 100),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          weeks[index],
                          style: const TextStyle(fontSize: 11),
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
