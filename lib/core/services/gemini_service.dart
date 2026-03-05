import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:calorieai/core/utils/env.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  final log = Logger('GeminiService');
  static const String _baseUrl = 'https://openrouter.ai/api/v1';
  static const String _model = 'google/gemini-2.5-flash-lite';
  late final Map<String, String> _headers;

  GeminiService() {
    _headers = {
      'Authorization': 'Bearer ${Env.openrouterApiKey}',
      'Content-Type': 'application/json',
      'HTTP-Referer': 'https://calorieai.app',
      'X-Title': 'CalorieAI',
    };
  }

  /// Generates content based on the provided prompt
  Future<String> generate(String prompt) async {
    try {
      log.fine('Generating content via OpenRouter...');

      final body = jsonEncode({
        'model': _model,
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
      });

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: _headers,
        body: body,
      );

      if (response.statusCode != 200) {
        throw Exception('OpenRouter API error: ${response.statusCode} - ${response.body}');
      }

      final data = jsonDecode(response.body);
      final responseText = data['choices']?[0]?['message']?['content'] as String?;

      if (responseText == null || responseText.isEmpty) {
        log.warning('Empty response from OpenRouter');
        throw Exception('No response from OpenRouter');
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
      log.fine('Analyzing food image via OpenRouter...');

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
  6. for the score and score_text don't be harsh and give higher ratings, but for unhealthy food stay strict, make the user feel good and use a higher scoring for healthy snacks, fruits or high protein meals. so give a score of 8 for a healthy meal and 5 for a meal but has too much sugar or salt or too much fat etc and 2 for a unhealthy meal
  7. the score_text should be maximum 1-2 sentences long that explain why the meal has the score it has
  8. the score should be a compliment to the user and encourage him if he takes healthy food and the nutritional values are good
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

      // Convert image to base64
      final base64Image = base64Encode(imageBytes);

      final messages = [
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': geminiPrompt},
            if (prompt != null && prompt.isNotEmpty)
              {'type': 'text', 'text': prompt},
            {
              'type': 'image_url',
              'image_url': {'url': 'data:image/jpeg;base64,$base64Image'}
            },
          ]
        }
      ];

      final body = jsonEncode({
        'model': _model,
        'messages': messages,
      });

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: _headers,
        body: body,
      );

      if (response.statusCode != 200) {
        throw Exception('OpenRouter API error: ${response.statusCode} - ${response.body}');
      }

      final data = jsonDecode(response.body);
      final responseText = data['choices']?[0]?['message']?['content'] as String?;

      if (responseText == null || responseText.isEmpty) {
        log.warning('Empty response from OpenRouter');
        return 'Could not identify the food in the image.';
      }

      log.fine('Successfully analyzed food image');
      return responseText;
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
      log.fine('Analyzing food description via OpenRouter...');

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
for the score and score_text don't be harsh and give higher ratings, but for unhealthy food stay strict, make the user feel good if and use a higher scoring for healthy snacks, fruits or high protein meals. so give a score of 8 for a healthy meal and 5 for a meal but has too much sugar or salt or too much fat etc and 2 for a unhealthy meal
the score should be a compliment to the user and encourage him if he takes healthy food and the nutritional values are good
the score_text should be maximum 1-2 sentences long that explain why the meal has the score it has
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

      final body = jsonEncode({
        'model': _model,
        'messages': [
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': geminiPrompt},
              if (prompt != null && prompt.isNotEmpty)
                {'type': 'text', 'text': prompt},
            ]
          }
        ],
      });

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: _headers,
        body: body,
      );

      if (response.statusCode != 200) {
        throw Exception('OpenRouter API error: ${response.statusCode} - ${response.body}');
      }

      final data = jsonDecode(response.body);
      final responseText = data['choices']?[0]?['message']?['content'] as String?;

      if (responseText == null || responseText.isEmpty) {
        log.warning('Empty response from OpenRouter');
        return 'Could not identify the food in the image.';
      }

      log.fine('Successfully analyzed food description');
      return responseText;
    } catch (e, stackTrace) {
      log.severe('Error analyzing food description: $e', e, stackTrace);
      return 'Error analyzing description: $e';
    }
  }

  /// Sends a message to the model and returns the response
  Future<String> sendMessage({
    required String message,
    List<Map<String, dynamic>>? history,
  }) async {
    try {
      log.fine('Sending message via OpenRouter...');

      final messages = <Map<String, dynamic>>[];

      // Add history if provided
      if (history != null) {
        for (final content in history) {
          messages.add({
            'role': content['role'] ?? 'user',
            'content': content['content'],
          });
        }
      }

      // Add current message
      messages.add({
        'role': 'user',
        'content': message,
      });

      final body = jsonEncode({
        'model': _model,
        'messages': messages,
      });

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: _headers,
        body: body,
      );

      if (response.statusCode != 200) {
        throw Exception('OpenRouter API error: ${response.statusCode} - ${response.body}');
      }

      final data = jsonDecode(response.body);
      final responseText = data['choices']?[0]?['message']?['content'] as String?;

      if (responseText == null || responseText.isEmpty) {
        log.warning('Empty response from OpenRouter');
        return 'Could not process the message.';
      }

      log.fine('Successfully processed message');
      return responseText;
    } catch (e, stackTrace) {
      log.severe('Error sending message: $e', e, stackTrace);
      return 'Error processing message: $e';
    }
  }
}
