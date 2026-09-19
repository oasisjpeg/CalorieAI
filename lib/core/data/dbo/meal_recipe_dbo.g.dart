// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_recipe_dbo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MealRecipeDBOAdapter extends TypeAdapter<MealRecipeDBO> {
  @override
  final int typeId = 25;

  @override
  MealRecipeDBO read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MealRecipeDBO(
      id: fields[0] as String,
      name: fields[1] as String,
      servings: fields[2] as double,
      components: (fields[3] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      cookedWeightGrams: fields[4] as double?,
      thumbnailImageUrl: fields[5] as String?,
      createdAt: fields[6] as DateTime,
      updatedAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MealRecipeDBO obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.servings)
      ..writeByte(3)
      ..write(obj.components)
      ..writeByte(4)
      ..write(obj.cookedWeightGrams)
      ..writeByte(5)
      ..write(obj.thumbnailImageUrl)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealRecipeDBOAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
