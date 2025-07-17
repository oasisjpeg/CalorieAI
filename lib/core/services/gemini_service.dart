import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:logging/logging.dart';
import 'package:calorieai/core/utils/env.dart';

class GeminiService {
  final log = Logger('GeminiService');
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: Env.geminiApiKey,
    );
  }

  /// Generates content based on the provided prompt
  Future<String> generate(String prompt) async {
    try {
      log.fine('Generating content with Gemini...');

      final content = [
        Content.text(prompt),
      ];

      final response = await _model.generateContent(content);
      final responseText = response.text;

      if (responseText == null || responseText.isEmpty) {
        log.warning('Empty response from Gemini');
        throw Exception('No response from Gemini');
      }

      // Clean up the response by removing markdown formatting
      final cleanedResponse =
          responseText.replaceAll('```json', '').replaceAll('```', '');

      // Try to parse the JSON
      try {
        final decoded = json.decode(cleanedResponse);
        if (decoded is Map && decoded.containsKey('recipes')) {
          log.fine('Successfully generated recipes');
          return cleanedResponse;
        }
        throw FormatException('Invalid JSON format: Missing recipes array');
      } catch (e) {
        log.warning('Could not parse JSON response: $e');
        return cleanedResponse;
      }
    } catch (e) {
      log.severe('Error generating content: $e');
      rethrow;
    }
  }

  /// Analyzes a food image and returns a description of the food with nutritional information in JSON format
  Future<String> analyzeFoodImage({
    required Uint8List imageBytes,
    required BuildContext context,
    String? prompt,
  }) async {
    try {
      log.fine('Analyzing food image with Gemini...');

      final locale = Localizations.localeOf(context);
      final languageText = locale.languageCode == 'de' ? "german" : "english";

      final geminiPrompt = '''
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
  6. give me a score for the whole meal (0-10) based on the nutritional values (10 for a balanced healthy meal, 5 for a meal but has too much sugar or salt or too much fat etc, 0 for a unhealthy meal)
  7. give me a score_text for the whole meal (0-10) based on the nutritional values (10 for a balanced healthy meal, 5 for a meal but has too much sugar or salt or too much fat etc, 0 for a unhealthy meal). the text should be maximum 1-2 sentences long
IMPORTANT: Respond ONLY with valid JSON. DO NOT use markdown code blocks, backticks, or any formatting. Output raw JSON only by using this structure:
{
  "valid_food_image": boolean,
  "is_liquid": boolean,
  "title": "Specific meal name",
  "score": X.X,
  "score_text": "Explanation for the score",
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
      "fiber_g": X.X,
      "salt_g": X.X,
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
    "fiber_g": X.X,
    "salt_g": X.X,
  }
}
Provide exact food names (brand names if recognizable). Use standard nutritional databases. Maintain decimal precision.
Give me the response of texts (except the tags) in $languageText
      ''';

      final content = [
        Content.multi([
          TextPart(geminiPrompt),
          TextPart(prompt ?? ''),
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
        log.fine('Successfully analyzed food image');
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

  Future<String> analyzeFoodDescription({
    required BuildContext context,
    String? prompt,
  }) async {
    try {
      log.fine('Analyzing food description with Gemini...');

      final locale = Localizations.localeOf(context);
      final languageText = locale.languageCode == 'de' ? "german" : "english";

      final geminiPrompt = '''
You are a culinary expert specializing in food analysis based on descriptions. For any provided food description:

Verify if the description contains edible food items or drinks (coca-cola or red-bulls or similar)
If non-food or non-drinks detected, respond with: {"error": "No food detected"}
For valid food descriptions:
Identify each component with maximum specificity (e.g., "whole wheat spaghetti" not "pasta")
Use the provided portion sizes in grams from the description. If not explicitly stated, assume a standard serving size (e.g., 100g) for that item and note this assumption.
Calculate nutritional values per 100g and scale to the provided or assumed portion
Sum totals for the entire dish
Return the total grams in the totals section
For valid drink descriptions:
Identify the drink with maximum specificity (e.g., "coca-cola" not "soft drink")
Use the provided portion sizes in grams from the description (convert ml to g if ml is provided). If not explicitly stated, assume a standard serving size (e.g., 250ml or 250g) for that item and note this assumption.
Calculate nutritional values per 100g and scale to the provided or assumed portion
Sum totals for the entire drink
Return the total grams in the totals section
is_liquid is only true if you only describe liquids (only can of red-bull and nothing else), not if meals contain liquids (e.g. pasta with red-bull)
give me a score for the whole meal (0-10) based on the nutritional values (10 for a balanced healthy meal, 5 for a meal but has too much sugar or salt or too much fat etc, 0 for a unhealthy meal)
give me a score_text for the whole meal (0-10) based on the nutritional values (10 for a balanced healthy meal, 5 for a meal but has too much sugar or salt or too much fat etc, 0 for a unhealthy meal). the text should be maximum 1-2 sentences long
IMPORTANT: Respond ONLY with valid JSON. DO NOT use markdown code blocks, backticks, or any formatting. Output raw JSON only by using this structure:
{
"valid_food_image": boolean,
"is_liquid": boolean,
"title": "Specific meal name",
"score": X.X,
"score_text": "Explanation for the score",
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
"fiber_g": X.X,
"salt_g": X.X
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
"fiber_g": X.X,
"salt_g": X.X
}
}
Provide exact food names (brand names if recognizable). Use standard nutritional databases. Maintain decimal precision.
Give me the response of texts (except the tags) in $languageText
      ''';

      final content = [
        Content.multi([
          TextPart(geminiPrompt),
          TextPart(prompt ?? ''),
        ])
      ];

      final response = await _model.generateContent(content);
      final responseText = response.text;

      if (responseText == null || responseText.isEmpty) {
        log.warning('Empty response from Gemini');
        return 'Could not identify the food in the image.';
      }

      try {
        log.fine('Successfully analyzed food image');
        return responseText;
      } catch (formatError) {
        log.warning('Error formatting JSON response: $formatError');
        return responseText;
      }
    } catch (e, stackTrace) {
      log.severe('Error analyzing food image: $e', e, stackTrace);
      return 'Error analyzing image: $e';
    }
  }

  /// Sends a message to the Gemini model and returns the response
  Future<String> sendMessage({
    required String message,
    List<Content>? history,
  }) async {
    try {
      log.fine('Sending message to Gemini...');
      final chat = _model.startChat(history: history);

      final response = await chat.sendMessage(Content.multi([
        TextPart(message),
      ]));

      final responseText = response.text;

      if (responseText == null || responseText.isEmpty) {
        log.warning('Empty response from Gemini');
        return 'Could not process the message.';
      }

      // For display purposes, we'll format the response as a readable description
      try {
        log.fine('Successfully processed message');
        return responseText;
      } catch (formatError) {
        log.warning('Error formatting response: $formatError');
        return responseText; // Return the raw response if formatting fails
      }
    } catch (e, stackTrace) {
      log.severe('Error sending message: $e', e, stackTrace);
      return 'Error processing message: $e';
    }
  }
}
