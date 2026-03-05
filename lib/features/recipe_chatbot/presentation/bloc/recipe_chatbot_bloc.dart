import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:calorieai/core/data/datasource/local/saved_recipe_local_data_source.dart';
import 'package:calorieai/core/data/dbo/saved_recipe_dbo.dart';
import 'package:calorieai/core/services/gemini_service.dart';
import 'package:calorieai/core/domain/usecase/get_macro_goal_usecase.dart';
import 'package:calorieai/core/domain/usecase/get_intake_usecase.dart';
import 'package:calorieai/core/domain/usecase/get_kcal_goal_usecase.dart';
import 'package:calorieai/features/recipe_chatbot/presentation/bloc/recipe_chatbot_event.dart';
import 'package:calorieai/features/recipe_chatbot/presentation/bloc/recipe_chatbot_state.dart';
import 'package:uuid/uuid.dart';

class RecipeChatbotBloc extends Bloc<RecipeChatbotEvent, RecipeChatbotState> {
  final GeminiService _geminiService;
  final GetKcalGoalUsecase _getKcalGoalUsecase;
  final GetMacroGoalUsecase _getMacroGoalUsecase;
  final GetIntakeUsecase _getIntakeUseCase;
  final SavedRecipeLocalDataSource _savedRecipeDataSource;
  final log = Logger('RecipeChatbotBloc');
  final _uuid = const Uuid();

  // Conversation history to maintain context between requests
  final List<Map<String, dynamic>> _conversationHistory = [];

  RecipeChatbotBloc(
    this._geminiService,
    this._getKcalGoalUsecase,
    this._getMacroGoalUsecase,
    this._getIntakeUseCase,
    this._savedRecipeDataSource,
  ) : super(RecipeChatbotInitial()) {
    on<FetchRecipes>(_onFetchRecipes);
    on<FetchMoreRecipes>(_onFetchMoreRecipes);
    on<RecipeSelected>(_onRecipeSelected);
    on<RecipeUnselected>(_onRecipeUnselected);
    on<ToggleSaveRecipe>(_onToggleSaveRecipe);
    on<LoadSavedRecipes>(_onLoadSavedRecipes);
    on<ClearConversation>(_onClearConversation);
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

  Future<void> _onFetchMoreRecipes(
    FetchMoreRecipes event,
    Emitter<RecipeChatbotState> emit,
  ) async {
    final currentState = state;
    if (currentState is! RecipeChatbotSuccess) return;

    final existingRecipes = currentState.recipes;
    emit(RecipeChatbotLoading(
      existingRecipes: existingRecipes,
      isLoadingMore: true,
    ));

    try {
      // Build follow-up prompt with conversation history
      final followUpPrompt = _buildFollowUpPrompt(existingRecipes.length);
      
      final response = await _geminiService.sendMessage(
        message: followUpPrompt,
        history: _conversationHistory,
      );

      // Update conversation history
      _conversationHistory.add({'role': 'user', 'content': followUpPrompt});
      _conversationHistory.add({'role': 'assistant', 'content': response});

      final newRecipes = _parseRecipes(response);
      
      // Generate IDs for new recipes
      final allRecipes = [...existingRecipes, ...newRecipes.map((r) => {
        ...r,
        'id': _uuid.v4(),
      })];

      emit(currentState.copyWith(recipes: allRecipes));
    } catch (e, stackTrace) {
      log.severe('Error fetching more recipes', e, stackTrace);
      // Keep existing recipes on error
      emit(currentState);
    }
  }

  String _buildFollowUpPrompt(int existingCount) {
    return """
Generate 3 more different recipes following the same requirements as before. 
Make sure these new recipes are completely different from the previous $existingCount recipes.

IMPORTANT: Return ONLY a valid JSON object, no text before or after. Use this exact format:

{
  "recipes": [
    {
      "name": "Recipe Name",
      "description": "Brief description",
      "prep_time": 10,
      "cook_time": 15,
      "calories": 350,
      "protein": 30,
      "carbs": 20,
      "fat": 15,
      "ingredients": [
        {"name": "Ingredient 1", "quantity": 100, "unit": "g"}
      ],
      "instructions": ["Step 1", "Step 2"],
      "serving_suggestion": "Serve with..."
    }
  ]
}
""";
  }

  Future<void> _onToggleSaveRecipe(
    ToggleSaveRecipe event,
    Emitter<RecipeChatbotState> emit,
  ) async {
    final currentState = state;
    if (currentState is! RecipeChatbotSuccess) return;

    final recipe = event.recipe;
    final recipeId = recipe['id'] ?? recipe['name'];
    final isCurrentlySaved = currentState.savedRecipeIds.contains(recipeId);

    try {
      if (isCurrentlySaved) {
        await _savedRecipeDataSource.deleteSavedRecipe(recipeId);
      } else {
        final savedRecipe = SavedRecipeDBO(
          id: recipeId,
          title: recipe['name'] ?? '',
          description: recipe['description'] ?? '',
          prepTime: recipe['prep_time'] ?? 0,
          cookTime: recipe['cook_time'] ?? 0,
          calories: recipe['calories'] ?? 0,
          protein: recipe['protein'] ?? 0,
          carbs: recipe['carbs'] ?? 0,
          fat: recipe['fat'] ?? 0,
          ingredients: List<Map<String, dynamic>>.from(recipe['ingredients'] ?? []),
          instructions: List<String>.from(recipe['instructions'] ?? []),
          servingSuggestion: recipe['serving_suggestion'] ?? '',
          savedAt: DateTime.now(),
        );
        await _savedRecipeDataSource.saveRecipe(savedRecipe);
      }

      // Update saved IDs in state
      final updatedSavedIds = Set<String>.from(currentState.savedRecipeIds);
      if (isCurrentlySaved) {
        updatedSavedIds.remove(recipeId);
      } else {
        updatedSavedIds.add(recipeId);
      }

      emit(currentState.copyWith(savedRecipeIds: updatedSavedIds));
    } catch (e) {
      log.severe('Error toggling save recipe', e);
    }
  }

  Future<void> _onLoadSavedRecipes(
    LoadSavedRecipes event,
    Emitter<RecipeChatbotState> emit,
  ) async {
    try {
      final savedRecipes = await _savedRecipeDataSource.getAllSavedRecipes();
      final savedIds = savedRecipes.map((r) => r.id).toSet();
      
      final currentState = state;
      if (currentState is RecipeChatbotSuccess) {
        emit(currentState.copyWith(savedRecipeIds: savedIds));
      }
    } catch (e) {
      log.severe('Error loading saved recipes', e);
    }
  }

  void _onClearConversation(
    ClearConversation event,
    Emitter<RecipeChatbotState> emit,
  ) {
    _conversationHistory.clear();
    emit(RecipeChatbotInitial());
  }
}
