import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:perfect_three/core/theme/provider/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 현재 테마 모드 상태를 구독합니다.
    final themeModeAsync = ref.watch(themeModeNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text("설정")),
      body: themeModeAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()), // 로딩 중 UI
        error: (e, s) => Center(child: Text('설정 로드 에러: $e')), // 에러 발생 시 UI
        data: (currentThemeMode) {
          return ListView(
            children: [
              // 1. 다크 모드 토글 섹션
              SwitchListTile(
                title: Text("테마 모드"),
                subtitle: Text(
                  currentThemeMode == ThemeMode.dark
                      ? "현재 다크 모드입니다"
                      : "현재 라이트 모드입니다",
                ),
                value: currentThemeMode == ThemeMode.dark,
                onChanged: (bool isDark) {
                  // Provider 상태 변경
                  ref
                      .read(themeModeNotifierProvider.notifier)
                      .setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
                },
                secondary: const Icon(Icons.brightness_6),
              ),

              const Divider(),

              // 2. 데이터 관리 섹션 (향후 구현 예정)
              ListTile(
                leading: const Icon(Icons.archive_outlined),
                title: const Text("데이터 백업 / 복원"),
                subtitle: const Text("모든 목표 기록을 파일로 저장합니다. (준비 중)"),
                onTap: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(
                    content: Text('준비 중인 기능입니다. 빠른 시일 내에 업데이트 될 예정입니다.'),
                    duration: Duration(seconds: 2),
                  ));
                },
              ),

              const Divider(),

              // 3. 앱 정보 섹션
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  final appVersion = snapshot.hasData
                      ? 'v${snapshot.data!.version} (Build ${snapshot.data!.buildNumber})'
                      : 'v1.0.0 (Build 1)';
                  
                  return ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text("앱 정보"),
                    subtitle: Text("버전: $appVersion"),
                    onTap: () {
                      // AboutDialog 띄우기
                      showAboutDialog(
                        context: context,
                        applicationName: 'Perfect Three',
                        applicationVersion: appVersion,
                        applicationIcon: const Icon(
                          Icons.check_circle_outline,
                          color: Colors.blue,
                        ),
                        children: [const Text("3일 성공 구조를 통해 포기하지 않는 습관을 만드세요.")],
                      );
                    },
                  );
                },
              ),

              // 4. 라이선스 섹션
              ListTile(
                leading: const Icon(Icons.gavel_outlined),
                title: const Text("오픈소스 라이선스"),
                onTap: () {
                  showLicensePage(context: context);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
