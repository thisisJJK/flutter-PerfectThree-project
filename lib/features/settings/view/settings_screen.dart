import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perfect_three/core/theme/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  // TODO: 실제 앱 버전을 가져오는 함수 (예: package_info_plus 패키지 사용)
  final String _appVersion = 'v1.0.0 (Build 1)';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 현재 테마 모드 상태를 구독합니다.
    final currentThemeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(title: Text("설정")),
      body: ListView(
        children: [
          // 1. 다크 모드 토글 섹션
          SwitchListTile(
            title: Text("다크 모드"),
            subtitle: Text(
              currentThemeMode == ThemeMode.dark
                  ? "현재 다크 모드입니다"
                  : "현재 라이트 모드입니다",
            ),
            value: currentThemeMode == ThemeMode.dark,
            onChanged: (bool isDark) {
              // Provider 상태 변경
              ref.read(themeProvider.notifier).state = isDark
                  ? ThemeMode.dark
                  : ThemeMode.light;
            },
            secondary: const Icon(Icons.brightness_6),
          ),

          const Divider(),

          // 2. 데이터 관리 섹션 (추후 Backup/Restore 기능 추가 예정)
          ListTile(
            leading: const Icon(Icons.archive_outlined),
            title: Text("데이터 백업 / 복원"),
            subtitle: const Text("모든 목표 기록을 파일로 저장합니다."),
            onTap: () {
              // TODO: 데이터 백업/복원 로직 구현
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('준비 중인 기능입니다.')));
            },
          ),

          const Divider(),

          // 3. 앱 정보 섹션
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("앱 정보"),
            subtitle: Text("버전: $_appVersion"),
            onTap: () {
              // AboutDialog 띄우기
              showAboutDialog(
                context: context,
                applicationName: 'Perfect Three',
                applicationVersion: _appVersion,
                applicationIcon: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.blue,
                ),
                children: [const Text("3일 성공 구조를 통해 포기하지 않는 습관을 만드세요.")],
              );
            },
          ),

          // 4. 라이선스 섹션
          ListTile(
            leading: const Icon(Icons.gavel_outlined),
            title: const Text("오픈소스 라이선스"),
            onTap: () {
              // showLicensePage(context: context);
            },
          ),
        ],
      ),
    );
  }
}
