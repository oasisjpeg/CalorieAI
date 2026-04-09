// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'water_entry_dbo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WaterEntryDBOAdapter extends TypeAdapter<WaterEntryDBO> {
  @override
  final int typeId = 23;

  @override
  WaterEntryDBO read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WaterEntryDBO(
      date: fields[0] as DateTime,
      amountML: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, WaterEntryDBO obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.amountML);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WaterEntryDBOAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
