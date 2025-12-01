import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perfect_three/core/theme/app_colors.dart';
import 'package:perfect_three/core/theme/app_spacing.dart';
import 'package:perfect_three/core/theme/app_theme.dart';
import 'package:perfect_three/core/theme/provider/theme_provider.dart';
import 'package:perfect_three/features/goals/view/stats/all_stats_screen.dart';
import 'package:perfect_three/features/goals/view/stats/monthly_stats_screen.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeNotifierProvider).value;
    final isDark = themeMode == ThemeMode.dark;

    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        body: TabBarView(
          children: [AllStatsScreen(), MonthlyStatsScreen()],
        ),
        floatingActionButton: Container(
          height: 45,
          width: MediaQuery.of(context).size.width * 0.55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radius),
            color: isDark ? Colors.grey[900] : Colors.grey[300],
          ),
          child: TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            indicator: BoxDecoration(
              color: isDark
                  ? AppColors.primaryDark.withValues(alpha: 0.6)
                  : AppColors.primary.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(
                AppSpacing.radius,
              ),
            ),
            splashFactory: NoSplash.splashFactory,
            labelStyle: Font.jua.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
            unselectedLabelStyle: Font.jua.copyWith(fontSize: 15),
            onTap: (index) {},
            tabs: [
              Center(child: Text('전체')),
              Center(child: Text('월별')),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
