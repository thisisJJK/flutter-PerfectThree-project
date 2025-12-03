import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'notification_settings.g.dart';

@HiveType(typeId: 1)
class NotificationSettings extends HiveObject {
  @HiveField(0)
  bool allowNotifications;

  @HiveField(1)
  bool routineAlerts;

  @HiveField(2)
  String dailyBriefingTime; // "HH:mm" format

  @HiveField(3)
  bool marketingAlerts;

  @HiveField(4)
  bool soundEnabled;

  @HiveField(5)
  bool vibrationEnabled;

  NotificationSettings({
    this.allowNotifications = true,
    this.routineAlerts = true,
    this.dailyBriefingTime = "09:00",
    this.marketingAlerts = false,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  TimeOfDay get timeOfDay {
    final parts = dailyBriefingTime.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  NotificationSettings copyWith({
    bool? allowNotifications,
    bool? routineAlerts,
    String? dailyBriefingTime,
    bool? marketingAlerts,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return NotificationSettings(
      allowNotifications: allowNotifications ?? this.allowNotifications,
      routineAlerts: routineAlerts ?? this.routineAlerts,
      dailyBriefingTime: dailyBriefingTime ?? this.dailyBriefingTime,
      marketingAlerts: marketingAlerts ?? this.marketingAlerts,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }
}
