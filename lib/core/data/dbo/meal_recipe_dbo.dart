import 'package:hive/hive.dart';

part 'meal_recipe_dbo.g.dart';

@HiveType(typeId: 25)
class MealRecipeDBO extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double servings;

  /// Components use the same map schema as MealDBO.foodItems:
  /// name, type, estimated_grams, original_grams, calories, protein_g,
  /// carbs_g, fat_g, sugar_g, saturated_fat_g, fiber_g, salt_g,
  /// plus 'source' and 'meal_code' for traceability.
  @HiveField(3)
  List<Map<String, dynamic>> components;

  /// Optional cooked/total batch weight. When null, the sum of
  /// component grams is used as the batch weight.
  @HiveField(4)
  double? cookedWeightGrams;

  @HiveField(5)
  String? thumbnailImageUrl;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime updatedAt;

  MealRecipeDBO({
    required this.id,
    required this.name,
    required this.servings,
    required this.components,
    this.cookedWeightGrams,
    this.thumbnailImageUrl,
    required this.createdAt,
    required this.updatedAt,
  });
}
