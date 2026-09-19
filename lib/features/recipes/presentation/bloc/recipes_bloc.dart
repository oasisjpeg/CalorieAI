import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:calorieai/core/domain/usecase/get_config_usecase.dart';
import 'package:calorieai/features/recipes/domain/entity/meal_recipe_entity.dart';
import 'package:calorieai/features/recipes/domain/usecase/delete_meal_recipe_usecase.dart';
import 'package:calorieai/features/recipes/domain/usecase/get_meal_recipes_usecase.dart';
import 'package:calorieai/features/recipes/domain/usecase/save_meal_recipe_usecase.dart';

part 'recipes_event.dart';

part 'recipes_state.dart';

class RecipesBloc extends Bloc<RecipesEvent, RecipesState> {
  final log = Logger('RecipesBloc');

  final GetMealRecipesUsecase _getMealRecipesUsecase;
  final SaveMealRecipeUsecase _saveMealRecipeUsecase;
  final DeleteMealRecipeUsecase _deleteMealRecipeUsecase;
  final GetConfigUsecase _getConfigUsecase;

  RecipesBloc(this._getMealRecipesUsecase, this._saveMealRecipeUsecase,
      this._deleteMealRecipeUsecase, this._getConfigUsecase)
      : super(RecipesInitial()) {
    on<LoadRecipesEvent>((event, emit) async {
      emit(RecipesLoadingState());
      try {
        final config = await _getConfigUsecase.getConfig();
        final recipes = await _getMealRecipesUsecase.getAllRecipes();
        emit(RecipesLoadedState(
            recipes: recipes, usesImperialUnits: config.usesImperialUnits));
      } catch (error) {
        log.severe(error);
        emit(RecipesFailedState());
      }
    });
    on<SaveRecipeEvent>((event, emit) async {
      try {
        await _saveMealRecipeUsecase.saveRecipe(event.recipe);
        add(const LoadRecipesEvent());
      } catch (error) {
        log.severe(error);
        emit(RecipesFailedState());
      }
    });
    on<DeleteRecipeEvent>((event, emit) async {
      try {
        await _deleteMealRecipeUsecase.deleteRecipe(event.recipeId);
        add(const LoadRecipesEvent());
      } catch (error) {
        log.severe(error);
        emit(RecipesFailedState());
      }
    });
  }
}
