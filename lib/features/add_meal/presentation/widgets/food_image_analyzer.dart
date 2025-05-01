import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:opennutritracker/core/services/imgbb_service.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/domain/entity/intake_type_entity.dart';
import 'package:opennutritracker/core/services/gemini_service.dart';
import 'package:opennutritracker/core/utils/id_generator.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/core/utils/navigation_options.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/features/meal_view/presentation/meal_view_screen.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';
import 'package:opennutritracker/features/meal_detail/meal_detail_screen.dart';
// import 'package:opennutritracker/generated/l10n.dart'; // Removed unused import

class FoodImageAnalyzer extends StatefulWidget {
  final Function(String) onSearchTermsExtracted;
  final DateTime day;
  final IntakeTypeEntity intakeType;

  const FoodImageAnalyzer({
    Key? key,
    required this.onSearchTermsExtracted,
    required this.day,
    required this.intakeType,
  }) : super(key: key);

  @override
  State<FoodImageAnalyzer> createState() => _FoodImageAnalyzerState();
}

class _FoodImageAnalyzerState extends State<FoodImageAnalyzer> {
  final log = Logger('FoodImageAnalyzer');
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  bool _isAnalyzing = false;
  String _analysisResult = '';
  Map<String, dynamic>? _foodData;
  late GeminiService _geminiService;

  // Flag to track if we can add this food to the meal log

  Future<String?> _convertImageToBase64Url(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64 = base64Encode(bytes);
      return 'data:image/jpeg;base64,$base64';
    } catch (e) {
      log.severe('Error converting image to base64: $e');
      return null;
    }
  }

  Future<String?> _uploadImageToImgbb(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final imgbbService = ImgBBService();
      try {
        final imageUrl = await imgbbService.uploadImage(bytes);
        return imageUrl;
      } finally {
        imgbbService.dispose();
      }
    } catch (e) {
      log.severe('Error uploading image to ImgBB: $e');
      log.severe('Error uploading image to Imgur: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _geminiService = locator<GeminiService>();
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _analysisResult = '';
          _isAnalyzing = false;
        });

        // Automatically analyze the image
        _analyzeImage();
      }
    } catch (e) {
      log.severe('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: $e')),
      );
    }
  }

  Future<void> _analyzeImage() async {
    if (_imageFile == null) return;

    setState(() {
      _isAnalyzing = true;
      _analysisResult = '';
      _foodData = null;
    });

    try {
      final imageBytes = await _imageFile!.readAsBytes();
      final jsonResponse = await _geminiService.analyzeFoodImage(imageBytes);

      try {
        // Clean up the response if it contains markdown code blocks
        String cleanedResponse = jsonResponse;
        if (jsonResponse.contains('```json')) {
          cleanedResponse = jsonResponse
              .replaceAll('```json', '')
              .replaceAll('```', '')
              .trim();
        }

        // Try to parse the JSON response
        final parsedData = jsonDecode(cleanedResponse) as Map<String, dynamic>;

        setState(() {
          _foodData = parsedData;

        });

        if (_foodData != null && _foodData!['valid_food_image'] == true) {
          // Immediately create the meal entity and navigate
          final mealEntity = await createMealEntityFromGeminiData();
          log.fine('Meal entity created: $mealEntity');
          if (!mounted) return; // Ensure widget is still in tree
          Navigator.of(context).pushReplacementNamed(
            NavigationOptions.mealDetailRoute,
            arguments: MealDetailScreenArguments(
              mealEntity,
              widget.intakeType,
              widget.day,
              false, // usesImperialUnits
            ),
          );
          return; // Do not setState or show preview
        }
      } catch (jsonError) {
        log.warning('Error parsing JSON response: $jsonError');
        setState(() {
          // Fallback to showing the raw response
          _analysisResult = jsonResponse;
          _isAnalyzing = false;
        });

        // Try to extract search terms using the original method
        final searchTerms =
            await _geminiService.extractSearchTerms(jsonResponse);
        if (searchTerms.isNotEmpty) {
          widget.onSearchTermsExtracted(searchTerms);
        }
      }
    } catch (e) {
      log.severe('Error analyzing image: $e');
      setState(() {
        _analysisResult = 'Error analyzing image: $e';
        _isAnalyzing = false;
      });
    }
  }

  // Create a MealEntity from the Gemini analysis data
  Future<MealEntity> createMealEntityFromGeminiData() async {
    if (_foodData == null) {
      throw Exception('No food data available');
    }


    try {
      final title = _foodData!['title'] as String;
      final totals = _foodData!['totals'] as Map<String, dynamic>;

      // Calculate nutritional values per total grams and total values
      final totalGrams = totals['total_grams'] as double;
      final carbsPer100g =
          ((totals['carbs_g'] as double) * 100 / totalGrams).roundToDouble();
      final fatPer100g =
          ((totals['fat_g'] as double) * 100 / totalGrams).roundToDouble();
      final proteinPer100g =
          ((totals['protein_g'] as double) * 100 / totalGrams).roundToDouble();
      final sugarPer100g =
          ((totals['sugar_g'] as double) * 100 / totalGrams).roundToDouble();
      final saturatedFatPer100g =
          ((totals['saturated_fat_g'] as double) * 100 / totalGrams)
              .roundToDouble();
      final fiberPer100g =
          ((totals['fiber_g'] as double) * 100 / totalGrams).roundToDouble();

      // Calculate nutritional values per 100g
      final energyKcal100 =
          ((totals['calories'] as double) * 100 / totalGrams).roundToDouble();
      final carbs100 = carbsPer100g;
      final fat100 = fatPer100g;
      final proteins100 = proteinPer100g;
      final sugars100 = sugarPer100g;
      final saturatedFat100 = saturatedFatPer100g;
      final fiber100 = fiberPer100g;

      // Store the nutritional values in the entity
      final nutrimentsPerTotal = MealNutrimentsEntity(
        energyKcal100: energyKcal100,
        carbohydrates100: carbs100,
        fat100: fat100,
        proteins100: proteins100,
        sugars100: sugars100,
        saturatedFat100: saturatedFat100,
        fiber100: fiber100,
      );

      final imageUrl = await _uploadImageToImgbb(_imageFile!);

      // Set appropriate units based on whether it's a liquid or solid
      final isLiquid = _foodData!['is_liquid'] as bool;
      final mealUnit = isLiquid ? 'ml' : 'g';
      final servingUnit = isLiquid ? 'ml' : 'g';

      final foodItemsRaw = _foodData!['items'] as List<dynamic>;
      final foodItems = foodItemsRaw
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
      
      return MealEntity(
        code: IdGenerator.getUniqueID(),
        name: title,
        url: null,
        mealQuantity: totalGrams.toString(),
        mealUnit: mealUnit,
        servingQuantity: totalGrams,
        servingUnit: servingUnit,
        servingSize: isLiquid
            ? '${totalGrams.toStringAsFixed(0)}ml'
            : '${totalGrams.toStringAsFixed(0)}g',
        nutriments: nutrimentsPerTotal,
        source: MealSourceEntity.custom,
        thumbnailImageUrl: imageUrl,
        mainImageUrl: imageUrl,
        foodItems: foodItems,
      );
    } catch (e) {
      log.severe('Error creating meal entity: $e');
      return MealEntity.empty();
    }
  }

  // Add the analyzed food to the meal log
  Future<void> addToMealLog(BuildContext context) async {


    try {
      // Create the meal entity and navigate to meal detail screen
      final mealEntity = await createMealEntityFromGeminiData();

      // Navigate to the meal view screen
      Navigator.of(context).pushNamed(
        NavigationOptions.mealViewRoute,
        arguments: MealViewScreenArguments(
          mealEntity,
          widget.intakeType,
          widget.day,
          false)
      );
    } catch (e) {
      log.severe('Error adding to meal log: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding to meal log: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'), // TODO: Add translation
                onPressed: () => _getImage(ImageSource.camera),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'), // TODO: Add translation
                onPressed: () => _getImage(ImageSource.gallery),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_imageFile != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                _imageFile!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            if (_isAnalyzing)
              const Center(child: CircularProgressIndicator())
            else if (_analysisResult.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.restaurant,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Food Analysis',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 250),
                      child: SingleChildScrollView(
                        child: Text(
                          _analysisResult,
                          style: const TextStyle(fontSize: 14, height: 1.4),
                        ),
                      ),
                    ),
                    
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
