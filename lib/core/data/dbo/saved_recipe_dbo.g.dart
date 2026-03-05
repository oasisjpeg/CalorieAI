// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_recipe_dbo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedRecipeDBOAdapter extends TypeAdapter<SavedRecipeDBO> {
  @override
  final int typeId = 20;

  @override
  SavedRecipeDBO read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedRecipeDBO(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      prepTime: fields[3] as int,
      cookTime: fields[4] as int,
      calories: fields[5] as int,
      protein: fields[6] as int,
      carbs: fields[7] as int,
      fat: fields[8] as int,
      ingredients: (fields[9] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      instructions: (fields[10] as List).cast<String>(),
      servingSuggestion: fields[11] as String,
      savedAt: fields[12] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SavedRecipeDBO obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.prepTime)
      ..writeByte(4)
      ..write(obj.cookTime)
      ..writeByte(5)
      ..write(obj.calories)
      ..writeByte(6)
      ..write(obj.protein)
      ..writeByte(7)
      ..write(obj.carbs)
      ..writeByte(8)
      ..write(obj.fat)
      ..writeByte(9)
      ..write(obj.ingredients)
      ..writeByte(10)
      ..write(obj.instructions)
      ..writeByte(11)
      ..write(obj.servingSuggestion)
      ..writeByte(12)
      ..write(obj.savedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedRecipeDBOAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
