import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logging/logging.dart';
import 'package:calorieai/core/domain/entity/intake_entity.dart';
import 'package:calorieai/core/domain/usecase/get_intake_usecase.dart';
import 'package:calorieai/core/presentation/widgets/food_analysis_loading_dialog.dart';
import 'package:calorieai/core/services/gemini_service.dart';
import 'package:calorieai/core/utils/extensions.dart';
import 'package:calorieai/core/utils/locator.dart';
import 'package:calorieai/features/add_meal/domain/entity/meal_entity.dart';
import 'package:calorieai/features/add_meal/presentation/bloc/products_bloc.dart';
import 'package:calorieai/features/add_meal/presentation/bloc/recent_meal_bloc.dart';
import 'package:calorieai/features/iap/presentation/bloc/iap_bloc.dart';
import 'package:calorieai/features/iap/presentation/bloc/iap_event.dart';
import 'package:calorieai/features/recipes/domain/entity/meal_recipe_entity.dart';
import 'package:calorieai/features/recipes/domain/usecase/get_meal_recipes_usecase.dart';
import 'package:calorieai/l10n/app_localizations.dart';

typedef S = AppLocalizations;

/// Modal picker to add components to a recipe.
/// Pops with a `List<Map<String, dynamic>>` of components.
class RecipeComponentPickerSheet extends StatefulWidget {
  final DateTime day;
  final String? excludeRecipeId;
  final ScrollController? scrollController;

  const RecipeComponentPickerSheet(
      {super.key,
      required this.day,
      this.excludeRecipeId,
      this.scrollController});

  static Future<List<Map<String, dynamic>>?> show(
      BuildContext context, DateTime day,
      {String? excludeRecipeId}) {
    return showModalBottomSheet<List<Map<String, dynamic>>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) => RecipeComponentPickerSheet(
            day: day,
            excludeRecipeId: excludeRecipeId,
            scrollController: controller),
      ),
    );
  }

  @override
  State<RecipeComponentPickerSheet> createState() =>
      _RecipeComponentPickerSheetState();
}

class _RecipeComponentPickerSheetState
    extends State<RecipeComponentPickerSheet> {
  final log = Logger('RecipeComponentPickerSheet');

  late final ProductsBloc _productsBloc;
  late final RecentMealBloc _recentMealBloc;
  final _searchController = TextEditingController();
  final _aiPromptController = TextEditingController();
  final _customNameController = TextEditingController();
  final _customGramsController = TextEditingController();
  final _customKcalController = TextEditingController();
  final _customProteinController = TextEditingController();
  final _customCarbsController = TextEditingController();
  final _customFatController = TextEditingController();

  int _sourceIndex = 0;
  bool _aiLoading = false;

  @override
  void initState() {
    _productsBloc = locator<ProductsBloc>();
    _recentMealBloc = locator<RecentMealBloc>()
      ..add(const LoadRecentMealEvent(searchString: ""));
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _aiPromptController.dispose();
    _customNameController.dispose();
    _customGramsController.dispose();
    _customKcalController.dispose();
    _customProteinController.dispose();
    _customCarbsController.dispose();
    _customFatController.dispose();
    super.dispose();
  }

  double _defaultGramsFor(MealEntity meal) {
    if (meal.servingQuantity != null && meal.servingQuantity! > 0) {
      return meal.servingQuantity!;
    }
    return double.tryParse(meal.mealQuantity ?? '') ?? 100;
  }

  void _popWith(List<Map<String, dynamic>> components) {
    Navigator.of(context).pop(components);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(S.of(context).addComponentLabel,
                style: Theme.of(context).textTheme.titleLarge),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _sourceChip(0, S.of(context).pickerAiLabel),
                _sourceChip(1, S.of(context).searchLabel),
                _sourceChip(2, S.of(context).recentlyAddedLabel),
                _sourceChip(3, S.of(context).pickerTodayLabel),
                _sourceChip(4, S.of(context).recipesLabel),
                _sourceChip(5, S.of(context).pickerCustomLabel),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _buildActiveTab()),
        ],
      ),
    );
  }

  Widget _buildActiveTab() {
    switch (_sourceIndex) {
      case 1:
        return _buildSearchTab();
      case 2:
        return _buildRecentTab();
      case 3:
        return _buildTodayTab();
      case 4:
        return _buildRecipesTab();
      case 5:
        return _buildCustomTab();

      default:
        return _buildAiTab();
    }
  }

  Widget _sourceChip(int index, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: _sourceIndex == index,
        onSelected: (_) => setState(() => _sourceIndex = index),
      ),
    );
  }

  Widget _mealListTile(MealEntity meal) {
    return ListTile(
      leading: meal.thumbnailImageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                cacheManager: locator<CacheManager>(),
                fit: BoxFit.cover,
                width: 44,
                height: 44,
                imageUrl: meal.thumbnailImageUrl!,
              ))
          : ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 44,
                height: 44,
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: const Icon(Icons.restaurant_outlined),
              ),
            ),
      title:
          Text(meal.name ?? '?', maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
          '${(meal.nutriments.energyKcal100 ?? 0).toInt()} ${S.of(context).kcalLabel}/100${S.of(context).gramUnit}'),
      trailing: const Icon(Icons.add_outlined),
      onTap: () => _popWith(
          [MealRecipeEntity.componentFromMeal(meal, _defaultGramsFor(meal))]),
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Flexible(
                flex: 1,
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: _onSearchSubmit,
                  decoration: InputDecoration(
                    hintText: S.of(context).searchLabel,
                    prefixIcon: const Icon(Icons.search_outlined),
                    filled: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              IconButton(
                onPressed: () => _onSearchSubmit(_searchController.text),
                icon: const Icon(Icons.search_outlined),
                style: IconButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    backgroundColor: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: BlocBuilder<ProductsBloc, ProductsState>(
            bloc: _productsBloc,
            builder: (context, state) {
              if (state is ProductsLoadingState) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ProductsLoadedState) {
                if (state.products.isEmpty) {
                  return Center(child: Text(S.of(context).noResultsFound));
                }
                return ListView.builder(
                  controller: widget.scrollController,
                  itemCount: state.products.length,
                  itemBuilder: (context, index) =>
                      _mealListTile(state.products[index]),
                );
              } else if (state is ProductsFailedState) {
                return Center(
                    child: Text(S.of(context).errorFetchingProductData));
              }
              return Center(child: Text(S.of(context).searchDefaultLabel));
            },
          ),
        ),
      ],
    );
  }

  void _onSearchSubmit(String input) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (input.isNotEmpty) {
      _productsBloc.add(LoadProductsEvent(searchString: input));
    }
  }

  Widget _buildRecentTab() {
    return BlocBuilder<RecentMealBloc, RecentMealState>(
      bloc: _recentMealBloc,
      builder: (context, state) {
        if (state is RecentMealLoadingState || state is RecentMealInitial) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is RecentMealLoadedState) {
          if (state.recentMeals.isEmpty) {
            return Center(child: Text(S.of(context).noMealsRecentlyAddedLabel));
          }
          return ListView.builder(
            controller: widget.scrollController,
            itemCount: state.recentMeals.length,
            itemBuilder: (context, index) =>
                _mealListTile(state.recentMeals[index]),
          );
        }
        return Center(child: Text(S.of(context).noResultsFound));
      },
    );
  }

  Widget _buildTodayTab() {
    return FutureBuilder<List<IntakeEntity>>(
      future: _getTodayIntakes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final intakes = snapshot.data ?? [];
        if (intakes.isEmpty) {
          return Center(child: Text(S.of(context).noResultsFound));
        }
        return ListView.builder(
          controller: widget.scrollController,
          itemCount: intakes.length,
          itemBuilder: (context, index) {
            final intake = intakes[index];
            return ListTile(
              leading: Icon(intake.type.getIconData()),
              title: Text(intake.meal.name ?? '?',
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(
                  '${intake.amount.toStringAsFixed(0)}${intake.unit} · ${intake.totalKcal.toInt()} ${S.of(context).kcalLabel}'),
              trailing: const Icon(Icons.add_outlined),
              onTap: () =>
                  _popWith([MealRecipeEntity.componentFromIntake(intake)]),
            );
          },
        );
      },
    );
  }

  Future<List<IntakeEntity>> _getTodayIntakes() async {
    final usecase = locator<GetIntakeUsecase>();
    final results = await Future.wait([
      usecase.getBreakfastIntakeByDay(widget.day),
      usecase.getLunchIntakeByDay(widget.day),
      usecase.getDinnerIntakeByDay(widget.day),
      usecase.getSnackIntakeByDay(widget.day),
    ]);
    return results.expand((e) => e).toList();
  }

  Widget _buildRecipesTab() {
    return FutureBuilder<List<MealRecipeEntity>>(
      future: locator<GetMealRecipesUsecase>().getAllRecipes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final recipes = (snapshot.data ?? [])
            .where((r) => r.id != widget.excludeRecipeId)
            .toList();
        if (recipes.isEmpty) {
          return Center(child: Text(S.of(context).noRecipesYet));
        }
        return ListView.builder(
          controller: widget.scrollController,
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            return ListTile(
              leading: const Icon(Icons.restaurant_menu_outlined),
              title: Text(recipe.name,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(
                  '${recipe.totalKcal.toInt()} ${S.of(context).kcalLabel} · ${recipe.batchGrams.toStringAsFixed(0)}${S.of(context).gramUnit}'),
              trailing: const Icon(Icons.add_outlined),
              onTap: () => _popWith(MealRecipeEntity.componentsFromRecipe(
                  recipe, recipe.batchGrams)),
            );
          },
        );
      },
    );
  }

  Widget _buildCustomTab() {
    return ListView(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(16.0),
      children: [
        TextField(
          controller: _customNameController,
          decoration: InputDecoration(
              labelText: S.of(context).pickerCustomNameLabel,
              border: const OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _customGramsController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+([.,]\d{0,2})?$'))
          ],
          decoration: InputDecoration(
              labelText:
                  '${S.of(context).quantityLabel} (${S.of(context).gramUnit})',
              border: const OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _customNumberField(
                    _customKcalController, S.of(context).kcalLabel)),
            const SizedBox(width: 8),
            Expanded(
                child: _customNumberField(
                    _customProteinController, S.of(context).proteinLabel)),
            const SizedBox(width: 8),
            Expanded(
                child: _customNumberField(
                    _customCarbsController, S.of(context).carbsLabel)),
            const SizedBox(width: 8),
            Expanded(
                child: _customNumberField(
                    _customFatController, S.of(context).fatLabel)),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add_outlined),
            label: Text(S.of(context).addLabel),
            onPressed: _onCustomAdd,
          ),
        ),
      ],
    );
  }

  Widget _customNumberField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+([.,]\d{0,2})?$'))
      ],
      decoration:
          InputDecoration(labelText: label, border: const OutlineInputBorder()),
    );
  }

  void _onCustomAdd() {
    final name = _customNameController.text.trim();
    final grams =
        _customGramsController.text.replaceAll(',', '.').toDoubleOrNull() ?? 0;
    if (name.isEmpty || grams <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).recipeNameRequired)));
      return;
    }
    _popWith([
      MealRecipeEntity.componentFromCustom(
        name: name,
        grams: grams,
        calories:
            _customKcalController.text.replaceAll(',', '.').toDoubleOrNull() ??
                0,
        protein: _customProteinController.text
                .replaceAll(',', '.')
                .toDoubleOrNull() ??
            0,
        carbs:
            _customCarbsController.text.replaceAll(',', '.').toDoubleOrNull() ??
                0,
        fat: _customFatController.text.replaceAll(',', '.').toDoubleOrNull() ??
            0,
      )
    ]);
  }

  Widget _buildAiTab() {
    return ListView(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(16.0),
      children: [
        TextField(
          controller: _aiPromptController,
          decoration: InputDecoration(
            labelText: S.of(context).addPromptForGeminiDescription,
            hintText: S.of(context).addPromptForGeminiHintDescription,
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
          minLines: 1,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            icon: const Icon(Icons.auto_awesome),
            label: Text(S.of(context).analyzeWithGemini),
            onPressed: _aiLoading ? null : () => _analyzeDescription(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: Text(S.of(context).camera),
              onPressed:
                  _aiLoading ? null : () => _analyzePhoto(ImageSource.camera),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.photo_library),
              label: Text(S.of(context).gallery),
              onPressed:
                  _aiLoading ? null : () => _analyzePhoto(ImageSource.gallery),
            ),
          ],
        ),
      ],
    );
  }

  bool _checkAiAccess() {
    final iapBloc = context.read<IAPBloc>();
    final iapState = iapBloc.state;
    if (!iapState.hasPremiumAccess && iapState.remainingDailyAnalyses <= 0) {
      _showUpgradeDialog(context);
      return false;
    }
    return true;
  }

  void _recordAiAnalysis() {
    final iapBloc = context.read<IAPBloc>();
    if (!iapBloc.state.hasPremiumAccess) {
      iapBloc.add(const RecordAnalysisPerformed());
    }
  }

  Future<void> _analyzeDescription() async {
    final prompt = _aiPromptController.text.trim();
    if (prompt.isEmpty || !_checkAiAccess()) return;
    setState(() => _aiLoading = true);
    try {
      final future = locator<GeminiService>()
          .analyzeFoodDescription(context: context, prompt: prompt)
          .timeout(const Duration(seconds: 20),
              onTimeout: () => throw TimeoutException('Analysis timed out'));
      final result = await context.showFoodAnalysisLoading(
          analysisFuture: future, onTimeout: () {});
      await _handleAiResult(result);
    } finally {
      if (mounted) setState(() => _aiLoading = false);
    }
  }

  Future<void> _analyzePhoto(ImageSource source) async {
    if (!_checkAiAccess()) return;
    final picked = await ImagePicker().pickImage(
        source: source, maxWidth: 800, maxHeight: 800, imageQuality: 85);
    if (picked == null) return;
    setState(() => _aiLoading = true);
    try {
      final bytes = await File(picked.path).readAsBytes();
      if (!mounted) return;
      final future = locator<GeminiService>()
          .analyzeFoodImage(imageBytes: bytes, context: context)
          .timeout(const Duration(seconds: 20),
              onTimeout: () => throw TimeoutException('Analysis timed out'));
      final result = await context.showFoodAnalysisLoading(
          analysisFuture: future, onTimeout: () {});
      await _handleAiResult(result);
    } finally {
      if (mounted) setState(() => _aiLoading = false);
    }
  }

  Future<void> _handleAiResult(dynamic result) async {
    if (!mounted) return;
    if (result is TimeoutException || result is Exception || result is Error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(S.of(context).analysisFailed),
          backgroundColor: Colors.red));
      return;
    }
    try {
      String cleaned = result as String;
      if (cleaned.contains('```json')) {
        cleaned =
            cleaned.replaceAll('```json', '').replaceAll('```', '').trim();
      }
      final parsed = jsonDecode(cleaned) as Map<String, dynamic>;
      final items = parsed['items'] as List<dynamic>?;
      if (items == null || items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(S.of(context).analysisFailed),
            backgroundColor: Colors.red));
        return;
      }
      _recordAiAnalysis();
      _popWith(MealRecipeEntity.componentsFromGeminiItems(items));
    } catch (e) {
      log.warning('Error parsing AI result: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(S.of(context).analysisFailed),
          backgroundColor: Colors.red));
    }
  }

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upgrade to Premium'),
        content: const Text('Get unlimited access to all features'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, 'premium');
            },
            child: const Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }
}
