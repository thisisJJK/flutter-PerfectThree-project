// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationSettingsAdapter extends TypeAdapter<NotificationSettings> {
  @override
  final int typeId = 1;

  @override
  NotificationSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationSettings(
      allowNotifications: fields[0] as bool,
      routineAlerts: fields[1] as bool,
      dailyBriefingTime: fields[2] as String,
      marketingAlerts: fields[3] as bool,
      soundEnabled: fields[4] as bool,
      vibrationEnabled: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationSettings obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.allowNotifications)
      ..writeByte(1)
      ..write(obj.routineAlerts)
      ..writeByte(2)
      ..write(obj.dailyBriefingTime)
      ..writeByte(3)
      ..write(obj.marketingAlerts)
      ..writeByte(4)
      ..write(obj.soundEnabled)
      ..writeByte(5)
      ..write(obj.vibrationEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
