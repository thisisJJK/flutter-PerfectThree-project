// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GoalAdapter extends TypeAdapter<Goal> {
  @override
  final int typeId = 0;

  @override
  Goal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Goal(
      id: fields[0] as String,
      title: fields[1] as String,
      checks: (fields[2] as List).cast<bool>(),
      successCount: fields[3] as int,
      lastUpdatedDate: fields[4] as DateTime,
      isOngoing: fields[5] as bool,
      sortOrder: fields[6] as int,
      createdAt: fields[7] as DateTime,
      lastDay: fields[8] as bool,
      category: fields[9] as String,
      successDates: (fields[10] as List).cast<DateTime>(),
    );
  }

  @override
  void write(BinaryWriter writer, Goal obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.checks)
      ..writeByte(3)
      ..write(obj.successCount)
      ..writeByte(4)
      ..write(obj.lastUpdatedDate)
      ..writeByte(5)
      ..write(obj.isOngoing)
      ..writeByte(6)
      ..write(obj.sortOrder)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.lastDay)
      ..writeByte(9)
      ..write(obj.category)
      ..writeByte(10)
      ..write(obj.successDates);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
