part of 'recipes_bloc.dart';

abstract class RecipesEvent extends Equatable {
  const RecipesEvent();
}

class LoadRecipesEvent extends RecipesEvent {
  const LoadRecipesEvent();

  @override
  List<Object?> get props => [];
}

class SaveRecipeEvent extends RecipesEvent {
  final MealRecipeEntity recipe;

  const SaveRecipeEvent(this.recipe);

  @override
  List<Object?> get props => [recipe];
}

class DeleteRecipeEvent extends RecipesEvent {
  final String recipeId;

  const DeleteRecipeEvent(this.recipeId);

  @override
  List<Object?> get props => [recipeId];
}
