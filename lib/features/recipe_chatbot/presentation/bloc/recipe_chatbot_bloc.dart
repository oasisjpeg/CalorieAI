import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:calorieai/core/services/gemini_service.dart';
import 'package:calorieai/core/domain/usecase/get_macro_goal_usecase.dart';
import 'package:calorieai/core/domain/usecase/get_intake_usecase.dart';
import 'package:calorieai/core/domain/usecase/get_kcal_goal_usecase.dart';
import 'package:calorieai/features/recipe_chatbot/presentation/bloc/recipe_chatbot_event.dart';
import 'package:calorieai/features/recipe_chatbot/presentation/bloc/recipe_chatbot_state.dart';

class RecipeChatbotBloc extends Bloc<RecipeChatbotEvent, RecipeChatbotState> {
  final GeminiService _geminiService;
  final GetKcalGoalUsecase _getKcalGoalUsecase;
  final GetMacroGoalUsecase _getMacroGoalUsecase;
  final GetIntakeUsecase _getIntakeUseCase;
  final log = Logger('RecipeChatbotBloc');

  RecipeChatbotBloc(
    this._geminiService,
    this._getKcalGoalUsecase,
    this._getMacroGoalUsecase,
    this._getIntakeUseCase,
  ) : super(RecipeChatbotInitial()) {
    on<FetchRecipes>(_onFetchRecipes);
    on<RecipeSelected>(_onRecipeSelected);
    on<RecipeUnselected>(_onRecipeUnselected);
  }

  void _onRecipeSelected(
    RecipeSelected event,
    Emitter<RecipeChatbotState> emit,
  ) {
    emit(RecipeChatbotSuccess(
      recipes: (state as RecipeChatbotSuccess).recipes,
      selectedRecipe: event.recipe,
    ));
  }

  void _onRecipeUnselected(
    RecipeUnselected event,
    Emitter<RecipeChatbotState> emit,
  ) {
    emit(RecipeChatbotSuccess(
      recipes: (state as RecipeChatbotSuccess).recipes,
      selectedRecipe: null,
    ));
  }

  Future<void> _onFetchRecipes(
    FetchRecipes event,
    Emitter<RecipeChatbotState> emit,
  ) async {
    emit(RecipeChatbotLoading());
    try {
      // Get all intakes for today
      final todayBreakfast = await _getIntakeUseCase.getTodayBreakfastIntake();
      final todayLunch = await _getIntakeUseCase.getTodayLunchIntake();
      final todayDinner = await _getIntakeUseCase.getTodayDinnerIntake();
      final todaySnack = await _getIntakeUseCase.getTodaySnackIntake();

      // Calculate total consumed nutrients
      final totalConsumed =
          todayBreakfast + todayLunch + todayDinner + todaySnack;
      final totalCaloriesConsumed =
          totalConsumed.fold(0.0, (sum, intake) => sum + intake.totalKcal);
      final totalProteinConsumed = totalConsumed.fold(
          0.0, (sum, intake) => sum + intake.totalProteinsGram);
      final totalCarbsConsumed =
          totalConsumed.fold(0.0, (sum, intake) => sum + intake.totalCarbsGram);
      final totalFatConsumed =
          totalConsumed.fold(0.0, (sum, intake) => sum + intake.totalFatsGram);

      // Get total calorie goal for today
      final totalKcalGoal = await _getKcalGoalUsecase.getKcalGoal();

      // Get macro goals based on total calories
      final totalCarbsGoal =
          await _getMacroGoalUsecase.getCarbsGoal(totalKcalGoal);
      final totalFatGoal =
          await _getMacroGoalUsecase.getFatsGoal(totalKcalGoal);
      final totalProteinGoal =
          await _getMacroGoalUsecase.getProteinsGoal(totalKcalGoal);

      // Calculate remaining macros
      final remainingNutrients = {
        'calories': totalKcalGoal - totalCaloriesConsumed,
        'protein': totalProteinGoal - totalProteinConsumed,
        'carbs': totalCarbsGoal - totalCarbsConsumed,
        'fat': totalFatGoal - totalFatConsumed,
      };

      // Update filters with remaining nutrients
      final updatedFilters = Map<String, dynamic>.from(event.filters);
      updatedFilters['TARGET_CALORIES'] =
          (remainingNutrients['calories'] ?? 0).round();
      updatedFilters['MINIMUM_PROTEIN'] =
          (remainingNutrients['protein'] ?? 0).round();
      updatedFilters['MAXIMUM_CARBS'] =
          (remainingNutrients['carbs'] ?? 0).round();
      updatedFilters['MAXIMUM_FAT'] = (remainingNutrients['fat'] ?? 0).round();

      final prompt = _buildPrompt(updatedFilters);
      final response = await _geminiService.generate(prompt);

      final recipes = _parseRecipes(response);
      emit(RecipeChatbotSuccess(recipes: recipes));
    } catch (e, stackTrace) {
      log.severe('Error fetching recipes', e, stackTrace);
      emit(RecipeChatbotError(message: e.toString()));
    }
  }

  String _buildPrompt(Map<String, dynamic> filters) {
    final userContext = filters['CONTEXT']?.toString().isNotEmpty == true
        ? '\n    *   **User Context:** ${filters['CONTEXT']}\n'
        : '';

    return """
    I need 5 recipes in JSON format, designed to fit specific macronutrient goals. ${filters['CONTEXT']?.isNotEmpty == true ? 'Here\'s what the user is looking for: ${filters['CONTEXT']}' : ''}
Please consider the following user preferences: $userContext

Language: ${filters['LANGUAGE']} (The recipe should be written in this language.)

Recipe Type: ${filters['RECIPE_TYPE']} (Choose ONE: main course, side dish, snack, dessert, breakfast)

Dietary Restrictions: ${filters['DIETARY_RESTRICTIONS'].join(', ')} (List any restrictions. Use 'none' if there are no restrictions. Examples: gluten-free, dairy-free, vegetarian, vegan, low-carb, keto)

Macronutrient & Calorie Targets (Per Serving):

If Recipe Type is "main course":

Calories: Approximately ${filters['TARGET_CALORIES']} (Aim to be as close as possible, better to go under than over, but try to approach the target closely.)

Protein: At least ${filters['MINIMUM_PROTEIN']} grams (Prioritize meeting/exceeding this target.)

Carbs: Up to ${filters['MAXIMUM_CARBS']} grams (Do not exceed.)

Fat: Up to ${filters['MAXIMUM_FAT']} grams (Do not exceed.)

If Recipe Type is NOT "main course" (e.g., dessert, snack, side dish, breakfast):

Calories: Always create a healthy, low-calorie recipe (ideally between 100–250 kcal per serving, never using the full available calorie budget, regardless of daily calories left).

Protein, carbs, fat: Make healthy, balanced choices, no need to hit main-course macronutrient targets.

Instructions for Recipe Generation:

For main courses: strictly try to hit the protein target first, then approach the calorie target, then ensure carbs and fat are under maximums.

For all other recipe types: do not use the full daily or main course calorie target. Always create a healthy, simple, low-calorie, but high-protein recipe (100–250 kcal per serving unless otherwise specified), and focus on reasonable and balanced macros, not main-course targets.

Recipes must be realistically cookable, with normal prep and cook times.

Write all recipe text (ingredient names, steps) in the selected language.

Recipes should be budget-friendly.

Strictly follow all listed dietary restrictions.

Exclude any disliked ingredients.

Ingredient quantities MUST be in metric units (grams, milliliters, etc.).

Nutritional values (calories, protein, carbs, fat) should be estimated and only the numbers (no units or extra text).

Include a detailed ingredients array with quantity and metric unit in object notation.

Give clear, step-by-step instructions.

Include a serving suggestion for each recipe.

Output JSON Format:

Only return a JSON object with a recipes array, with each recipe containing:
the instructions must be in the selected language
json
{
  "recipes": [
    {
      "name": "Recipe Name",
      "description": "Brief description of the recipe.",
      "prep_time": 10,
      "cook_time": 15,
      "calories": 350,
      "protein": 30,
      "carbs": 20,
      "fat": 15,
      "ingredients": [
        {"name": "Ingredient 1", "quantity": 100, "unit": "g"},
        {"name": "Ingredient 2", "quantity": 5, "unit": "ml"},
        {"name": "Ingredient 3", "quantity": 1, "unit": "piece"}
      ],
      "instructions": [
        "1. Do this.",
        "2. Then that.",
        "3. Finally, this."
      ],
      "serving_suggestion": "Serve with something complementary."
    }
  ]
}
Recipes must never assign a high calorie value to dessert, snack, side dish, or breakfast types, regardless of remaining calories for the day, but still try to use high protein.

Only main courses should use the full available calorie and macro targets.
    
    """;
  }

  List<Map<String, dynamic>> _parseRecipes(String response) {
    try {
      final decoded = json.decode(response);
      if (decoded is Map && decoded.containsKey('recipes')) {
        final recipes = List<Map<String, dynamic>>.from(decoded['recipes']);
        // Validate required fields in each recipe
        for (var recipe in recipes) {
          final requiredFields = [
            'name',
            'description',
            'prep_time',
            'cook_time',
            'calories',
            'protein',
            'carbs',
            'fat',
            'ingredients',
            'instructions',
            'serving_suggestion'
          ];
          for (var field in requiredFields) {
            if (!recipe.containsKey(field)) {
              throw FormatException('Missing required field: $field');
            }
          }
        }
        return recipes;
      }
      throw FormatException('Invalid JSON format: Missing recipes array');
    } catch (e) {
      log.severe('Error parsing recipes: $e');
      throw FormatException('Could not parse recipe response: ${e.toString()}');
    }
  }
}
