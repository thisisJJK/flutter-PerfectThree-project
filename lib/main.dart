import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:perfect_three/core/theme/app_theme.dart';
import 'package:perfect_three/core/theme/provider/theme_provider.dart';
import 'package:perfect_three/data/models/goal.dart';
import 'package:perfect_three/routes/app_router.dart';

import 'core/utils/logger.dart';

/// 앱의 시작점입니다.
void main() async {
  // Flutter 엔진과 위젯 바인딩을 초기화합니다. (비동기 작업 전 필수)
  WidgetsFlutterBinding.ensureInitialized();
  // 1. Hive 초기화
  await Hive.initFlutter();

  // 2. Adapter 등록 (Hive가 Goal 클래스를 이해하도록)
  Hive.registerAdapter(GoalAdapter());

  // 3. Box 열기 (미리 열어두면 앱 속도가 빨라짐)
  await Hive.openBox<Goal>('goals_box');

  CustomLogger.info("🚀 Perfect Three 앱이 시작됩니다. (Hive 초기화 완료)");

  // ProviderScope로 앱을 감싸서 Riverpod 상태 관리를 사용할 수 있게 합니다.
  runApp(ProviderScope(child: MyApp()));
}

/// 앱의 최상위 위젯입니다.
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 라우터 설정 가져오기
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeNotifierProvider).value;
    return MaterialApp.router(
      routerConfig: router,
      title: 'Perfect Three', // 앱 이름 (나중에 Localization 적용 예정)
      themeMode: themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,

      // 임시 홈 화면 (다음 단계에서 라우터로 교체 예정)
      // 임시 테스트용 코드
    );
  }
}
