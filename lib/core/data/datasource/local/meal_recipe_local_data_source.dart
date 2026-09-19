import 'package:hive/hive.dart';
import 'package:calorieai/core/data/dbo/meal_recipe_dbo.dart';

class MealRecipeLocalDataSource {
  static const String _boxName = 'meal_recipes';
  Box<MealRecipeDBO>? _box;

  Future<Box<MealRecipeDBO>> get box async {
    _box ??= await Hive.openBox<MealRecipeDBO>(_boxName);
    return _box!;
  }

  Future<List<MealRecipeDBO>> getAllRecipes() async {
    final recipes = (await box).values.toList();
    recipes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return recipes;
  }

  Future<MealRecipeDBO?> getRecipe(String id) async {
    return (await box).get(id);
  }

  Future<void> saveRecipe(MealRecipeDBO recipe) async {
    await (await box).put(recipe.id, recipe);
  }

  Future<void> deleteRecipe(String id) async {
    await (await box).delete(id);
  }
}
