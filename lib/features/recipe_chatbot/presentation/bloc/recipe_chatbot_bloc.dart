import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/services/gemini_service.dart';
import 'package:opennutritracker/core/domain/usecase/get_macro_goal_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_intake_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_kcal_goal_usecase.dart';
import 'package:opennutritracker/features/recipe_chatbot/presentation/bloc/recipe_chatbot_event.dart';
import 'package:opennutritracker/features/recipe_chatbot/presentation/bloc/recipe_chatbot_state.dart';

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
      final totalConsumed = todayBreakfast + todayLunch + todayDinner + todaySnack;
      final totalCaloriesConsumed = totalConsumed.fold(0.0, (sum, intake) => sum + intake.totalKcal);
      final totalProteinConsumed = totalConsumed.fold(0.0, (sum, intake) => sum + intake.totalProteinsGram);
      final totalCarbsConsumed = totalConsumed.fold(0.0, (sum, intake) => sum + intake.totalCarbsGram);
      final totalFatConsumed = totalConsumed.fold(0.0, (sum, intake) => sum + intake.totalFatsGram);
      
      // Get total calorie goal for today
      final totalKcalGoal = await _getKcalGoalUsecase.getKcalGoal();
      
      // Get macro goals based on total calories
      final totalCarbsGoal = await _getMacroGoalUsecase.getCarbsGoal(totalKcalGoal);
      final totalFatGoal = await _getMacroGoalUsecase.getFatsGoal(totalKcalGoal);
      final totalProteinGoal = await _getMacroGoalUsecase.getProteinsGoal(totalKcalGoal);
      
      // Calculate remaining macros
      final remainingNutrients = {
        'calories': totalKcalGoal - totalCaloriesConsumed,
        'protein': totalProteinGoal - totalProteinConsumed,
        'carbs': totalCarbsGoal - totalCarbsConsumed,
        'fat': totalFatGoal - totalFatConsumed,
      };

      // Update filters with remaining nutrients
      final updatedFilters = Map<String, dynamic>.from(event.filters);
      updatedFilters['TARGET_CALORIES'] = (remainingNutrients['calories'] ?? 0).round();
      updatedFilters['MINIMUM_PROTEIN'] = (remainingNutrients['protein'] ?? 0).round();
      updatedFilters['MAXIMUM_CARBS'] = (remainingNutrients['carbs'] ?? 0).round();
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
    return """
    I need ${filters['NUMBER']} recipes in JSON format, designed to fit specific macronutrient goals. Please consider the following user preferences:

    *   **Language:** ${filters['LANGUAGE']} (Choose ONE: English, Spanish, French, German, etc. - The recipe should be written in this language.)
    *   **Recipe Type:** ${filters['RECIPE_TYPE']} (Choose ONE: main course, side dish, snack, dessert, breakfast)
    *   **Cooking Method:** ${filters['COOKING_METHOD']} (Prioritize air fryer. Can include other cooking methods *only if necessary* as a minor step. Options: air fryer, baked, grilled, stovetop)
    *   **Maximum Cooking Time:** ${filters['MAX_COOKING_TIME']} minutes (Target is total cooking time. Be realistic.)
    *   **Pricing:** ${filters['PRICING']} (Choose ONE: budget-friendly, normal, pricier. This reflects the cost of the ingredients per serving.)
    *   **Preferred Meats:** ${filters['PREFERRED_MEATS'].join(', ')} (List preferred meats, separated by commas. Use 'any' if there are no meat preferences.)
    *   **Preferred Vegetables:** ${filters['PREFERRED_VEGETABLES'].join(', ')} (List preferred vegetables, separated by commas. Use 'any' if there are no vegetable preferences.)
    *   **Dietary Restrictions:** ${filters['DIETARY_RESTRICTIONS'].join(', ')} (List any restrictions. Use 'none' if there are no restrictions. Examples: gluten-free, dairy-free, vegetarian, vegan, low-carb, keto)
    *   **Disliked Ingredients:** ${filters['DISLIKED_INGREDIENTS'].join(', ')} (List any ingredients to avoid, separated by commas. Use 'none' if there are no disliked ingredients. Examples: onions, mushrooms, cilantro)
    *   **Preferred Flavors/Cuisines:** ${filters['PREFERRED_FLAVORS']} (Describe desired flavors or cuisines. Examples: spicy, Italian, Asian, Mexican, Mediterranean, BBQ. Use 'any' if there are no specific flavor preferences.)

    *   **Macronutrient Targets (Per Serving):**
        *   Calories: Approximately ${filters['TARGET_CALORIES']} (Prioritize staying close to this value. A tolerance of +/- 50 calories is acceptable, but aim to be as close as possible.)
        *   Protein: At least ${filters['MINIMUM_PROTEIN']} grams (Protein target is important for satiety. Prioritize meeting or exceeding this target.)
        *   Carbs: Up to ${filters['MAXIMUM_CARBS']} grams (Keep carbs *below* this maximum.)
        *   Fat: Up to ${filters['MAXIMUM_FAT']} grams (Keep fat *below* this maximum.)

    Instructions for Recipe Generation:

    1.  Prioritize recipes that can be realistically cooked primarily in an air fryer within the specified time limit. Only include other cooking methods as very minor steps if absolutely necessary.
    2.  Generate the recipe in the specified language. The instructions and ingredient names should be in the selected language.
    3.  Create a recipe that aligns with the chosen pricing category (budget-friendly, normal, pricier). Budget-friendly recipes should use inexpensive ingredients.
    4.  Use the preferred meats and vegetables as much as possible.
    5.  Strictly adhere to any dietary restrictions.
    6.  Ensure the disliked ingredients are completely absent from the recipes.
    7.  Aim for flavor profiles that match the preferred flavors/cuisines.
    8.  **Crucially**, focus on hitting the protein target first, then calories, then staying under the maximum carb and fat targets.
    9.  All quantities in the ingredient list MUST be in metric units (grams, milliliters, etc.).
    10. Nutritional values (calories, protein, carbs, fat) are ESTIMATES. They should be clearly stated for each recipe. If precise nutritional data is unavailable, provide a reasonable estimate.
    11. Include detailed ingredient lists with quantities and units.
    12. Provide clear and easy-to-follow cooking instructions.

    Please provide the response in JSON format with a `recipes` array. Each recipe object in the array MUST include the following fields: `name`, `description`, `prep_time`, `cook_time`, `calories`, `protein`, `carbs`, `fat`, `ingredients`, `instructions`, and `serving_suggestion`.
    From the Nutritional estimates, give only the numbers and not any text to them
    
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
            'name', 'description', 'prep_time', 'cook_time',
            'calories', 'protein', 'carbs', 'fat',
            'ingredients', 'instructions', 'serving_suggestion'
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
