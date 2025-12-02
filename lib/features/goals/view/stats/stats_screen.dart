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
          physics: NeverScrollableScrollPhysics(),
          children: [AllStatsScreen(), MonthlyStatsScreen()],
        ),
        floatingActionButton: Container(
          height: 48,
          width: 200,
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceElevatedDark : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            border: Border.all(
              color: (isDark ? AppColors.dividerDark : AppColors.divider)
                  .withValues(alpha: 0.3),
              width: 0.5,
            ),
            // iOS 스타일 부드러운 그림자
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            indicator: BoxDecoration(
              color: isDark ? AppColors.primaryDark : AppColors.primary,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            ),
            splashFactory: NoSplash.splashFactory,
            labelStyle: Font.main.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
            unselectedLabelStyle: Font.main.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
              letterSpacing: -0.2,
            ),
            labelColor: Colors.white,
            unselectedLabelColor: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
            onTap: (index) {},
            tabs: [
              Tab(text: '전체'),
              Tab(text: '월별'),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
