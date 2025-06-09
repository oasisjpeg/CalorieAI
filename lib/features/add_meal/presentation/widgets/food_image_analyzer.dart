import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opennutritracker/core/services/imgbb_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/domain/entity/intake_type_entity.dart';
import 'package:opennutritracker/core/services/gemini_service.dart';
import 'package:opennutritracker/core/utils/id_generator.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/core/utils/navigation_options.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/features/iap/presentation/pages/iap_screen.dart';
import 'package:opennutritracker/features/meal_view/presentation/meal_view_screen.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';
import 'package:opennutritracker/features/meal_detail/meal_detail_screen.dart';
import 'package:opennutritracker/features/add_meal/presentation/widgets/food_items_adjustable_list.dart';
import 'package:opennutritracker/features/iap/presentation/bloc/iap_bloc.dart';
import 'package:opennutritracker/features/iap/presentation/bloc/iap_event.dart';
import 'package:opennutritracker/l10n/app_localizations.dart';

typedef S = AppLocalizations;

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
  final FocusNode _promptFocusNode = FocusNode();

  File? _imageFile;
  bool _isAnalyzing = false;
  bool _isAnalyzingDescription = false;
  String _analysisResult = '';
  Map<String, dynamic>? _foodData;
  late GeminiService _geminiService;
  final TextEditingController _promptController = TextEditingController();
  bool _hasPrompt = false;

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

  @override
  void dispose() {
    _promptController.dispose();
    _promptFocusNode.dispose();
    super.dispose();
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
          _hasPrompt = false;
          _promptController.clear();
        });
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

    // Check if user has premium access or remaining analyses
    final iapBloc = context.read<IAPBloc>();
    final iapState = iapBloc.state;

    if (!iapState.hasPremiumAccess && iapState.remainingDailyAnalyses <= 0) {
      // Show upgrade dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(S.of(context)!.upgradeToPremium),
            content: Text(S.of(context)!.getUnlimitedAccessToAllFeatures),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(S.of(context).dialogCancelLabel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to IAP screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const IAPScreen()),
                  );
                },
                child: Text(S.of(context)!.upgradeToPremium),
              ),
            ],
          ),
        );
      }
      setState(() => _isAnalyzing = false);
      return;
    }

    try {
      // Record the analysis usage
      if (!iapState.hasPremiumAccess) {
        iapBloc.add(const RecordAnalysisPerformed());
      }

      final imageUrl = await _uploadImageToImgbb(_imageFile!);
      if (imageUrl == null) {
        setState(() {
          _isAnalyzing = false;
          _analysisResult = 'Failed to upload image';
        });
        return;
      }

      // Include the prompt in the Gemini analysis
      final prompt = _promptController.text.trim();
      final jsonResponse = await _geminiService.analyzeFoodImage(
        imageBytes: await _imageFile!.readAsBytes(),
        context: context,
        prompt: prompt.isNotEmpty ? prompt : null,
      );

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
          _analysisResult = 'Successfully analyzed food image';
          // Show remaining uses if not premium
          if (!iapState.hasPremiumAccess) {
            final remaining = iapState.remainingDailyAnalyses - 1;
            if (remaining >= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${S.of(context).remainingAnalyses}: $remaining',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
              );
            }
          }
        });
        _isAnalyzing = false;

        // Do not navigate here! Instead, show the adjustable ingredient list and "Save Meal" button.
      } catch (jsonError) {
        log.warning('Error parsing JSON response: $jsonError');
      }
    } catch (e) {
      log.severe('Error analyzing image: $e');
      setState(() {
        _analysisResult = 'Error analyzing image: $e';
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _analyzeFoodDescription() async {
    if (!_hasPrompt) return;

    setState(() {
      _isAnalyzing = true;
      _analysisResult = '';
      _foodData = null;
    });

    // Check if user has premium access or remaining analyses
    final iapBloc = context.read<IAPBloc>();
    final iapState = iapBloc.state;

    if (!iapState.hasPremiumAccess && iapState.remainingDailyAnalyses <= 0) {
      // Show upgrade dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(S.of(context)!.upgradeToPremium),
            content: Text(S.of(context)!.getUnlimitedAccessToAllFeatures),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(S.of(context).dialogCancelLabel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to IAP screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const IAPScreen()),
                  );
                },
                child: Text(S.of(context)!.upgradeToPremium),
              ),
            ],
          ),
        );
      }
      setState(() => _isAnalyzing = false);
      return;
    }

    try {
      // Record the analysis usage
      if (!iapState.hasPremiumAccess) {
        iapBloc.add(const RecordAnalysisPerformed());
      }


      // Include the prompt in the Gemini analysis
      final prompt = _promptController.text.trim();
      final jsonResponse = await _geminiService.analyzeFoodDescription(
        context: context,
        prompt: prompt,
      );

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
          _analysisResult = 'Successfully analyzed food image';
          _isAnalyzingDescription = false;
          // Show remaining uses if not premium
          if (!iapState.hasPremiumAccess) {
            final remaining = iapState.remainingDailyAnalyses - 1;
            if (remaining >= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${S.of(context).remainingAnalyses}: $remaining',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
              );
            }
          }
        });
        _isAnalyzing = false;

        // Do not navigate here! Instead, show the adjustable ingredient list and "Save Meal" button.
      } catch (jsonError) {
        log.warning('Error parsing JSON response: $jsonError');
      }
    } catch (e) {
      log.severe('Error analyzing image: $e');
      setState(() {
        _analysisResult = 'Error analyzing image: $e';
        _isAnalyzing = false;
      });
    }
  }

  // Store the adjusted food items from the list
  List<Map<String, dynamic>>? _adjustedFoodItems;

  // Create a MealEntity from the Gemini analysis data, using adjusted items if provided
  Future<MealEntity> createMealEntityFromGeminiData(
      [List<Map<String, dynamic>>? adjustedItems]) async {
    if (_foodData == null) {
      throw Exception('No food data available');
    }

    try {
      final title = _foodData!['title'] as String;
      final totals = _foodData!['totals'] as Map<String, dynamic>;
      final isLiquid = _foodData!['is_liquid'] as bool;
      final mealUnit = isLiquid ? 'ml' : 'g';
      final servingUnit = isLiquid ? 'ml' : 'g';

      // Use adjusted items if provided, otherwise original
      final foodItems = adjustedItems ??
          (_foodData!['items'] as List<dynamic>)
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();

      // Nutrition calculation
      double totalGrams;
      double totalCalories,
          totalCarbs,
          totalFat,
          totalProtein,
          totalSugars,
          totalSaturatedFat,
          totalFiber;
      if (adjustedItems != null) {
        totalGrams = foodItems.fold<double>(
            0,
            (sum, item) =>
                sum + (item['estimated_grams'] as num? ?? 0).toDouble());
        totalCalories = foodItems.fold<double>(
            0,
            (sum, item) =>
                sum +
                ((item['calories'] as num? ?? 0) *
                    ((item['estimated_grams'] as num? ?? 0).toDouble() / 100)));
        totalCarbs = foodItems.fold<double>(
            0,
            (sum, item) =>
                sum +
                ((item['carbs_g'] as num? ?? 0) *
                    ((item['estimated_grams'] as num? ?? 0).toDouble() / 100)));
        totalFat = foodItems.fold<double>(
            0,
            (sum, item) =>
                sum +
                ((item['fat_g'] as num? ?? 0) *
                    ((item['estimated_grams'] as num? ?? 0).toDouble() / 100)));
        totalProtein = foodItems.fold<double>(
            0,
            (sum, item) =>
                sum +
                ((item['protein_g'] as num? ?? 0) *
                    ((item['estimated_grams'] as num? ?? 0).toDouble() / 100)));
        totalSugars = foodItems.fold<double>(
            0,
            (sum, item) =>
                sum +
                ((item['sugar_g'] as num? ?? 0) *
                    ((item['estimated_grams'] as num? ?? 0).toDouble() / 100)));
        totalSaturatedFat = foodItems.fold<double>(
            0,
            (sum, item) =>
                sum +
                ((item['saturated_fat_g'] as num? ?? 0) *
                    ((item['estimated_grams'] as num? ?? 0).toDouble() / 100)));
        totalFiber = foodItems.fold<double>(
            0,
            (sum, item) =>
                sum +
                ((item['fiber_g'] as num? ?? 0) *
                    ((item['estimated_grams'] as num? ?? 0).toDouble() / 100)));
      } else {
        totalGrams = totals['total_grams'] as double;
        totalCalories = totals['calories'] as double;
        totalCarbs = totals['carbs_g'] as double;
        totalFat = totals['fat_g'] as double;
        totalProtein = totals['protein_g'] as double;
        totalSugars = totals['sugar_g'] as double;
        totalSaturatedFat = totals['saturated_fat_g'] as double;
        totalFiber = totals['fiber_g'] as double;
      }

      // Calculate per 100g values
      final energyKcal100 = (totalCalories * 100 / totalGrams).roundToDouble();
      final carbs100 = (totalCarbs * 100 / totalGrams).roundToDouble();
      final fat100 = (totalFat * 100 / totalGrams).roundToDouble();
      final proteins100 = (totalProtein * 100 / totalGrams).roundToDouble();
      final sugars100 = (totalSugars * 100 / totalGrams).roundToDouble();
      final saturatedFat100 =
          (totalSaturatedFat * 100 / totalGrams).roundToDouble();
      final fiber100 = (totalFiber * 100 / totalGrams).roundToDouble();

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          _promptFocusNode.unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Show buttons if not analyzing and no image selected
              if (!_isAnalyzing && _imageFile == null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: Text(S.of(context).camera),
                      onPressed: () => _getImage(ImageSource.camera),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: Text(S.of(context).gallery),
                      onPressed: () => _getImage(ImageSource.gallery),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(_isAnalyzingDescription ? Icons.close : Icons.edit),
                    label: Text(_isAnalyzingDescription ? S.of(context).hideDescription : S.of(context).addDescription),
                    onPressed: () {
                      setState(() {
                        _isAnalyzingDescription = !_isAnalyzingDescription;
                        if (!_isAnalyzingDescription) {
                          _promptController.clear();
                          _hasPrompt = false;
                          _promptFocusNode.unfocus();
                        }
                      });
                    },
                  ),
                ],
              ),
              if (_isAnalyzingDescription)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _promptController,
                        focusNode: _promptFocusNode,
                        decoration: InputDecoration(
                          labelText: S.of(context).addPromptForGeminiDescription,
                          hintText:
                              S.of(context).addPromptForGeminiHintDescription,
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        minLines: 1,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (String value) {
                          setState(() {
                            _hasPrompt = value.trim().isNotEmpty;
                            _isAnalyzing = true;
                          });
                          _analyzeImage();
                          _promptFocusNode.unfocus();
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                        ),
                        onPressed: () {
                          setState(() {
                            _hasPrompt =
                                _promptController.text.trim().isNotEmpty;
                            _isAnalyzing = true;
                          });
                          _analyzeFoodDescription();
                        },
                        child: Text(S.of(context).analyzeWithGemini),
                      ),
                    ],
                  ),
                ),
              
              // Show loading indicator while analyzing
              if (_isAnalyzing)
                const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(child: CircularProgressIndicator()),
                ),

              // Show image and prompt if image is selected, not analyzing, and no food data yet
              if (!_isAnalyzing && _imageFile != null && _foodData == null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _imageFile!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                if (!_hasPrompt)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _promptController,
                          focusNode: _promptFocusNode,
                          decoration: InputDecoration(
                            labelText: S.of(context)!.addPromptForGemini,
                            hintText:
                                S.of(context)!.addPromptForGeminiHint,
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                          minLines: 1,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (String value) {
                            setState(() {
                              _hasPrompt = value.trim().isNotEmpty;
                              _isAnalyzing = true;
                            });
                            _analyzeImage();
                            _promptFocusNode.unfocus();
                          },
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                          ),
                          onPressed: () {
                            setState(() {
                              _hasPrompt =
                                  _promptController.text.trim().isNotEmpty;
                              _isAnalyzing = true;
                            });
                            _analyzeImage();
                          },
                          child: Text(S.of(context)!.analyzeWithGemini),
                        ),
                      ],
                    ),
                  ),
              ],

              const SizedBox(height: 8),

              // Show title of the analyzed food if we have data
              if (_foodData != null && _foodData!['title'] != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        _foodData!['title'],
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        S.of(context).adjustQuantitiesAsNeeded,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).hintColor,
                            ),
                      ),
                    ],
                  ),
                ),

              // Show analysis result (if any)
              if (_analysisResult.isNotEmpty)
                if (_analysisResult.startsWith('Error analyzing image'))
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Card(
                      elevation: 4,
                      color: Theme.of(context).colorScheme.errorContainer,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: Icon(Icons.error_outline,
                            color: Theme.of(context).colorScheme.error,
                            size: 36),
                        title: Text(
                          S.of(context).analysisFailed,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        subtitle: Text(
                          S.of(context).analysisFailed,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Retry',
                          onPressed: () {
                            if (_imageFile != null) _analyzeImage();
                          },
                        ),
                      ),
                    ),
                  )
                else
                  _foodData != null && _foodData!['items'] != null
                      ? Column(
                          children: [
                            const SizedBox(height: 8),
                            FoodItemsAdjustableList(
                              foodItems: _foodData!['items'],
                              totals: _foodData!['totals'],
                              key: const ValueKey('adjustable-list'),
                              onChanged: (adjustedItems) {
                                setState(() {
                                  _adjustedFoodItems = adjustedItems;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.check),
                              label: const Text('Save Meal'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                foregroundColor:
                                    Theme.of(context).colorScheme.onPrimary,
                              ),
                              onPressed: () async {
                                final mealEntity =
                                    await createMealEntityFromGeminiData(
                                        _adjustedFoodItems);
                                if (!mounted) return;
                                Navigator.of(context).pushReplacementNamed(
                                  NavigationOptions.mealDetailRoute,
                                  arguments: MealDetailScreenArguments(
                                    mealEntity,
                                    widget.intakeType,
                                    widget.day,
                                    false, // usesImperialUnits
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        )
                      : Container(
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
                          child: Text(_analysisResult,
                              style:
                                  const TextStyle(fontSize: 14, height: 1.4)),
                        ),
            ],
          ),
        ));
  }
}
