import 'package:calorieai/core/data/repository/meal_recipe_repository.dart';
import 'package:calorieai/features/recipes/domain/entity/meal_recipe_entity.dart';

class SaveMealRecipeUsecase {
  final MealRecipeRepository _repository;

  SaveMealRecipeUsecase(this._repository);

  Future<void> saveRecipe(MealRecipeEntity recipe) {
    return _repository.saveRecipe(recipe);
  }
}
