import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:perfect_three/core/theme/app_spacing.dart';
import 'package:perfect_three/core/theme/provider/theme_provider.dart';
import 'package:perfect_three/features/goals/viewmodel/goal_viewmodel.dart';

class MonthlyStatsScreen extends ConsumerStatefulWidget {
  const MonthlyStatsScreen({super.key});

  @override
  ConsumerState<MonthlyStatsScreen> createState() => _MonthlyStatsScreenState();
}

class _MonthlyStatsScreenState extends ConsumerState<MonthlyStatsScreen> {
  DateTime _selectedMonth = DateTime.now();

  void _changeMonth(int offset) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + offset,
      );
    });
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
                // Filter successes in this month
                int totalSuccesses = 0;
                Map<String, int> goalSuccessCounts = {};

                for (var goal in goals) {
                  int count = 0;
                  // successDates가 null일 수 있으므로 안전하게 처리 (기존 데이터 호환)
                  // ignore: unnecessary_null_comparison
                  if (goal.successDates != null) {
                    for (var date in goal.successDates) {
                      if (date.year == _selectedMonth.year &&
                          date.month == _selectedMonth.month) {
                        count++;
                      }
                    }
                  }

                  if (count > 0) {
                    goalSuccessCounts[goal.title] = count;
                    totalSuccesses += count;
                  }
                }

                if (totalSuccesses == 0) {
                  return const Center(child: Text('이 달의 달성 기록이 없습니다.'));
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Summary Card
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
                              '총 3일 성공 횟수',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$totalSuccesses회',
                              style: Theme.of(context).textTheme.displayMedium
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

                    // Breakdown
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
                                  ? colorScheme.tertiary.withValues(alpha: 0.4)
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
                            child: Text(
                              '${entry.value}회',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
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
}
