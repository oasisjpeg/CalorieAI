import 'package:calorieai/core/data/repository/meal_recipe_repository.dart';
import 'package:calorieai/features/recipes/domain/entity/meal_recipe_entity.dart';

class GetMealRecipesUsecase {
  final MealRecipeRepository _repository;

  GetMealRecipesUsecase(this._repository);

  Future<List<MealRecipeEntity>> getAllRecipes() {
    return _repository.getAllRecipes();
  }

  Future<MealRecipeEntity?> getRecipe(String id) {
    return _repository.getRecipe(id);
  }
}
