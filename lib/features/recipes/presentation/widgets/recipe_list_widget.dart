import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:calorieai/core/domain/entity/intake_type_entity.dart';
import 'package:calorieai/core/presentation/widgets/delete_dialog.dart';
import 'package:calorieai/core/utils/locator.dart';
import 'package:calorieai/core/utils/navigation_options.dart';
import 'package:calorieai/features/meal_detail/meal_detail_screen.dart';
import 'package:calorieai/features/recipes/domain/entity/meal_recipe_entity.dart';
import 'package:calorieai/features/recipes/presentation/bloc/recipes_bloc.dart';
import 'package:calorieai/features/recipes/presentation/recipe_builder_screen.dart';
import 'package:calorieai/l10n/app_localizations.dart';

typedef S = AppLocalizations;

/// Shared list of the user's recipes.
/// [selectionMode] = inside AddMealScreen: tap logs the recipe via
/// MealDetailScreen. Otherwise (Recipes tab) tap opens the builder to edit.
class RecipeListWidget extends StatefulWidget {
  final DateTime day;
  final IntakeTypeEntity? intakeType;
  final bool selectionMode;
  final ValueListenable<String>? filterListenable;

  const RecipeListWidget({
    super.key,
    required this.day,
    this.intakeType,
    this.selectionMode = false,
    this.filterListenable,
  });

  @override
  State<RecipeListWidget> createState() => _RecipeListWidgetState();
}

class _RecipeListWidgetState extends State<RecipeListWidget> {
  late final RecipesBloc _recipesBloc;

  @override
  void initState() {
    _recipesBloc = locator<RecipesBloc>()..add(const LoadRecipesEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecipesBloc, RecipesState>(
      bloc: _recipesBloc,
      builder: (context, state) {
        if (state is RecipesInitial || state is RecipesLoadingState) {
          return const Padding(
            padding: EdgeInsets.only(top: 32),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (state is RecipesLoadedState) {
          return ValueListenableBuilder<String>(
            valueListenable:
                widget.filterListenable ?? ValueNotifier(''),
            builder: (context, filter, _) {
              final recipes = filter.trim().isEmpty
                  ? state.recipes
                  : state.recipes
                      .where((r) =>
                          r.name.toLowerCase().contains(filter.toLowerCase()))
                      .toList();
              return _buildList(context, recipes, state.usesImperialUnits);
            },
          );
        } else if (state is RecipesFailedState) {
          return Center(child: Text(S.of(context).recipeErrorTitle));
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildList(BuildContext context, List<MealRecipeEntity> recipes,
      bool usesImperialUnits) {
    if (recipes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(Icons.restaurant_menu_outlined,
                size: 64, color: Theme.of(context).hintColor),
            const SizedBox(height: 16),
            Text(S.of(context).noRecipesYet,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(S.of(context).noRecipesYetHint,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).hintColor),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _openBuilder(context),
              icon: const Icon(Icons.add),
              label: Text(S.of(context).createRecipeLabel),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _openBuilder(context),
                icon: const Icon(Icons.add),
                label: Text(S.of(context).createRecipeLabel),
              ),
            ),
          ),
        Expanded(
          child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
            itemCount: recipes.length,
            itemBuilder: (context, index) =>
                _buildRecipeCard(context, recipes[index], usesImperialUnits),
          ),
        ),
      ],
    );
  }

  Widget _buildRecipeCard(BuildContext context, MealRecipeEntity recipe,
      bool usesImperialUnits) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).colorScheme.outline),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => widget.selectionMode
            ? _logRecipe(context, recipe, usesImperialUnits)
            : _openBuilder(context, existing: recipe),
        child: SizedBox(
          height: 100,
          child: Center(
            child: ListTile(
              leading: recipe.thumbnailImageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedNetworkImage(
                        cacheManager: locator<CacheManager>(),
                        fit: BoxFit.cover,
                        width: 60,
                        height: 60,
                        imageUrl: recipe.thumbnailImageUrl!,
                      ))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 60,
                        height: 60,
                        color:
                            Theme.of(context).colorScheme.secondaryContainer,
                        child: const Icon(Icons.restaurant_menu_outlined),
                      ),
                    ),
              title: AutoSizeText(
                recipe.name,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                S.of(context).recipeListSubtitle(
                    recipe.components.length,
                    recipe.kcalPerServing.toInt(),
                    recipe.servings.toInt()),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7)),
                overflow: TextOverflow.ellipsis,
              ),
              trailing: widget.selectionMode
                  ? IconButton(
                      style: IconButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onSurface,
                      ),
                      icon: const Icon(Icons.add_outlined),
                      onPressed: () =>
                          _logRecipe(context, recipe, usesImperialUnits),
                    )
                  : IconButton(
                      style: IconButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onSurface,
                      ),
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _confirmDelete(context, recipe),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  void _openBuilder(BuildContext context, {MealRecipeEntity? existing}) {
    Navigator.of(context).pushNamed(NavigationOptions.recipeBuilderRoute,
        arguments: RecipeBuilderScreenArguments(
          day: widget.day,
          intakeType: widget.intakeType,
          existingRecipe: existing,
        ));
  }

  Future<void> _confirmDelete(
      BuildContext context, MealRecipeEntity recipe) async {
    final delete = await showDialog<bool>(
        context: context, builder: (context) => const DeleteDialog());
    if (delete == true) {
      _recipesBloc.add(DeleteRecipeEvent(recipe.id));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).itemDeletedSnackbar)));
      }
    }
  }

  void _logRecipe(BuildContext context, MealRecipeEntity recipe,
      bool usesImperialUnits) {
    if (widget.intakeType != null) {
      _pushMealDetail(
          context, recipe, widget.intakeType!, usesImperialUnits);
    } else {
      _showMealTypeChooser(context, recipe, usesImperialUnits);
    }
  }

  void _pushMealDetail(BuildContext context, MealRecipeEntity recipe,
      IntakeTypeEntity intakeType, bool usesImperialUnits) {
    Navigator.of(context).pushNamed(NavigationOptions.mealDetailRoute,
        arguments: MealDetailScreenArguments(recipe.toMealEntity(),
            intakeType, widget.day, usesImperialUnits));
  }

  void _showMealTypeChooser(BuildContext context, MealRecipeEntity recipe,
      bool usesImperialUnits) {
    showDialog(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(S.of(context).chooseMealLabel),
        children: [
          for (final type in IntakeTypeEntity.values)
            SimpleDialogOption(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _pushMealDetail(
                    context, recipe, type, usesImperialUnits);
              },
              child: Row(
                children: [
                  Icon(type.getIconData(), size: 20),
                  const SizedBox(width: 12),
                  Text(_intakeTypeLabel(context, type)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _intakeTypeLabel(BuildContext context, IntakeTypeEntity type) {
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
}
