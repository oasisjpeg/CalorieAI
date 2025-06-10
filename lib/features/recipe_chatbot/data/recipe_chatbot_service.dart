import 'dart:convert';

import 'package:calorieai/core/services/gemini_service.dart';
import 'package:calorieai/features/recipe_chatbot/domain/recipe_entity.dart';

class RecipeChatbotService {
  final GeminiService geminiService;

  RecipeChatbotService(this.geminiService);

  // Moved the template outside the method to be a class member
  static const String _recipePromptTemplate = """I need [NUMBER] recipes in JSON format, designed to fit specific macronutrient goals. Please consider the following user preferences:

*   Language: [LANGUAGE] (Choose ONE: English, Spanish, French, German, etc. - The recipe should be written in this language.)
*   Recipe Type: [RECIPE_TYPE] (Choose ONE: main course, side dish, snack, dessert, breakfast)
*   Cooking Method: [COOKING_METHOD] (Prioritize air fryer. Can include other cooking methods only if necessary as a minor step. Options: air fryer, baked, grilled, stovetop)
*   Maximum Cooking Time: [MAX_COOKING_TIME] minutes (Target is total cooking time. Be realistic.)
*   Pricing: [PRICING] (Choose ONE: budget-friendly, normal, pricier. This reflects the cost of the ingredients per serving.)
*   Preferred Meats: [PREFERRED_MEATS] (List preferred meats, separated by commas. Use 'any' if there are no meat preferences.)
*   Preferred Vegetables: [PREFERRED_VEGETABLES] (List preferred vegetables, separated by commas. Use 'any' if there are no vegetable preferences.)
*   Dietary Restrictions: [DIETARY_RESTRICTIONS] (List any restrictions. Use 'none' if there are no restrictions. Examples: gluten-free, dairy-free, vegetarian, vegan, low-carb, keto)
*   Disliked Ingredients: [DISLIKED_INGREDIENTS] (List any ingredients to avoid, separated by commas. Use 'none' if there are no disliked ingredients. Examples: onions, mushrooms, cilantro)
*   Preferred Flavors/Cuisines: [PREFERRED_FLAVORS] (Describe desired flavors or cuisines. Examples: spicy, Italian, Asian, Mexican, Mediterranean, BBQ. Use 'any' if there are no specific flavor preferences.)

*   Macronutrient Targets (Per Serving):
    *   Calories: Approximately [TARGET_CALORIES] (Prioritize staying close to this value. A tolerance of +/- 50 calories is acceptable, but aim to be as close as possible.)
    *   Protein: At least [MINIMUM_PROTEIN] grams (Protein target is important for satiety. Prioritize meeting or exceeding this target.)
    *   Carbs: Up to [MAXIMUM_CARBS] grams (Keep carbs below this maximum.)
    *   Fat: Up to [MAXIMUM_FAT] grams (Keep fat below this maximum.)

Instructions for Recipe Generation:

1.  Prioritize recipes that can be realistically cooked primarily in an air fryer within the specified time limit. Only include other cooking methods as very minor steps if absolutely necessary.
2.  Generate the recipe in the specified language. The instructions and ingredient names should be in the selected language.
3.  Create a recipe that aligns with the chosen pricing category (budget-friendly, normal, pricier). Budget-friendly recipes should use inexpensive ingredients.
4.  Use the preferred meats and vegetables as much as possible.
5.  Strictly adhere to any dietary restrictions.
6.  Ensure the disliked ingredients are completely absent from the recipes.
7.  Aim for flavor profiles that match the preferred flavors/cuisines.
8.  Crucially, focus on hitting the protein target first, then calories, then staying under the maximum carb and fat targets.
9.  All quantities in the ingredient list MUST be in metric units (grams, milliliters, etc.).
10. Nutritional values (calories, protein, carbs, fat) are ESTIMATES. They should be clearly stated for each recipe. If precise nutritional data is unavailable, provide a reasonable estimate.
11. For ingredients, provide a list of strings. For nutriments, provide a nested object.
12. Provide clear and easy-to-follow cooking instructions.

Please provide the response strictly in the following JSON format. Do not include any other text before or after the JSON array. The response should be a valid JSON array of recipe objects:
```json
[
  {
    "title": "recipe title (in [LANGUAGE])",
    "description": "recipe description (in [LANGUAGE])",
    "prep_time": "X minutes",
    "cook_time": "Y minutes",
    "ingredients": ["ingredient1 (in [LANGUAGE])", "ingredient2 (in [LANGUAGE]) with quantity and metric unit", "ingredient3 (in [LANGUAGE]) with quantity and metric unit"],
    "instructions": ["step 1 (in [LANGUAGE])", "step 2 (in [LANGUAGE])", "step 3 (in [LANGUAGE])"],
    "nutriments": {
      "calories": 500,
      "protein": 40,
      "carbs": 50,
      "fat": 20
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
    filledPrompt = filledPrompt.replaceAll('[MAX_COOKING_TIME]', maxCookingTime.toString());
    filledPrompt = filledPrompt.replaceAll('[PRICING]', pricing);
    filledPrompt = filledPrompt.replaceAll('[PREFERRED_MEATS]', preferredMeats);
    filledPrompt = filledPrompt.replaceAll('[PREFERRED_VEGETABLES]', preferredVegetables);
    filledPrompt = filledPrompt.replaceAll('[DIETARY_RESTRICTIONS]', dietaryRestrictions);
    filledPrompt = filledPrompt.replaceAll('[DISLIKED_INGREDIENTS]', dislikedIngredients);
    filledPrompt = filledPrompt.replaceAll('[PREFERRED_FLAVORS]', preferredFlavors);
    filledPrompt = filledPrompt.replaceAll('[TARGET_CALORIES]', targetCalories.toString());
    filledPrompt = filledPrompt.replaceAll('[MINIMUM_PROTEIN]', minimumProtein.toString());
    filledPrompt = filledPrompt.replaceAll('[MAXIMUM_CARBS]', maximumCarbs.toString());
    filledPrompt = filledPrompt.replaceAll('[MAXIMUM_FAT]', maximumFat.toString());

    // The part where you were appending dynamic values like "LANGUAGE: $language"
    // is already handled by the replaceAll calls above. The template itself
    // contains these placeholders. You do not need to append them again.
    // The original code was trying to define the template and then append to it,
    // which is not the correct way to use string templates with placeholders.

    print('--- Sending Prompt to Gemini ---');
    print(filledPrompt);
    print('--- End of Prompt ---');

    final response = await geminiService.sendMessage(message: filledPrompt);

    print('--- Gemini Raw Response ---');
    print(response);
    print('--- End of Gemini Raw Response ---');

    String responseString = response ;

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