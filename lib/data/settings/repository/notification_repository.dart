import 'package:hive_flutter/hive_flutter.dart';
import 'package:perfect_three/data/settings/model/notification_settings.dart';

class NotificationRepository {
  static const String _boxName = 'notification_settings';
  static const String _key = 'settings';

  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<NotificationSettings>(_boxName);
    }
  }

  NotificationSettings getSettings() {
    final box = Hive.box<NotificationSettings>(_boxName);
    return box.get(_key) ?? NotificationSettings();
  }

  Future<void> saveSettings(NotificationSettings settings) async {
    final box = Hive.box<NotificationSettings>(_boxName);
    await box.put(_key, settings);
  }
}
