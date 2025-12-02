import 'dart:math';

import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:perfect_three/core/theme/app_colors.dart';
import 'package:perfect_three/core/theme/app_spacing.dart';
import 'package:perfect_three/core/theme/app_theme.dart';
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
    final themeMode = ref.watch(themeModeNotifierProvider).value;
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      body: Column(
        children: [
          // Month Selector
          Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => _changeMonth(-1),
                  icon: Icon(
                    Icons.chevron_left_rounded,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                Text(
                  DateFormat('yyyy년 MM월').format(_selectedMonth),
                  style: Font.display.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                IconButton(
                  onPressed: () => _changeMonth(1),
                  icon: Icon(
                    Icons.chevron_right_rounded,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
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
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 64,
                            color: isDark
                                ? AppColors.textTertiaryDark
                                : AppColors.textTertiary,
                          ),
                          const SizedBox(height: AppSpacing.m),
                          Text(
                            '이 달의 달성 기록이 없습니다.',
                            style: Font.main.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Calculate derived stats
                final activeGoalsCount = activeGoals.length;
                final bestStreak = _calculateBestStreak(allSuccessDates);
                final monthDiff = totalSuccesses - prevMonthSuccesses;
                final weeklyBreakdown = _getWeeklyBreakdown(allSuccessDates);

                return ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    0,
                    AppSpacing.screenPadding,
                    88,
                  ),
                  children: [
                    Text(
                      '월간 분석',
                      style: Font.display.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
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
                          label: '총 성공',
                          value: '$totalSuccesses회',
                          icon: Icons.check_circle_outline_rounded,
                          color: AppColors.success,
                          isDark: isDark,
                        ),
                        StatCard(
                          label: '최고 연속',
                          value: '$bestStreak일',
                          icon: Icons.local_fire_department_rounded,
                          color: AppColors.error,
                          isDark: isDark,
                        ),
                        StatCard(
                          label: '활성 목표',
                          value: '$activeGoalsCount개',
                          icon: Icons.flag_outlined,
                          color: AppColors.info,
                          isDark: isDark,
                        ),
                        StatCard(
                          label: '전월 대비',
                          value: monthDiff >= 0 ? '+$monthDiff' : '$monthDiff',
                          icon: monthDiff >= 0
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          color: monthDiff >= 0
                              ? AppColors.success
                              : AppColors.warning,
                          isDark: isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Weekly Breakdown Chart
                    Text(
                      '주간 분석',
                      style: Font.display.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    _buildWeeklyChart(context, weeklyBreakdown, isDark),
                    const SizedBox(height: AppSpacing.xl),

                    // Goal Breakdown
                    Text(
                      '목표별 달성 현황',
                      style: Font.display.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    ...goalSuccessCounts.entries.map((entry) {
                      final goal = goals.firstWhere(
                        (g) => g.title == entry.key,
                      );
                      final categoryColor = AppColors.getCategoryColor(
                        goal.category,
                      );

                      return Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.s),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.surfaceDark
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radius,
                          ),
                          border: Border.all(
                            color:
                                (isDark
                                        ? AppColors.dividerDark
                                        : AppColors.divider)
                                    .withValues(alpha: 0.3),
                            width: 0.5,
                          ),
                          // iOS 스타일 그림자
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withValues(alpha: 0.2)
                                  : Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
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
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusS,
                              ),
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
                            style: Font.main.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                            ),
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
                            child: Text(
                              '${entry.value}회',
                              style: Font.main.copyWith(
                                color: isDark
                                    ? AppColors.primaryDark
                                    : AppColors.primary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
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

  Widget _buildWeeklyChart(
    BuildContext context,
    Map<int, int> weekCounts,
    bool isDark,
  ) {
    if (weekCounts.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxCount = weekCounts.values.reduce(max);
    final weeks = ['1주차', '2주차', '3주차', '4주차', '5주차'];

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
                          style: Font.main.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.primaryDark
                                : AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: height.clamp(20, 100),
                          decoration: BoxDecoration(
                            color:
                                (isDark
                                        ? AppColors.primaryDark
                                        : AppColors.primary)
                                    .withValues(alpha: 0.4),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          weeks[index],
                          style: Font.main.copyWith(
                            fontSize: 11,
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
}
