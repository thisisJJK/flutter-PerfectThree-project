import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:perfect_three/core/theme/app_colors.dart';
import 'package:perfect_three/core/theme/app_typography.dart';
import 'package:perfect_three/core/theme/provider/theme_provider.dart';
import 'package:perfect_three/features/ads/banner_ad_widget.dart';
import 'package:perfect_three/features/goals/view/completed_goal_screen.dart';
import 'package:perfect_three/features/goals/view/ongoing_goal_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeNotifierProvider).value;
    final isDark = themeMode == ThemeMode.dark;
    return Scaffold(
      body: DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Perfect Three"),
            titleTextStyle: AppTypography.title.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
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
              preferredSize: Size.fromHeight(50),
              child: ClipRRect(
                borderRadius: BorderRadiusGeometry.circular(10),
                child: Container(
                  height: 45,

                  margin: EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isDark ? Colors.grey[900] : Colors.grey[200],
                  ),
                  child: TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: isDark
                          ? AppColors.primaryDark.withValues(alpha: 0.4)
                          : AppColors.primary.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelStyle: TextStyle(
                      fontSize: 16,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),

                    splashFactory: NoSplash.splashFactory,
                    tabs: [
                      Center(child: Text('진행중')),
                      Center(child: Text('완료')),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: TabBarView(
            children: [OngoingGoalScreen(), CompletedGoalScreen()],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: SizedBox(height: 60, child: BottomBannerAd()),
      ),
    );
  }
}
