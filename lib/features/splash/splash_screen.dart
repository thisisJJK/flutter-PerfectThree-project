import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:perfect_three/features/goals/viewmodel/goal_viewmodel.dart';

import '../../core/utils/custom_logger.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  /// 모든 필수 데이터 로딩이 완료되었는지 확인하는 비동기 함수
  Future<void> _initializeApp(BuildContext context, WidgetRef ref) async {
    // 1. ThemeMode 로드는 이미 main.dart에서 처리되고 있습니다. (themeModeNotifierProvider)

    // 2. 목표 데이터 로딩을 강제로 트리거하여 로딩 완료를 기다립니다.
    // .future를 사용하여 비동기 로딩 완료를 기다립니다.
    await ref.read(goalViewModelProvider.future);

    // 3. 최소 1.5초는 화면에 머물도록 강제 지연 (너무 빨리 사라지면 어색함 방지)
    await Future.delayed(const Duration(milliseconds: 1500));

    CustomLogger.info("✅ 앱 초기화 완료. 홈 화면으로 이동합니다.");

    // 4. 로딩 완료 후 홈 화면으로 이동 (뒤로 가기 방지를 위해 replace)
    if (context.mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 위젯이 빌드된 후 초기화 로직을 실행합니다.
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
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha:  0.7),
              ),
            ),
            const SizedBox(height: 60),
            const CircularProgressIndicator(), // 로딩 중임을 시각적으로 보여줍니다.
          ],
        ),
      ),
    );
  }
}
