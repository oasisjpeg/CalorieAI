// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_activity_dbo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserActivityDBOAdapter extends TypeAdapter<UserActivityDBO> {
  @override
  final int typeId = 10;

  @override
  UserActivityDBO read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserActivityDBO(
      fields[0] as String,
      fields[1] as double,
      fields[2] as double,
      fields[3] as DateTime,
      fields[4] as PhysicalActivityDBO,
      fields[5] as String?,
      fields[6] as bool,
      fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserActivityDBO obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.duration)
      ..writeByte(2)
      ..write(obj.burnedKcal)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.physicalActivityDBO)
      ..writeByte(5)
      ..write(obj.healthKitWorkoutId)
      ..writeByte(6)
      ..write(obj.isFromHealthKit)
      ..writeByte(7)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserActivityDBOAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserActivityDBO _$UserActivityDBOFromJson(Map<String, dynamic> json) =>
    UserActivityDBO(
      json['id'] as String,
      (json['duration'] as num).toDouble(),
      (json['burnedKcal'] as num).toDouble(),
      DateTime.parse(json['date'] as String),
      PhysicalActivityDBO.fromJson(
          json['physicalActivityDBO'] as Map<String, dynamic>),
      json['healthKitWorkoutId'] as String?,
      json['isFromHealthKit'] as bool? ?? false,
      json['note'] as String?,
    );

Map<String, dynamic> _$UserActivityDBOToJson(UserActivityDBO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'duration': instance.duration,
      'burnedKcal': instance.burnedKcal,
      'date': instance.date.toIso8601String(),
      'physicalActivityDBO': instance.physicalActivityDBO,
      'healthKitWorkoutId': instance.healthKitWorkoutId,
      'isFromHealthKit': instance.isFromHealthKit,
      'note': instance.note,
    };
