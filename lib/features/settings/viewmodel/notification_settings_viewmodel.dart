import 'package:flutter/material.dart';
import 'package:perfect_three/core/services/notification_service.dart';
import 'package:perfect_three/data/settings/model/notification_settings.dart';
import 'package:perfect_three/data/settings/repository/notification_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_settings_viewmodel.g.dart';

@Riverpod(keepAlive: true)
NotificationRepository notificationRepository(NotificationRepositoryRef ref) {
  return NotificationRepository();
}

@Riverpod(keepAlive: true)
NotificationService notificationService(NotificationServiceRef ref) {
  return NotificationService();
}

@riverpod
class NotificationSettingsViewModel extends _$NotificationSettingsViewModel {
  late final NotificationRepository _repository;
  late final NotificationService _service;

  @override
  NotificationSettings build() {
    _repository = ref.watch(notificationRepositoryProvider);
    _service = ref.watch(notificationServiceProvider);

    _checkPermissionStatus();

    return _repository.getSettings();
  }

  Future<void> _checkPermissionStatus() async {
    final hasPermission = await _service.checkPermissionStatus();
    // 시스템 권한이 없는 경우에만 강제로 끔
    if (!hasPermission && state.allowNotifications) {
      state = state.copyWith(allowNotifications: false);
      await _repository.saveSettings(state);
    }
  }

  Future<void> updateAllowNotifications(bool value) async {
    if (value) {
      final granted = await _service.requestPermissions();
      if (!granted) {
        // 권한이 거부되었거나 영구적으로 거부된 경우 설정 화면으로 이동 유도
        // 여기서는 바로 설정 화면을 엽니다.
        await _service.openSettings();

        // 설정에서 돌아왔을 때를 대비해 상태를 false로 유지하지만,
        // 실제로는 앱이 다시 포커스될 때 권한을 확인하는 로직이 있으면 좋습니다.
        // 현재 구조에서는 사용자가 다시 토글을 시도해야 합니다.
        state = state.copyWith(allowNotifications: false);
        return;
      }
    } else {
      await _service.cancelAllNotifications();
    }

    state = state.copyWith(allowNotifications: value);
    await _saveAndSchedule();
  }

  Future<void> updateRoutineAlerts(bool value) async {
    state = state.copyWith(routineAlerts: value);
    await _saveAndSchedule();
  }

  Future<void> updateDailyBriefingTime(TimeOfDay time) async {
    final timeString =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    state = state.copyWith(dailyBriefingTime: timeString);
    await _saveAndSchedule();
  }

  Future<void> updateMarketingAlerts(bool value) async {
    state = state.copyWith(marketingAlerts: value);
    await _saveAndSchedule();
  }

  Future<void> updateSoundEnabled(bool value) async {
    state = state.copyWith(soundEnabled: value);
    await _saveAndSchedule();
  }

  Future<void> updateVibrationEnabled(bool value) async {
    state = state.copyWith(vibrationEnabled: value);
    await _saveAndSchedule();
  }

  Future<void> _saveAndSchedule() async {
    await _repository.saveSettings(state);

    if (state.allowNotifications && state.routineAlerts) {
      final time = state.timeOfDay;
      await _service.scheduleDailyNotification(
        id: 0,
        title: '오늘의 목표를 확인하세요!',
        body: '3일 성공을 위해 오늘도 화이팅!',
        hour: time.hour,
        minute: time.minute,
      );
    } else {
      await _service.cancelNotification(0);
    }
  }
}
