import 'package:equatable/equatable.dart';
import 'package:calorieai/core/data/dbo/meal_recipe_dbo.dart';
import 'package:calorieai/core/data/dbo/saved_recipe_dbo.dart';
import 'package:calorieai/core/domain/entity/intake_entity.dart';
import 'package:calorieai/core/utils/extensions.dart';
import 'package:calorieai/features/add_meal/domain/entity/meal_entity.dart';
import 'package:calorieai/features/add_meal/domain/entity/meal_nutriments_entity.dart';

/// A user-built "whole meal" / recipe composed of multiple food components.
///
/// Components reuse the AI foodItems map schema so they can be passed
/// straight through to MealEntity.foodItems (rendered by meal detail /
/// meal view as the Ingredients section):
/// {
///   'name': String, 'type': String?,
///   'estimated_grams': double, 'original_grams': double,
///   'calories','protein_g','carbs_g','fat_g','sugar_g',
///   'saturated_fat_g','fiber_g','salt_g': double (absolute at original_grams),
///   'source': String, 'meal_code': String?
/// }
class MealRecipeEntity extends Equatable {
  final String id;
  final String name;
  final double servings;
  final List<Map<String, dynamic>> components;
  final double? cookedWeightGrams;
  final String? thumbnailImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MealRecipeEntity({
    required this.id,
    required this.name,
    required this.servings,
    required this.components,
    this.cookedWeightGrams,
    this.thumbnailImageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Scales an absolute nutrient value of a component to its current grams.
  static double scaledValue(Map<String, dynamic> component, String key) {
    final grams = (component['estimated_grams'] as num? ?? 0).toDouble();
    final original =
        (component['original_grams'] as num? ?? grams).toDouble();
    final ratio = original > 0 ? grams / original : 1.0;
    return ((component[key] as num? ?? 0).toDouble()) * ratio;
  }

  double _totalOf(String key) =>
      components.fold(0.0, (sum, c) => sum + scaledValue(c, key));

  double get totalGrams => components.fold(
      0.0, (sum, c) => sum + ((c['estimated_grams'] as num? ?? 0).toDouble()));

  double get totalKcal => _totalOf('calories');

  double get totalProtein => _totalOf('protein_g');

  double get totalCarbs => _totalOf('carbs_g');

  double get totalFat => _totalOf('fat_g');

  double get totalSugar => _totalOf('sugar_g');

  double get totalSaturatedFat => _totalOf('saturated_fat_g');

  double get totalFiber => _totalOf('fiber_g');

  /// Batch weight used for per-100g math and serving size.
  double get batchGrams =>
      (cookedWeightGrams != null && cookedWeightGrams! > 0)
          ? cookedWeightGrams!
          : totalGrams;

  double get servingGrams => servings > 0 ? batchGrams / servings : batchGrams;

  double get kcalPerServing => servings > 0
      ? totalKcal * servingGrams / batchGrams
      : totalKcal;

  MealNutrimentsEntity get nutrimentsPer100 {
    final grams = batchGrams;
    double? per100(double value) => grams > 0 ? value * 100 / grams : null;
    return MealNutrimentsEntity(
        energyKcal100: per100(totalKcal),
        carbohydrates100: per100(totalCarbs),
        fat100: per100(totalFat),
        proteins100: per100(totalProtein),
        sugars100: per100(totalSugar),
        saturatedFat100: per100(totalSaturatedFat),
        fiber100: per100(totalFiber));
  }

  /// Components with macros re-normalized to the current estimated_grams,
  /// ready to be stored or used as MealEntity.foodItems.
  List<Map<String, dynamic>> normalizedComponents() {
    return components.map((component) {
      final map = Map<String, dynamic>.from(component);
      final grams = (map['estimated_grams'] as num? ?? 0).toDouble();
      for (final key in [
        'calories',
        'protein_g',
        'carbs_g',
        'fat_g',
        'sugar_g',
        'saturated_fat_g',
        'fiber_g',
        'salt_g',
      ]) {
        map[key] = scaledValue(component, key);
      }
      map['estimated_grams'] = grams;
      map['original_grams'] = grams;
      return map;
    }).toList();
  }

  /// Converts the recipe to a MealEntity so the whole existing pipeline
  /// (MealDetailScreen, intake logging, health sync) works unchanged.
  MealEntity toMealEntity() {
    return MealEntity(
        code: 'recipe:$id',
        name: name,
        url: null,
        mealQuantity: batchGrams.toStringAsFixed(0),
        mealUnit: 'g',
        servingQuantity: servingGrams,
        servingUnit: 'g',
        servingSize: null,
        nutriments: nutrimentsPer100,
        source: MealSourceEntity.recipe,
        thumbnailImageUrl: thumbnailImageUrl,
        mainImageUrl: thumbnailImageUrl,
        foodItems: normalizedComponents());
  }

  /// Normalizes a list of raw components (e.g. while editing) for saving.
  static List<Map<String, dynamic>> normalize(
      List<Map<String, dynamic>> components) {
    return components.map((component) {
      final map = Map<String, dynamic>.from(component);
      final grams = (map['estimated_grams'] as num? ?? 0).toDouble();
      for (final key in [
        'calories',
        'protein_g',
        'carbs_g',
        'fat_g',
        'sugar_g',
        'saturated_fat_g',
        'fiber_g',
        'salt_g',
      ]) {
        map[key] = scaledValue(component, key);
      }
      map['original_grams'] = grams;
      return map;
    }).toList();
  }

  /// Builds a component map from a product/search result, using [grams]
  /// of that meal.
  static Map<String, dynamic> componentFromMeal(MealEntity meal, double grams) {
    final nutriments = meal.nutriments;
    double absolute(double? per100) => (per100 ?? 0) * grams / 100;
    return {
      'name': meal.name ?? '?',
      'type': 'other',
      'estimated_grams': grams,
      'original_grams': grams,
      'calories': absolute(nutriments.energyKcal100),
      'protein_g': absolute(nutriments.proteins100),
      'carbs_g': absolute(nutriments.carbohydrates100),
      'fat_g': absolute(nutriments.fat100),
      'sugar_g': absolute(nutriments.sugars100),
      'saturated_fat_g': absolute(nutriments.saturatedFat100),
      'fiber_g': absolute(nutriments.fiber100),
      'salt_g': 0.0,
      'source': meal.source.name,
      'meal_code': meal.code,
    };
  }

  /// Builds a component from a logged diary intake (uses its logged amount).
  static Map<String, dynamic> componentFromIntake(IntakeEntity intake) =>
      componentFromMeal(intake.meal, intake.amount);

  /// Flattens another recipe into component maps (scaled to [grams] of that
  /// recipe's batch; pass its full batchGrams to embed the whole recipe).
  static List<Map<String, dynamic>> componentsFromRecipe(
      MealRecipeEntity recipe, double grams) {
    final ratio = recipe.batchGrams > 0 ? grams / recipe.batchGrams : 1.0;
    return recipe.normalizedComponents().map((component) {
      final map = Map<String, dynamic>.from(component);
      for (final key in [
        'estimated_grams',
        'original_grams',
        'calories',
        'protein_g',
        'carbs_g',
        'fat_g',
        'sugar_g',
        'saturated_fat_g',
        'fiber_g',
        'salt_g',
      ]) {
        map[key] = ((map[key] as num? ?? 0).toDouble()) * ratio;
      }
      map['source'] = 'recipe';
      map['meal_code'] = recipe.id;
      return map;
    }).toList();
  }

  /// Converts Gemini analysis items (image or description) to components.
  static List<Map<String, dynamic>> componentsFromGeminiItems(List items) {
    return items.map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      final grams = (map['estimated_grams'] as num? ?? 0).toDouble();
      map['original_grams'] = grams;
      map['source'] = 'ai';
      return map;
    }).toList();
  }

  /// A manual component: absolute macros for the given grams.
  static Map<String, dynamic> componentFromCustom({
    required String name,
    required double grams,
    double calories = 0,
    double protein = 0,
    double carbs = 0,
    double fat = 0,
  }) {
    return {
      'name': name,
      'type': 'other',
      'estimated_grams': grams,
      'original_grams': grams,
      'calories': calories,
      'protein_g': protein,
      'carbs_g': carbs,
      'fat_g': fat,
      'sugar_g': 0.0,
      'saturated_fat_g': 0.0,
      'fiber_g': 0.0,
      'salt_g': 0.0,
      'source': 'custom',
      'meal_code': null,
    };
  }

  /// Converts a saved AI recipe idea (SavedRecipeDBO) into a recipe.
  /// Ingredient weights are parsed where possible; nutrition (which the AI
  /// only gives per serving) is distributed across components by weight.
  factory MealRecipeEntity.fromSavedRecipeDBO(SavedRecipeDBO recipe) {
    final components = <Map<String, dynamic>>[];
    double totalGrams = 0;
    for (final ingredient in recipe.ingredients) {
      final grams = _parseIngredientGrams(ingredient);
      totalGrams += grams;
      components.add({
        'name': ingredient['name']?.toString() ?? '?',
        'type': 'other',
        'estimated_grams': grams,
        'original_grams': grams,
        'calories': 0.0,
        'protein_g': 0.0,
        'carbs_g': 0.0,
        'fat_g': 0.0,
        'sugar_g': 0.0,
        'saturated_fat_g': 0.0,
        'fiber_g': 0.0,
        'salt_g': 0.0,
        'source': 'ai',
        'meal_code': null,
      });
    }
    if (totalGrams <= 0) totalGrams = 1;
    for (final component in components) {
      final share =
          (component['estimated_grams'] as num).toDouble() / totalGrams;
      component['calories'] = recipe.calories * share;
      component['protein_g'] = recipe.protein * share;
      component['carbs_g'] = recipe.carbs * share;
      component['fat_g'] = recipe.fat * share;
    }
    final now = DateTime.now();
    return MealRecipeEntity(
        id: recipe.id,
        name: recipe.title,
        servings: 1,
        components: components,
        createdAt: recipe.savedAt,
        updatedAt: now);
  }

  static double _parseIngredientGrams(Map<String, dynamic> ingredient) {
    final quantity = (ingredient['quantity'] as Object?).asDoubleOrNull() ??
        double.tryParse(ingredient['quantity']?.toString() ?? '');
    final unit = ingredient['unit']?.toString().toLowerCase() ?? '';
    if (quantity == null) return 100;
    switch (unit) {
      case 'kg':
        return quantity * 1000;
      case 'l':
        return quantity * 1000;
      case 'g':
      case 'ml':
      case 'gram':
      case 'grams':
        return quantity;
      default:
        // Unknown units (pcs, tbsp, cups…) fall back to a rough estimate
        return quantity > 0 && quantity <= 20 ? quantity * 30 : quantity;
    }
  }

  factory MealRecipeEntity.fromMealRecipeDBO(MealRecipeDBO dbo) {
    return MealRecipeEntity(
        id: dbo.id,
        name: dbo.name,
        servings: dbo.servings,
        components: dbo.components
            .map((c) => Map<String, dynamic>.from(c))
            .toList(),
        cookedWeightGrams: dbo.cookedWeightGrams,
        thumbnailImageUrl: dbo.thumbnailImageUrl,
        createdAt: dbo.createdAt,
        updatedAt: dbo.updatedAt);
  }

  MealRecipeDBO toMealRecipeDBO() {
    return MealRecipeDBO(
        id: id,
        name: name,
        servings: servings,
        components: normalizedComponents(),
        cookedWeightGrams: cookedWeightGrams,
        thumbnailImageUrl: thumbnailImageUrl,
        createdAt: createdAt,
        updatedAt: updatedAt);
  }

  @override
  List<Object?> get props => [id, name, servings, updatedAt];
}
