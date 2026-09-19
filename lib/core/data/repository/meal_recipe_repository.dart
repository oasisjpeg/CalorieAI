import 'package:calorieai/core/data/datasource/local/meal_recipe_local_data_source.dart';
import 'package:calorieai/features/recipes/domain/entity/meal_recipe_entity.dart';

class MealRecipeRepository {
  final MealRecipeLocalDataSource _dataSource;

  MealRecipeRepository(this._dataSource);

  Future<List<MealRecipeEntity>> getAllRecipes() async {
    final dbos = await _dataSource.getAllRecipes();
    return dbos.map(MealRecipeEntity.fromMealRecipeDBO).toList();
  }

  Future<MealRecipeEntity?> getRecipe(String id) async {
    final dbo = await _dataSource.getRecipe(id);
    return dbo == null ? null : MealRecipeEntity.fromMealRecipeDBO(dbo);
  }

  Future<void> saveRecipe(MealRecipeEntity recipe) async {
    await _dataSource.saveRecipe(recipe.toMealRecipeDBO());
  }

  Future<void> deleteRecipe(String id) async {
    await _dataSource.deleteRecipe(id);
  }
}
