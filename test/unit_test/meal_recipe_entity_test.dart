import 'package:calorieai/features/recipes/domain/entity/meal_recipe_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> component({
    double grams = 100,
    double kcal = 200,
    double protein = 10,
    double carbs = 20,
    double fat = 5,
  }) =>
      {
        'name': 'item',
        'type': 'other',
        'estimated_grams': grams,
        'original_grams': grams,
        'calories': kcal,
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

  MealRecipeEntity recipe({
    double servings = 2,
    double? cookedWeight,
    List<Map<String, dynamic>>? components,
  }) =>
      MealRecipeEntity(
        id: 'r1',
        name: 'Test',
        servings: servings,
        components: components ?? [component()],
        cookedWeightGrams: cookedWeight,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );

  test('totals sum component macros', () {
    final r = recipe(components: [component(grams: 100, kcal: 200), component(grams: 50, kcal: 100)]);
    expect(r.totalGrams, 150);
    expect(r.totalKcal, 300);
  });

  test('editing grams scales macros by ratio', () {
    final c = component(grams: 200);
    c['original_grams'] = 100.0; // captured at 100g, now set to 200g
    expect(MealRecipeEntity.scaledValue(c, 'calories'), 400);
    expect(MealRecipeEntity.scaledValue(c, 'protein_g'), 20);
  });

  test('per-100g nutriments use batch weight', () {
    final r = recipe(components: [component(grams: 200, kcal: 400)]);
    expect(r.nutrimentsPer100.energyKcal100, 200);
    // cooked weight override: same macros spread over 400g cooked weight
    final cooked = recipe(cookedWeight: 400, components: [component(grams: 200, kcal: 400)]);
    expect(cooked.nutrimentsPer100.energyKcal100, 100);
  });

  test('servings split the batch', () {
    final r = recipe(servings: 4, components: [component(grams: 400, kcal: 800)]);
    expect(r.servingGrams, 100);
    expect(r.kcalPerServing, 200);
  });

  test('toMealEntity produces loggable meal', () {
    final r = recipe(servings: 2, components: [component(grams: 200, kcal: 400)]);
    final meal = r.toMealEntity();
    expect(meal.mealUnit, 'g');
    expect(meal.servingQuantity, 100); // 200g batch / 2 servings
    expect(meal.hasServingValues, isTrue);
    expect(meal.nutriments.energyKcal100, 200);
    expect(meal.foodItems, isNotNull);
    expect(meal.foodItems!.length, 1);
    // normalized: original_grams == estimated_grams after conversion
    expect(meal.foodItems![0]['original_grams'], meal.foodItems![0]['estimated_grams']);
  });

  test('nested recipe flattens proportionally', () {
    final inner = recipe(servings: 1, components: [component(grams: 200, kcal: 400)]);
    final flattened = MealRecipeEntity.componentsFromRecipe(inner, 100); // half the batch
    expect(flattened.length, 1);
    expect(flattened[0]['estimated_grams'], 100);
    expect(flattened[0]['calories'], 200);
  });
}
