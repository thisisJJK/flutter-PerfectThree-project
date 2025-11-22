import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:perfect_three/data/models/goal.dart';
import 'package:perfect_three/features/goals/viewmodel/goal_viewmodel.dart';

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
  runApp(const ProviderScope(child: MyApp()));
}

/// 앱의 최상위 위젯입니다.
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ViewModel 상태 감시 (데이터 로드)
    final goalsAsync = ref.watch(goalViewModelProvider);
    return MaterialApp(
      title: 'Perfect Three', // 앱 이름 (나중에 Localization 적용 예정)
      theme: ThemeData(
        // 테마 색상 설정 (브랜드 컬러)
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamily: 'Pretendard', // (폰트는 나중에 추가 설정)
      ),
      // 임시 홈 화면 (다음 단계에서 라우터로 교체 예정)
      // 임시 테스트용 코드
      home: Scaffold(
        appBar: AppBar(title: const Text("로직 테스트")),
        body: Center(
          child: goalsAsync.when(
            // 데이터 로딩 중일 때
            loading: () => const CircularProgressIndicator(),
            // 에러 났을 때
            error: (err, stack) => Text('에러: $err'),
            // 데이터가 있을 때
            data: (goals) {
              if (goals.isEmpty) return const Text("목표가 없습니다.");
              return ListView.builder(
                itemCount: goals.length,
                itemBuilder: (context, index) {
                  final goal = goals[index];
                  return ListTile(
                    title: Text(goal.title),
                    subtitle: Text("성공 횟수: ${goal.successCount}"),
                    // 임시로 1일차 체크박스만 보여줌
                    trailing: Checkbox(
                      value: goal.checks[0],
                      onChanged: (value) {
                        // ViewModel의 함수 호출!
                        ref
                            .read(goalViewModelProvider.notifier)
                            .toggleCheck(goal.id, 0);
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // 목표 추가 테스트
            ref
                .read(goalViewModelProvider.notifier)
                .addGoal("테스트 목표 ${DateTime.now().second}");
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
