import 'dart:convert';
import 'package:logging/logging.dart';

import 'package:calorieai/core/services/gemini_service.dart';
import 'package:calorieai/features/recipe_chatbot/domain/recipe_entity.dart';

class RecipeChatbotService {
    final log = Logger('RecipeChatbotService');

  final GeminiService geminiService;

  RecipeChatbotService(this.geminiService);

  // Moved the template outside the method to be a class member
  static const String _recipePromptTemplate =
      """I need [NUMBER] recipes in JSON format, designed to fit specific macronutrient goals. Please consider the following user preferences:

Language: [LANGUAGE] (Choose ONE: English, Spanish, French, German, etc. The recipe should be written in this language.)
Recipe Type: [RECIPE_TYPE] (Choose ONE: main course, side dish, snack, dessert, breakfast)
Cooking Method: [COOKING_METHOD] (Prioritize air fryer. Can include other methods only if absolutely necessary as a minor step. Options: air fryer, baked, grilled, stovetop)
Maximum Cooking Time: [MAX_COOKING_TIME] minutes (This is the total cooking time. Be realistic about what’s possible.)
Pricing: [PRICING] (Choose ONE: budget-friendly, normal, pricier. This reflects the cost of ingredients per serving.)
Preferred Meats: [PREFERRED_MEATS] (List preferred meats, separated by commas. Use 'any' if there are no preferences.)
Preferred Vegetables: [PREFERRED_VEGETABLES] (List preferred vegetables, separated by commas. Use 'any' if there are no preferences.)
Dietary Restrictions: [DIETARY_RESTRICTIONS] (List any restrictions. Use 'none' if there are none. Examples: gluten-free, dairy-free, vegetarian, vegan, low-carb, keto.)
Disliked Ingredients: [DISLIKED_INGREDIENTS] (List any ingredients to avoid, separated by commas. Use 'none' if there are none.)
Preferred Flavors/Cuisines: [PREFERRED_FLAVORS] (Describe desired flavors/cuisines. Examples: spicy, Italian, Asian, Mexican, Mediterranean, BBQ. Use 'any' if there are no preferences.)

Macronutrient & Calorie Targets (Per Serving):
If RECIPE_TYPE is "main course":
Calories: Approximately [TARGET_CALORIES] (aim for this value, ±50 kcal tolerance)
Protein: At least [MINIMUM_PROTEIN] grams
Carbs: Up to [MAXIMUM_CARBS] grams
Fat: Up to [MAXIMUM_FAT] grams

If RECIPE_TYPE is NOT "main course" (e.g., dessert, snack, side dish, breakfast):
Calories: Always generate a healthy, low-calorie recipe (ideally between 100–250 kcal per serving). Never use the full available calories for these types, regardless of remaining daily calorie budget.
Protein, carbs, fat: Make healthy, balanced choices, but do not attempt to hit main-course macronutrient targets.

Instructions for Recipe Generation:
Main Courses:
Strictly match [TARGET_CALORIES], [MINIMUM_PROTEIN], [MAXIMUM_CARBS], and [MAXIMUM_FAT]. Protein is the highest priority, followed by calories, carbs, and fat.
Non-Main Courses (desserts, snacks, side dishes, breakfast):
Never use the full daily calorie budget. Always generate a healthy, low-calorie recipe (100–250 kcal per serving, unless otherwise specified).
Do not try to meet the [TARGET_CALORIES] or other strict macronutrient targets for these recipes. Simplicity and healthiness are the top priorities.
Prioritize recipes that can be realistically cooked using the air fryer within the specified time. Other methods should be minor steps only if required.
Use the chosen language for all recipe instructions and ingredient names.
Make sure the recipe aligns with the specified pricing. Budget-friendly recipes must use inexpensive ingredients.
Use preferred meats and vegetables as much as possible.
Strictly follow any dietary restrictions.
Exclude all disliked ingredients.
Match the preferred flavors or cuisines.
All ingredient quantities must be in metric units (grams, milliliters, etc.).
Nutritional values (calories, protein, carbs, fat) should be estimated and clearly stated for every recipe. If exact numbers cannot be given, give reasonable estimates.

For each recipe, provide:
an ingredients list (as an array of strings)
a nutriments object (nested, with keys for calories, protein, carbs, fat, salt, sugar, fiber, saturated_fat)
clear, concise cooking instructions
an optional serving suggestion

Important:
For main courses: calorie and macronutrient targets are crucial—do not deviate.
For all other recipe types: focus only on keeping the recipe healthy and low in calories, without using up the full calorie target.
Never generate a non-main-course recipe that matches or exceeds the full daily or main course calorie target.
]

Response Format
Please provide the response strictly in the following JSON format. Do not include any additional text before or after the JSON array. The response must be a valid JSON array of recipe objects:

json
[
  {
    "title": "recipe title (in [LANGUAGE])",
    "description": "recipe description (in [LANGUAGE])",
    "prep_time": "X minutes",
    "cook_time": "Y minutes",
    "ingredients": [
      "ingredient1 (in [LANGUAGE]) with quantity and metric unit",
      "ingredient2 (in [LANGUAGE]) with quantity and metric unit"
    ],
    "instructions": [
      "step 1 (in [LANGUAGE])",
      "step 2 (in [LANGUAGE])"
    ],
    "nutriments": {
      "calories": 500,
      "protein": 40,
      "carbs": 50,
      "fat": 20,
      "salt": 20,
      "sugar": 20,
      "fiber": 20,
      "saturated_fat": 20
    },
    "serving_suggestion": "serving suggestion (in [LANGUAGE], optional)"
  }
]
```"""; // End of the template string

  Future<List<RecipeEntity>> getRecipes({
    required String language,
    required String recipeType,
    required String cookingMethod,
    required int maxCookingTime,
    required String pricing,
    required String preferredMeats,
    required String preferredVegetables,
    required String dietaryRestrictions,
    required String dislikedIngredients,
    required String preferredFlavors,
    required int targetCalories,
    required int minimumProtein,
    required int maximumCarbs,
    required int maximumFat,
    required int number,
  }) async {
    String filledPrompt = _recipePromptTemplate; // Start with the base template

    // Replace placeholders with actual values
    filledPrompt = filledPrompt.replaceAll('[NUMBER]', number.toString());
    filledPrompt = filledPrompt.replaceAll('[LANGUAGE]', language);
    filledPrompt = filledPrompt.replaceAll('[RECIPE_TYPE]', recipeType);
    filledPrompt = filledPrompt.replaceAll('[COOKING_METHOD]', cookingMethod);
    filledPrompt = filledPrompt.replaceAll(
        '[MAX_COOKING_TIME]', maxCookingTime.toString());
    filledPrompt = filledPrompt.replaceAll('[PRICING]', pricing);
    filledPrompt = filledPrompt.replaceAll('[PREFERRED_MEATS]', preferredMeats);
    filledPrompt =
        filledPrompt.replaceAll('[PREFERRED_VEGETABLES]', preferredVegetables);
    filledPrompt =
        filledPrompt.replaceAll('[DIETARY_RESTRICTIONS]', dietaryRestrictions);
    filledPrompt =
        filledPrompt.replaceAll('[DISLIKED_INGREDIENTS]', dislikedIngredients);
    filledPrompt =
        filledPrompt.replaceAll('[PREFERRED_FLAVORS]', preferredFlavors);
    filledPrompt =
        filledPrompt.replaceAll('[TARGET_CALORIES]', targetCalories.toString());
    filledPrompt =
        filledPrompt.replaceAll('[MINIMUM_PROTEIN]', minimumProtein.toString());
    filledPrompt =
        filledPrompt.replaceAll('[MAXIMUM_CARBS]', maximumCarbs.toString());
    filledPrompt =
        filledPrompt.replaceAll('[MAXIMUM_FAT]', maximumFat.toString());

    // The part where you were appending dynamic values like "LANGUAGE: $language"
    // is already handled by the replaceAll calls above. The template itself
    // contains these placeholders. You do not need to append them again.
    // The original code was trying to define the template and then append to it,
    // which is not the correct way to use string templates with placeholders.

    log.fine('--- Sending Prompt to Gemini ---');
    log.fine(filledPrompt);
    log.fine('--- End of Prompt ---');

    final response = await geminiService.sendMessage(message: filledPrompt);

    log.fine('--- Gemini Raw Response ---');
    log.fine(response);
    log.fine('--- End of Gemini Raw Response ---');

    String responseString = response;

    if (responseString.startsWith("```json")) {
      responseString = responseString.substring(7);
    }
    if (responseString.endsWith("```")) {
      responseString = responseString.substring(0, responseString.length - 3);
    }
    responseString = responseString.trim();

    try {
      // Ensure the response is not empty before trying to decode
      if (responseString.isEmpty) {
        print('Gemini returned an empty response string.');
        return [];
      }
      final List<dynamic> decodedJson = jsonDecode(responseString);
      final List<RecipeEntity> recipes = decodedJson
          .map((json) => RecipeEntity.fromJson(json as Map<String, dynamic>))
          .toList();
      return recipes;
    } catch (e) {
      print('Error decoding JSON from Gemini: $e');
      print('Problematic JSON string: $responseString');
      return [];
    }
  }
}
