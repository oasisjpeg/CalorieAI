import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:calorieai/core/domain/entity/intake_type_entity.dart';
import 'package:calorieai/core/domain/usecase/get_config_usecase.dart';
import 'package:calorieai/core/utils/extensions.dart';
import 'package:calorieai/core/utils/id_generator.dart';
import 'package:calorieai/core/utils/locator.dart';
import 'package:calorieai/core/utils/navigation_options.dart';
import 'package:calorieai/features/add_meal/domain/entity/meal_entity.dart';
import 'package:calorieai/features/meal_detail/meal_detail_screen.dart';
import 'package:calorieai/features/recipes/domain/entity/meal_recipe_entity.dart';
import 'package:calorieai/features/recipes/presentation/bloc/recipes_bloc.dart';
import 'package:calorieai/features/recipes/presentation/widgets/recipe_component_picker_sheet.dart';
import 'package:calorieai/l10n/app_localizations.dart';

typedef S = AppLocalizations;

class RecipeBuilderScreenArguments {
  final DateTime day;
  final IntakeTypeEntity? intakeType;
  final MealRecipeEntity? existingRecipe;
  final String? initialName;
  final List<Map<String, dynamic>>? initialComponents;

  RecipeBuilderScreenArguments({
    required this.day,
    this.intakeType,
    this.existingRecipe,
    this.initialName,
    this.initialComponents,
  });
}

/// Builds a recipe from multiple components. The result can be saved to the
/// recipe library or logged directly ("quick combine" without saving).
class RecipeBuilderScreen extends StatefulWidget {
  const RecipeBuilderScreen({super.key});

  @override
  State<RecipeBuilderScreen> createState() => _RecipeBuilderScreenState();
}

class _RecipeBuilderScreenState extends State<RecipeBuilderScreen> {
  final _nameController = TextEditingController();

  final List<Map<String, dynamic>> _components = [];

  late DateTime _day;
  IntakeTypeEntity? _intakeType;
  MealRecipeEntity? _existing;
  String? _thumbnailImageUrl;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final args = ModalRoute.of(context)?.settings.arguments
        as RecipeBuilderScreenArguments?;
    _day = args?.day ?? DateTime.now();
    _intakeType = args?.intakeType;
    _existing = args?.existingRecipe;
    if (_existing != null) {
      _nameController.text = _existing!.name;
      _thumbnailImageUrl = _existing!.thumbnailImageUrl;
      _components.addAll(
          _existing!.components.map((c) => Map<String, dynamic>.from(c)));
    } else {
      if (args?.initialName != null) _nameController.text = args!.initialName!;
      if (args?.initialComponents != null) {
        _components.addAll(
            args!.initialComponents!.map((c) => Map<String, dynamic>.from(c)));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  double get _servings => _existing?.servings ?? 1;

  double get _totalGrams => _components.fold(
      0.0, (sum, c) => sum + ((c['estimated_grams'] as num? ?? 0).toDouble()));

  double get _batchGrams {
    final cooked = _existing?.cookedWeightGrams;
    return (cooked != null && cooked > 0) ? cooked : _totalGrams;
  }

  double _totalOf(String key) => _components.fold(
      0.0, (sum, c) => sum + MealRecipeEntity.scaledValue(c, key));

  double get _servingGrams =>
      _servings > 0 ? _batchGrams / _servings : _batchGrams;

  double get _servingRatio => _batchGrams > 0 ? _servingGrams / _batchGrams : 1;

  MealRecipeEntity _buildEntity() {
    final now = DateTime.now();
    return MealRecipeEntity(
      id: _existing?.id ?? IdGenerator.getUniqueID(),
      name: _nameController.text.trim(),
      servings: _servings,
      components: MealRecipeEntity.normalize(_components),
      cookedWeightGrams: _existing?.cookedWeightGrams,
      thumbnailImageUrl: _thumbnailImageUrl,
      createdAt: _existing?.createdAt ?? now,
      updatedAt: now,
    );
  }

  bool _validate() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).recipeNameRequired)));
      return false;
    }
    if (_components.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).recipeNeedsItems)));
      return false;
    }
    return true;
  }

  Future<void> _onSavePressed({bool closeAfter = true}) async {
    if (!_validate()) return;
    final entity = _buildEntity();
    locator<RecipesBloc>().add(SaveRecipeEvent(entity));
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).recipeSavedSnackbar)));
    if (closeAfter && mounted) Navigator.of(context).pop();
  }

  Future<void> _onLogPressed() async {
    if (_components.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).recipeNeedsItems)));
      return;
    }
    // Quick-combine works without a name too
    if (_nameController.text.trim().isEmpty) {
      _nameController.text = _components
          .map((c) => c['name']?.toString() ?? '')
          .where((n) => n.isNotEmpty)
          .take(2)
          .join(' + ');
    }
    final entity = _buildEntity();
    final meal = entity.toMealEntity();
    if (_intakeType != null) {
      _pushMealDetail(meal, _intakeType!);
    } else {
      _showMealTypeChooser(meal);
    }
  }

  Future<void> _pushMealDetail(MealEntity meal, IntakeTypeEntity type) async {
    final usesImperialUnits =
        (await locator<GetConfigUsecase>().getConfig()).usesImperialUnits;
    if (!mounted) return;
    Navigator.of(context).pushNamed(NavigationOptions.mealDetailRoute,
        arguments:
            MealDetailScreenArguments(meal, type, _day, usesImperialUnits));
  }

  void _showMealTypeChooser(MealEntity meal) {
    showDialog(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(S.of(context).chooseMealLabel),
        children: [
          for (final type in IntakeTypeEntity.values)
            SimpleDialogOption(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _pushMealDetail(meal, type);
              },
              child: Row(
                children: [
                  Icon(type.getIconData(), size: 20),
                  const SizedBox(width: 12),
                  Text(_intakeTypeLabel(type)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _intakeTypeLabel(IntakeTypeEntity type) {
    switch (type) {
      case IntakeTypeEntity.breakfast:
        return S.of(context).breakfastLabel;
      case IntakeTypeEntity.lunch:
        return S.of(context).lunchLabel;
      case IntakeTypeEntity.dinner:
        return S.of(context).dinnerLabel;
      case IntakeTypeEntity.snack:
        return S.of(context).snackLabel;
    }
  }

  Future<void> _onAddComponent() async {
    final result = await RecipeComponentPickerSheet.show(context, _day,
        excludeRecipeId: _existing?.id);
    if (result != null && result.isNotEmpty) {
      setState(() => _components.addAll(result));
    }
  }

  void _updateGrams(int index, String value) {
    final grams = value.replaceAll(',', '.').toDoubleOrNull();
    if (grams == null || grams <= 0) return;
    setState(() => _components[index]['estimated_grams'] = grams);
  }

  String _emojiForType(String? type) {
    switch (type) {
      case 'protein':
        return '🥩';
      case 'carb':
        return '🍚';
      case 'fat':
        return '🥑';
      case 'vegetable':
        return '🥦';
      default:
        return '🍽️';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_existing != null
            ? S.of(context).editRecipeLabel
            : S.of(context).createRecipeLabel),
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(16.0),
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                  labelText: S.of(context).recipeNameLabel,
                  border: const OutlineInputBorder()),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text(S.of(context).ingredientsLabel,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton.icon(
                  onPressed: _onAddComponent,
                  icon: const Icon(Icons.add),
                  label: Text(S.of(context).addComponentLabel),
                ),
              ],
            ),
            if (_components.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Center(
                  child: Text(S.of(context).recipeNeedsItems,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.hintColor)),
                ),
              ),
            ...List.generate(_components.length, (index) {
              final component = _components[index];
              final kcal = MealRecipeEntity.scaledValue(component, 'calories');
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(_emojiForType(component['type'] as String?),
                              style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              component['name']?.toString() ?? '',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () =>
                                setState(() => _components.removeAt(index)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          SizedBox(
                            width: 80,
                            child: TextFormField(
                              key: ObjectKey(component),
                              initialValue:
                                  (component['estimated_grams'] as num? ?? 0)
                                      .toStringAsFixed(0),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+([.,]\d{0,2})?$'))
                              ],
                              onChanged: (v) => _updateGrams(index, v),
                              decoration: const InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(S.of(context).gramUnit),
                          const Spacer(),
                          Text(
                            '${kcal.toStringAsFixed(0)} ${S.of(context).kcalLabel}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            if (_components.isNotEmpty)
              Card(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(S.of(context).recipeTotalsLabel,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                          '${_batchGrams.toStringAsFixed(0)}${S.of(context).gramUnit} · ${_totalOf('calories').toStringAsFixed(0)} ${S.of(context).kcalLabel}',
                          style: theme.textTheme.bodyMedium),
                      const Divider(height: 24),
                      Text(S.of(context).calculationsMacronutrientsDistributionLabel,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        '${_servingGrams.toStringAsFixed(0)}${S.of(context).gramUnit} · '
                        '${(_totalOf('calories') * _servingRatio).toStringAsFixed(0)} ${S.of(context).kcalLabel} · '
                        '💪 ${(_totalOf('protein_g') * _servingRatio).toStringAsFixed(1)}${S.of(context).gramUnit} · '
                        '🌾 ${(_totalOf('carbs_g') * _servingRatio).toStringAsFixed(1)}${S.of(context).gramUnit} · '
                        '🥑 ${(_totalOf('fat_g') * _servingRatio).toStringAsFixed(1)}${S.of(context).gramUnit}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _onLogPressed,
                  icon: const Icon(Icons.add_outlined),
                  label: Text(S.of(context).logOnceLabel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _onSavePressed(),
                  icon: const Icon(Icons.save_outlined),
                  label: Text(S.of(context).saveRecipeLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
