import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/utils/env.dart';

class GeminiService {
  final log = Logger('GeminiService');
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash-lite',
      apiKey: Env.geminiApiKey,
    );
  }

  /// Analyzes a food image and returns a description of the food with nutritional information in JSON format
  Future<String> analyzeFoodImage(Uint8List imageBytes) async {
    try {
      log.fine('Analyzing food image with Gemini...');

      final prompt = '''
      You are a culinary expert specializing in visual food analysis. For any provided image:

1. Verify if the image contains edible food items or drinks (coca-cola or red-bulls or similar)
2. If non-food or non-drinks detected, respond with: {"error": "No food detected"}
3. For valid food images:
   - Identify each component with maximum specificity (e.g., "whole wheat spaghetti" not "pasta")
   - Estimate portion sizes in grams using visual cues
   - Calculate nutritional values per 100g and scale to estimated portion
   - Sum totals for the entire dish
   - Return the total grams in the totals section
4. For valid drink images:
  - Identify the drink with maximum specificity (e.g., "coca-cola" not "soft drink")
  - Estimate portion sizes in grams using visual cues (convert ml to g)
  - Calculate nutritional values per 100g and scale to estimated portion
  - Sum totals for the entire drink
  - Return the total grams in the totals section

  5. is_liquid is only true if you only see liquids (only can of red-bull and nothing else), not if meals contain liquids (e.g. pasta with red-bull)

IMPORTANT: Respond ONLY with valid JSON. DO NOT use markdown code blocks, backticks, or any formatting. Output raw JSON only by using this structure:
{
  "valid_food_image": boolean,
  "is_liquid": boolean,
  "title": "Specific meal name",
  "items": [
    {
      "name": "specific food name",
      "type": "category (e.g., grain, protein)",
      "estimated_grams": X.X,
      "calories": X.X,
      "protein_g": X.X,
      "carbs_g": X.X,
      "fat_g": X.X,
      "sugar_g": X.X,
      "saturated_fat_g": X.X,
      "fiber_g": X.X
    }
  ],
  "totals": {
    "total_grams": X.X,
    "calories": X.X,
    "protein_g": X.X,
    "carbs_g": X.X,
    "fat_g": X.X,
    "sugar_g": X.X,
    "saturated_fat_g": X.X,
    "fiber_g": X.X
  }
}
Provide exact food names (brand names if recognizable). Use standard nutritional databases. Maintain decimal precision.
Give me the resposne of texts (except the tags) in german
      ''';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await _model.generateContent(content);
      final responseText = response.text;

      if (responseText == null || responseText.isEmpty) {
        log.warning('Empty response from Gemini');
        return 'Could not identify the food in the image.';
      }

      // For display purposes, we'll format the JSON response as a readable description
      try {
        // Keep the original JSON response for now, we'll handle parsing in the UI
        log.fine(
            'Successfully analyzed food image');
        return responseText;
      } catch (formatError) {
        log.warning('Error formatting JSON response: $formatError');
        return responseText; // Return the raw response if formatting fails
      }
    } catch (e, stackTrace) {
      log.severe('Error analyzing food image: $e', e, stackTrace);
      return 'Error analyzing image: $e';
    }
  }

  /// Extracts search terms from the food description
  Future<String> extractSearchTerms(String foodDescription) async {
    try {
      log.fine('Extracting search terms from food description...');

      final prompt = '''
Extract the most relevant search terms for a food database from this food description. 
Focus on the main food item and key ingredients.
Return only the search terms as a comma-separated list with no additional text.

Food description: $foodDescription
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final searchTerms = response.text ?? '';

      log.fine('Extracted search terms: $searchTerms');
      return searchTerms;
    } catch (e) {
      log.severe('Error extracting search terms: $e');
      return '';
    }
  }
}
