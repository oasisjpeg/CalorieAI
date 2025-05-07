import 'package:bloc/bloc.dart';
import 'package:opennutritracker/features/recipe_chatbot/data/recipe_chatbot_service.dart';
import 'package:opennutritracker/features/recipe_chatbot/domain/recipe_entity.dart';
import 'package:opennutritracker/features/recipe_chatbot/presentation/bloc/recipe_chatbot_event.dart';
import 'package:opennutritracker/features/recipe_chatbot/presentation/bloc/recipe_chatbot_state.dart';

class RecipeChatbotBloc extends Bloc<RecipeChatbotEvent, RecipeChatbotState> {
  final RecipeChatbotService _recipeChatbotService;
  final Map<String, String> _parameters = {};
  RecipeChatbotBloc(this._recipeChatbotService)
      : super(RecipeChatbotInitial()) {
    on<RecipeChatbotLoad>((event, emit) async {
      await getRecipes(emit);
    });
    on<RecipeChatbotUpdateParameter>((event, emit) {
      _parameters[event.key] = event.value;
      getRecipes(emit);
    });
    on<RecipeChatbotClear>((event, emit) {
      _parameters.clear();
      getRecipes(emit);
    });
  }

  Future<void> getRecipes(Emitter<RecipeChatbotState> emit) async {
    emit(RecipeChatbotLoading());
    try {
      final parameters = <String, dynamic>{
        'LANGUAGE': _parameters['LANGUAGE'] ?? 'English',
        'RECIPE_TYPE': _parameters['RECIPE_TYPE'] ?? 'main course',
        'COOKING_METHOD': _parameters['COOKING_METHOD'] ?? 'air fryer',
        'MAX_COOKING_TIME': _parameters['MAX_COOKING_TIME'] ?? '30',
        'PRICING': _parameters['PRICING'] ?? 'normal',
        'PREFERRED_MEATS': _parameters['PREFERRED_MEATS'] ?? 'any',
        'PREFERRED_VEGETABLES': _parameters['PREFERRED_VEGETABLES'] ?? 'any',
        'DIETARY_RESTRICTIONS': _parameters['DIETARY_RESTRICTIONS'] ?? 'none',
        'DISLIKED_INGREDIENTS': _parameters['DISLIKED_INGREDIENTS'] ?? 'none',
        'PREFERRED_FLAVORS': _parameters['PREFERRED_FLAVORS'] ?? 'any',
        'TARGET_CALORIES': _parameters['TARGET_CALORIES'] ?? '600',
        'MINIMUM_PROTEIN': _parameters['MINIMUM_PROTEIN'] ?? '40',
        'MAXIMUM_CARBS': _parameters['MAXIMUM_CARBS'] ?? '70',
        'MAXIMUM_FAT': _parameters['MAXIMUM_FAT'] ?? '30',
        'NUMBER': _parameters['NUMBER'] ?? '3',
      };

      print(parameters);
      final List<RecipeEntity> recipes = await _recipeChatbotService.getRecipes(
        language: _parameters['LANGUAGE'] ?? 'English',
        recipeType: _parameters['RECIPE_TYPE'] ?? 'main course',
        cookingMethod: _parameters['COOKING_METHOD'] ?? 'air fryer',
        maxCookingTime:
            int.tryParse(_parameters['MAX_COOKING_TIME'] ?? '30') ?? 30,
        pricing: _parameters['PRICING'] ?? 'normal',
        preferredMeats: _parameters['PREFERRED_MEATS'] ?? 'any',
        preferredVegetables: _parameters['PREFERRED_VEGETABLES'] ?? 'any',
        dietaryRestrictions: _parameters['DIETARY_RESTRICTIONS'] ?? 'none',
        dislikedIngredients: _parameters['DISLIKED_INGREDIENTS'] ?? 'none',
        preferredFlavors: _parameters['PREFERRED_FLAVORS'] ?? 'any',
        targetCalories:
            int.tryParse(_parameters['TARGET_CALORIES'] ?? '600') ?? 600,
        minimumProtein:
            int.tryParse(_parameters['MINIMUM_PROTEIN'] ?? '40') ?? 40,
        maximumCarbs: int.tryParse(_parameters['MAXIMUM_CARBS'] ?? '70') ?? 70,
        maximumFat: int.tryParse(_parameters['MAXIMUM_FAT'] ?? '30') ?? 30,
        number: int.tryParse(_parameters['NUMBER'] ?? '3') ?? 3,
      );

      emit(RecipeChatbotLoaded(recipes));
    } catch (e) {
      emit(RecipeChatbotError(e.toString()));
    }
  }
}
