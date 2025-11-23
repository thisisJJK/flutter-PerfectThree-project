// 파일 위치: lib/core/providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Hive 추가
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../utils/custom_logger.dart';

part 'theme_provider.g.dart'; // 코드 생성 파일

// [상수 정의] 설정 데이터를 저장할 Hive Box 이름과 Key
const String settingsBoxName = 'settings_box';
const String themeKey = 'themeMode';

/// ThemeMode를 Hive에 저장하기 위해 String으로 변환합니다.
String themeModeToString(ThemeMode mode) {
  // 'ThemeMode.light' -> 'light'로 변환
  return mode.toString().split('.').last;
}

/// Hive에서 불러온 String을 ThemeMode로 변환합니다.
ThemeMode stringToThemeMode(String? str) {
  switch (str) {
    case 'dark':
      return ThemeMode.dark;
    case 'light':
      return ThemeMode.light;
    case 'system':
      return ThemeMode.system;
    default:
      return ThemeMode.system; // 저장된 값이 없으면 기본값은 라이트 모드
  }
}

/// [ThemeModeNotifier]
/// 테마 모드를 Hive에 영구적으로 저장하고 관리하는 Notifier입니다.
@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  late Box _settingsBox;

  // 1. 초기화 (build) - 비동기 작업으로 초기 상태를 로드합니다.
  @override
  Future<ThemeMode> build() async {
    // 1. Hive Box 열기
    if (!Hive.isBoxOpen(settingsBoxName)) {
      _settingsBox = await Hive.openBox(settingsBoxName);
    } else {
      _settingsBox = Hive.box(settingsBoxName);
    }

    // 2. Hive에서 저장된 값 불러오기
    final savedThemeString = _settingsBox.get(themeKey) as String?;

    // 3. ThemeMode로 변환하여 초기 상태를 설정
    final initialMode = stringToThemeMode(savedThemeString);
    CustomLogger.info("🎨 테마 설정 로드 완료: $initialMode");

    return initialMode;
  }

  /// 4. 외부에서 호출하여 테마를 변경하고 Hive에 저장하는 메서드
  Future<void> setThemeMode(ThemeMode newMode) async {
    // 상태를 로딩으로 잠시 변경 (UI는 로딩을 무시해도 됩니다)
    state = const AsyncValue.loading();

    try {
      // Hive에 새로운 테마 값 저장
      await _settingsBox.put(themeKey, themeModeToString(newMode));

      // 상태를 새로운 값으로 업데이트하여 UI에 반영
      state = AsyncValue.data(newMode);
      CustomLogger.info("🎨 테마 설정 변경 및 저장 완료: $newMode");
    } catch (e, stackTrace) {
      CustomLogger.error("테마 저장 실패", e, stackTrace);
      // 에러가 나도 앱이 멈추지 않도록 에러 상태를 전달합니다.
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
