part of 'recipes_bloc.dart';

abstract class RecipesState extends Equatable {
  const RecipesState();
}

class RecipesInitial extends RecipesState {
  @override
  List<Object?> get props => [];
}

class RecipesLoadingState extends RecipesState {
  @override
  List<Object?> get props => [];
}

class RecipesLoadedState extends RecipesState {
  final List<MealRecipeEntity> recipes;
  final bool usesImperialUnits;

  const RecipesLoadedState(
      {required this.recipes, this.usesImperialUnits = false});

  @override
  List<Object?> get props => [recipes, usesImperialUnits];
}

class RecipesFailedState extends RecipesState {
  @override
  List<Object?> get props => [];
}
