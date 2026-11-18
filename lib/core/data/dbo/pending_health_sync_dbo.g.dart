// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_health_sync_dbo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PendingHealthSyncDBOAdapter extends TypeAdapter<PendingHealthSyncDBO> {
  @override
  final int typeId = 24;

  @override
  PendingHealthSyncDBO read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PendingHealthSyncDBO(
      id: fields[0] as String,
      payloadJson: fields[1] as String,
      createdAt: fields[2] as DateTime,
      retryCount: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PendingHealthSyncDBO obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.payloadJson)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.retryCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingHealthSyncDBOAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
