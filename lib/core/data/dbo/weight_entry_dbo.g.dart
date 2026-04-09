// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_entry_dbo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WeightEntryDBOAdapter extends TypeAdapter<WeightEntryDBO> {
  @override
  final int typeId = 22;

  @override
  WeightEntryDBO read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeightEntryDBO(
      date: fields[0] as DateTime,
      weightKG: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, WeightEntryDBO obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.weightKG);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeightEntryDBOAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
