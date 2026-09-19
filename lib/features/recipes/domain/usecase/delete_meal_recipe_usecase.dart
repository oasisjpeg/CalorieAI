import 'package:calorieai/core/data/repository/meal_recipe_repository.dart';

class DeleteMealRecipeUsecase {
  final MealRecipeRepository _repository;

  DeleteMealRecipeUsecase(this._repository);

  Future<void> deleteRecipe(String id) {
    return _repository.deleteRecipe(id);
  }
}
