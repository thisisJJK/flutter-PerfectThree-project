import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:perfect_three/core/theme/app_colors.dart';
import 'package:perfect_three/core/theme/app_spacing.dart';
import 'package:perfect_three/core/theme/app_theme.dart';
import 'package:perfect_three/core/theme/provider/theme_provider.dart';
import 'package:perfect_three/features/ads/banner_ad_widget.dart';
import 'package:perfect_three/features/goals/view/my_routin_screen.dart';
import 'package:perfect_three/features/goals/view/ongoing_goal_screen.dart';
import 'package:perfect_three/features/goals/view/stats_screen.dart';
import 'package:perfect_three/features/goals/viewmodel/goal_viewmodel.dart';
import 'package:perfect_three/features/goals/widgets/category_chips.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeNotifierProvider).value;
    final isDark = themeMode == ThemeMode.dark;
    final isStatsScreen = ref
        .watch(goalViewModelProvider.notifier)
        .isStatsScreen;

    return Scaffold(
      body: DefaultTabController(
        initialIndex: 0,
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Perfect Three", style: TextStyle(fontSize: 24)),

            centerTitle: false,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: () {
                  //설정 화면 이동
                  context.push('/settings');
                },
                icon: Icon(Icons.settings),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: isStatsScreen
                  ? Size.fromHeight(40)
                  : Size.fromHeight(96),
              child: Column(
                children: [
                  ClipRRect(
                    child: Container(
                      height: 45,
                      margin: EdgeInsets.symmetric(horizontal: 20),
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

                        onTap: (value) {
                          setState(() {
                            ref
                                .read(goalViewModelProvider.notifier)
                                .toggleIsStatsScreen(value);
                          });
                        },
                        tabs: [
                          Center(child: Text('진행중')),
                          Center(child: Text('내 루틴')),
                          Center(child: Text('통계')),
                        ],
                      ),
                    ),
                  ),
                  if (!isStatsScreen)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
                      child: CategoryChips(isOngoing: true),
                    ),
                ],
              ),
            ),
          ),
          body: TabBarView(
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
