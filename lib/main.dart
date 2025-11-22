import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/utils/logger.dart';

/// 앱의 시작점입니다.
void main() async {
  // Flutter 엔진과 위젯 바인딩을 초기화합니다. (비동기 작업 전 필수)
  WidgetsFlutterBinding.ensureInitialized();

  // 앱 시작 로그
  CustomLogger.info("🚀 Perfect Three 앱이 시작됩니다.");

  // ProviderScope로 앱을 감싸서 Riverpod 상태 관리를 사용할 수 있게 합니다.
  runApp(const ProviderScope(child: MyApp()));
}

/// 앱의 최상위 위젯입니다.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Perfect Three', // 앱 이름 (나중에 Localization 적용 예정)
      theme: ThemeData(
        // 테마 색상 설정 (브랜드 컬러)
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamily: 'Pretendard', // (폰트는 나중에 추가 설정)
      ),
      // 임시 홈 화면 (다음 단계에서 라우터로 교체 예정)
      home: const Scaffold(
        body: Center(child: Text("Perfect Three 초기 설정 완료!")),
      ),
    );
  }
}
