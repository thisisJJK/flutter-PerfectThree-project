// Perfect Three 앱의 위젯 테스트
//
// 이 테스트는 Perfect Three 앱의 주요 위젯들이 올바르게 렌더링되는지 확인합니다.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:perfect_three/data/models/goal.dart';
import 'package:perfect_three/main.dart';

void main() {
  setUpAll(() async {
    // 테스트를 위한 Hive 초기화
    await Hive.initFlutter();
    Hive.registerAdapter(GoalAdapter());
    await Hive.openBox<Goal>('goals_box');
  });

  tearDownAll(() async {
    // 테스트 후 정리
    await Hive.close();
  });

  testWidgets('앱이 성공적으로 시작되고 스플래시 화면이 표시되는지 테스트', (WidgetTester tester) async {
    // 앱 빌드
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    // 스플래시 화면이 표시되었는지 확인 (스플래시 후 홈으로 이동하므로 홈 화면 확인)
    // 스플래시는 자동으로 홈으로 이동하므로 홈 화면 타이틀 확인
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('Perfect Three'), findsWidgets);
  });

  testWidgets('홈 화면에 탭이 올바르게 표시되는지 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // 홈 화면의 탭들이 표시되는지 확인
    expect(find.text('진행중'), findsOneWidget);
    expect(find.text('내 루틴'), findsOneWidget);
    expect(find.text('통계'), findsOneWidget);
  });

  testWidgets('설정 화면으로 이동할 수 있는지 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // 설정 아이콘 찾기
    final settingsIcon = find.byIcon(Icons.settings);
    expect(settingsIcon, findsOneWidget);

    // 설정 버튼 탭
    await tester.tap(settingsIcon);
    await tester.pumpAndSettle();

    // 설정 화면이 표시되는지 확인
    expect(find.text('설정'), findsOneWidget);
    expect(find.text('테마 모드'), findsOneWidget);
  });
}
