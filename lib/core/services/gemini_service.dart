import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
      final cleanedResponse = responseText
          .replaceAll('```json', '')
          .replaceAll('```', '');

      // Try to parse the JSON
      try {
        final decoded = json.decode(cleanedResponse);
        if (decoded is Map && decoded.containsKey('recipes')) {
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

  }
