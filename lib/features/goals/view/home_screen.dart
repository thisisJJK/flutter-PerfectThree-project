import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:perfect_three/core/theme/app_colors.dart';
import 'package:perfect_three/core/theme/app_spacing.dart';
import 'package:perfect_three/core/theme/app_theme.dart';
import 'package:perfect_three/core/theme/provider/theme_provider.dart';
import 'package:perfect_three/features/goals/provider/screen_provider.dart';
import 'package:perfect_three/features/goals/view/myroutin/my_routin_screen.dart';
import 'package:perfect_three/features/goals/view/ongoing/ongoing_goal_screen.dart';
import 'package:perfect_three/features/goals/view/stats/stats_screen.dart';
import 'package:perfect_three/shared/ads/banner_ad_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeNotifierProvider).value;
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      body: DefaultTabController(
        initialIndex: 0,
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              "Perfect Three",
              style: Font.display.copyWith(
                fontSize: 28, // iOS 스타일 제목 크기
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            centerTitle: false,
            elevation: 0,
            scrolledUnderElevation: 0,
            actions: [
              IconButton(
                onPressed: () {
                  context.push('/settings');
                },
                icon: Icon(
                  Icons.settings_outlined,
                ),
              ),
              SizedBox(width: AppSpacing.s),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: Container(
                height: 48,
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceElevatedDark
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  border: Border.all(
                    color: (isDark ? AppColors.dividerDark : AppColors.divider)
                        .withValues(alpha: 0.3),
                    width: 0.5,
                  ),
                ),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: isDark ? AppColors.primaryDark : AppColors.primary,
                    borderRadius: BorderRadius.circular(
                      AppSpacing.radiusXl,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (isDark ? AppColors.primaryDark : AppColors.primary)
                                .withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
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
                  onTap: (index) =>
                      ref.read(screenProvider.notifier).state = index == 2,
                  tabs: const [
                    Tab(text: '진행중'),
                    Tab(text: '내 루틴'),
                    Tab(text: '통계'),
                  ],
                ),
              ),
            ),
          ),
          body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [OngoingGoalScreen(), MyRoutinScreen(), StatsScreen()],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: SizedBox(height: 60, child: BottomBannerAd()),
      ),
    );
  }
}
