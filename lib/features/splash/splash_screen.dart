import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:perfect_three/features/goals/viewmodel/goal_viewmodel.dart';

import '../../shared/utils/custom_logger.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  /// 모든 필수 데이터 로딩이 완료되었는지 확인하는 비동기 함수
  Future<void> _initializeApp(BuildContext context, WidgetRef ref) async {
    await ref.read(goalViewModelProvider.future);

    await Future.delayed(const Duration(milliseconds: 1500));

    CustomLogger.info("✅ 앱 초기화 완료. 홈 화면으로 이동합니다.");

    if (context.mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp(context, ref);
    });

    // 스플래시 화면 UI
    return Scaffold(
      // [테마 대응] 배경색은 ScaffodBackgroundColor를 따릅니다.
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 앱 로고 (임시 아이콘 사용)
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              "Perfect Three",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "3일, 작은 성공이 만드는 큰 습관",
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
