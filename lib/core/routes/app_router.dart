import 'package:go_router/go_router.dart';
import 'package:perfect_three/features/settings/view/settings_screen.dart';
import 'package:perfect_three/features/splash/splash_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/goals/view/home_screen.dart';
import '../../features/goals/view/ongoing/add_goal_screen.dart';

part 'app_router.g.dart';

/// [AppRouter]
/// 앱의 모든 화면 이동 경로를 정의합니다.
@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: '/splash', // 앱 시작 시 첫 화면
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      // 1. 홈 화면
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          // 2. 목표 추가 화면 (홈 화면 위에 팝업처럼 뜸)
          GoRoute(
            path: 'add',
            name: 'add_goal',
            builder: (context, state) => const AddGoalScreen(),
          ),
        ],
      ),
      // 3. 설정 화면
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
