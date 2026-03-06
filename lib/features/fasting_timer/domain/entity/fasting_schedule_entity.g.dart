// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fasting_schedule_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FastingScheduleEntityAdapter extends TypeAdapter<FastingScheduleEntity> {
  @override
  final int typeId = 21;

  @override
  FastingScheduleEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FastingScheduleEntity(
      fastingStartHour: fields[0] as int,
      fastingStartMinute: fields[1] as int,
      fastingEndHour: fields[2] as int,
      fastingEndMinute: fields[3] as int,
      isActive: fields[4] as bool,
      lastStartedAt: fields[5] as DateTime?,
      title: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FastingScheduleEntity obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.fastingStartHour)
      ..writeByte(1)
      ..write(obj.fastingStartMinute)
      ..writeByte(2)
      ..write(obj.fastingEndHour)
      ..writeByte(3)
      ..write(obj.fastingEndMinute)
      ..writeByte(4)
      ..write(obj.isActive)
      ..writeByte(5)
      ..write(obj.lastStartedAt)
      ..writeByte(6)
      ..write(obj.title);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FastingScheduleEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
