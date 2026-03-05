import 'package:hive/hive.dart';

part 'saved_recipe_dbo.g.dart';

@HiveType(typeId: 20)
class SavedRecipeDBO extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  int prepTime;

  @HiveField(4)
  int cookTime;

  @HiveField(5)
  int calories;

  @HiveField(6)
  int protein;

  @HiveField(7)
  int carbs;

  @HiveField(8)
  int fat;

  @HiveField(9)
  List<Map<String, dynamic>> ingredients;

  @HiveField(10)
  List<String> instructions;

  @HiveField(11)
  String servingSuggestion;

  @HiveField(12)
  DateTime savedAt;

  SavedRecipeDBO({
    required this.id,
    required this.title,
    required this.description,
    required this.prepTime,
    required this.cookTime,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.ingredients,
    required this.instructions,
    required this.servingSuggestion,
    required this.savedAt,
  });
}
