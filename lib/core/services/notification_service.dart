import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:perfect_three/data/goal/models/goal.dart';
import 'package:perfect_three/shared/utils/custom_logger.dart';
import 'package:perfect_three/shared/utils/date_utils.dart' as utils;
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static const List<String> cheerMessages = [
    "작심삼일도 10번이면 한 달입니다! 오늘도 화이팅!",
    "포기하지 않는 것이 가장 큰 재능입니다.",
    "오늘의 작은 노력이 내일의 큰 변화를 만듭니다.",
    "당신은 생각보다 훨씬 강합니다. 끝까지 해내세요!",
    "성공은 매일 반복되는 작은 노력의 합입니다.",
    "지금 흘리는 땀방울이 내일의 기쁨이 됩니다.",
    "시작이 반입니다. 이미 절반은 성공했습니다!",
    "당신의 꿈을 응원합니다. 오늘도 힘내세요!",
    "어제보다 나은 오늘을 만들어가고 계시군요!",
    "꾸준함이 답입니다. 오늘도 한 걸음 더!",
  ];
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    await _configureLocalTimeZone();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestSoundPermission: false,
          requestBadgePermission: false,
          requestAlertPermission: false,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  Future<bool> requestPermissions() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<bool> shouldShowRequestRationale() async {
    return await Permission.notification.shouldShowRequestRationale;
  }

  Future<void> openSettings() async {
    await openAppSettings();
  }

  Future<bool> checkPermissionStatus() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_briefing_channel',
          'Daily Briefing',
          channelDescription: 'Daily briefing notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> scheduleCheerNotification(TimeOfDay time) async {
    final random = Random();
    final message = cheerMessages[random.nextInt(cheerMessages.length)];

    await _notificationsPlugin.zonedSchedule(
      1, // ID for cheer notification
      '오늘의 응원',
      message,
      _nextInstanceOfTime(time.hour, time.minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'cheer_channel',
          'Cheer Messages',
          channelDescription: 'Daily cheer messages',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    CustomLogger.info('응원 메시지 알림 예약됨: $message at ${time.hour}:${time.minute}');
  }

  Future<void> cancelCheerNotification() async {
    await _notificationsPlugin.cancel(1);
  }

  Future<void> scheduleSuccessReminders(
    List<Goal> goals,
    TimeOfDay time,
  ) async {
    // 기존 알림 취소 (ID 100~)
    await cancelSuccessReminders();

    int notificationId = 100;
    final now = utils.DateUtils.now();

    for (var goal in goals) {
      if (!goal.isOngoing) continue;

      // 목표 생성일로부터 3일째 되는 날 계산
      // 0일차(생성), 1일차, 2일차(성공일)
      // 현재 구현상 3일 주기로 반복되므로, 다음 3일차(성공일)를 계산해야 함

      // 현재 날짜와 생성일의 차이
      final diff = utils.DateUtils.differenceDay(now, goal.createdAt);

      // 현재 주기 (0~2)
      final currentCycleDay = diff % 3;

      // 다음 성공일(2일차)까지 남은 일수
      // 0일차 -> 2일 뒤
      // 1일차 -> 1일 뒤
      // 2일차 -> 오늘 (이미 지났으면 다음 주기 2일 뒤가 아니라 3일 뒤가 되어야 하나?
      // 로직상 2일차에 성공 체크를 하므로, 2일차 당일 아침에 알림을 주는 것이 맞음)

      int daysUntilSuccess = 2 - currentCycleDay;
      if (daysUntilSuccess < 0) daysUntilSuccess += 3;

      // 만약 오늘이 성공일인데 이미 시간이 지났다면?
      // _nextInstanceOfTime과 유사한 로직 필요하지만, 여기서는 특정 날짜를 계산해야 함

      final nextSuccessDate = now.add(Duration(days: daysUntilSuccess));

      // 시간 설정
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        nextSuccessDate.year,
        nextSuccessDate.month,
        nextSuccessDate.day,
        time.hour,
        time.minute,
      );

      // 만약 계산된 시간이 현재보다 이전이라면 (예: 오늘이 성공일인데 알림 시간이 지남)
      // 다음 주기의 성공일로 설정 (3일 뒤)
      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
        scheduledDate = scheduledDate.add(const Duration(days: 3));
      }

      await _notificationsPlugin.zonedSchedule(
        notificationId++,
        '작심삼일 성공의 날!',
        '${goal.title} 목표 달성까지 얼마 안 남았습니다. 화이팅!',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'success_channel',
            'Success Reminders',
            channelDescription: '3-day success reminders',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      CustomLogger.info('성공 알림 예약됨: ${goal.title} at $scheduledDate');
    }
  }

  Future<void> cancelSuccessReminders() async {
    // ID 100부터 200까지 취소 (충분한 범위)
    for (int i = 100; i < 200; i++) {
      await _notificationsPlugin.cancel(i);
    }
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
