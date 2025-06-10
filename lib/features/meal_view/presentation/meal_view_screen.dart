import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:calorieai/features/home/presentation/bloc/home_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:logging/logging.dart';
import 'package:calorieai/core/domain/entity/intake_type_entity.dart';
import 'package:calorieai/core/presentation/widgets/meal_value_unit_text.dart';
import 'package:calorieai/core/presentation/widgets/image_full_screen.dart';
import 'package:calorieai/core/utils/locator.dart';
import 'package:calorieai/core/utils/navigation_options.dart';
import 'package:calorieai/core/data/repository/intake_repository.dart';
import 'package:calorieai/features/add_meal/domain/entity/meal_entity.dart';
import 'package:calorieai/features/meal_detail/presentation/bloc/meal_detail_bloc.dart';
import 'package:calorieai/features/meal_detail/presentation/widgets/meal_detail_macro_nutrients.dart';
import 'package:calorieai/features/meal_detail/presentation/widgets/meal_detail_nutriments_table.dart';
import 'package:calorieai/features/meal_detail/presentation/widgets/meal_info_button.dart';
import 'package:calorieai/features/meal_detail/presentation/widgets/meal_placeholder.dart';
import 'package:calorieai/features/meal_detail/presentation/widgets/meal_title_expanded.dart';
import 'package:calorieai/features/meal_detail/presentation/widgets/off_disclaimer.dart';
import 'package:calorieai/l10n/app_localizations.dart';
typedef S = AppLocalizations;

class MealViewScreen extends StatefulWidget {
  const MealViewScreen({super.key});

  @override
  State<MealViewScreen> createState() => _MealViewScreenState();
}

class _MealViewScreenState extends State<MealViewScreen> {
  static const _containerSize = 350.0;
  final log = Logger('MealViewScreen');
  late MealDetailBloc _mealDetailBloc;
  final _scrollController = ScrollController();

  late MealEntity meal;
  late DateTime _day;
  late IntakeTypeEntity intakeTypeEntity;
  late bool _usesImperialUnits;
  late IntakeRepository _intakeRepository;

  @override
  void initState() {
    _mealDetailBloc = locator<MealDetailBloc>();
    _intakeRepository = locator<IntakeRepository>();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final args =
        ModalRoute.of(context)?.settings.arguments as MealViewScreenArguments;
    meal = args.mealEntity;
    _day = args.day;
    intakeTypeEntity = args.intakeTypeEntity;
    _usesImperialUnits = args.usesImperialUnits;

    final initialUnit = meal.mealUnit ?? 'g';
    final initialQuantity = meal.mealQuantity ?? '100';

    _mealDetailBloc.add(UpdateKcalEvent(
      meal: meal,
      totalQuantity: initialQuantity,
      selectedUnit: initialUnit,
    ));

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MealDetailBloc, MealDetailState>(
      bloc: _mealDetailBloc,
      builder: (context, state) {
        if (state is MealDetailInitial) {
          return Scaffold(
            body: _getLoadedContent(
              context,
              state.totalQuantityConverted,
              state.totalKcal,
              state.totalCarbs,
              state.totalFat,
              state.totalProtein,
              state.selectedUnit,
            ),
          );
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }

  void _showDeleteDialog(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).deleteTimeDialogTitle),
        content: Text(S.of(context).deleteTimeDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.of(context).dialogCancelLabel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(S.of(context).dialogDeleteLabel),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        // Get all intakes for the current day and type
        final intakes = await _intakeRepository.getIntakeByDateAndType(
            intakeTypeEntity, _day);

        // Find the intake that matches our meal
        final intakeToDelete = intakes.firstWhere(
          (intake) => intake.meal.code == meal.code,
          orElse: () =>
              throw Exception('No matching intake found for this meal'),
        );

        // Use HomeBloc to delete the intake, which will update the UI
        final homeBloc = locator<HomeBloc>();
        homeBloc.deleteIntakeItem(intakeToDelete);
        homeBloc.add(const LoadItemsEvent());

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.of(context).itemDeletedSnackbar)));
        }
        Navigator.pop(context);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete meal: ${e.toString()}')),
          );
        }
      }
    }
  }

  Widget _getLoadedContent(
    BuildContext context,
    String totalQuantity,
    double totalKcal,
    double totalCarbs,
    double totalFat,
    double totalProtein,
    String selectedUnit,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 125,
          flexibleSpace: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final top = constraints.biggest.height;
              final barsHeight =
                  MediaQuery.of(context).padding.top + kToolbarHeight;
              const offset = 10;
              return FlexibleSpaceBar(
                expandedTitleScale: 1,
                background: MealTitleExpanded(
                    meal: meal, usesImperialUnits: _usesImperialUnits),
                title: AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: top > barsHeight - offset && top < barsHeight + offset
                      ? Text(
                          meal.name ?? '',
                          style: theme.textTheme.titleLarge,
                          overflow: TextOverflow.ellipsis,
                        )
                      : const SizedBox(),
                ),
              );
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteDialog(context),
            ),
          ],
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            const SizedBox(height: 16),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(80),
                child: GestureDetector(
                  child: Hero(
                    tag: ImageFullScreen.fullScreenHeroTag,
                    child: CachedNetworkImage(
                      width: 250,
                      height: 250,
                      cacheManager: locator<CacheManager>(),
                      imageUrl: meal.mainImageUrl ?? "",
                      fit: BoxFit.cover,
                      placeholder: (context, string) => const MealPlaceholder(),
                      errorWidget: (context, url, error) =>
                          const MealPlaceholder(),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      NavigationOptions.imageFullScreenRoute,
                      arguments:
                          ImageFullScreenArguments(meal.mainImageUrl ?? ""),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        '${totalKcal.toInt()} ${S.of(context).kcalLabel}',
                        style: theme.textTheme.headlineSmall,
                      ),
                      MealValueUnitText(
                        value: double.parse(totalQuantity),
                        meal: meal,
                        displayUnit:
                            selectedUnit == UnitDropdownItem.serving.toString()
                                ? meal.servingUnit
                                : selectedUnit,
                        usesImperialUnits: _usesImperialUnits,
                        textStyle: theme.textTheme.bodyMedium,
                        prefix: ' / ',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      MealDetailMacroNutrients(
                        typeString: S.of(context).carbsLabel,
                        value: totalCarbs,
                      ),
                      MealDetailMacroNutrients(
                        typeString: S.of(context).fatLabel,
                        value: totalFat,
                      ),
                      MealDetailMacroNutrients(
                        typeString: S.of(context).proteinLabel,
                        value: totalProtein,
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 16.0),
                  MealDetailNutrimentsTable(
                    product: meal,
                    usesImperialUnits: _usesImperialUnits,
                    servingQuantity: double.parse(totalQuantity),
                    servingUnit:
                        selectedUnit == UnitDropdownItem.serving.toString()
                            ? meal.servingUnit
                            : selectedUnit,
                  ),
                  const SizedBox(height: 24.0),
                  if (meal.foodItems != null && meal.foodItems!.isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ingredients',
                            style: theme.textTheme.titleMedium,
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: meal.foodItems!.length,
                            itemBuilder: (context, index) {
                              final item = meal.foodItems?[index];
                              if (item == null) return const SizedBox.shrink();

                              // Choose an emoji based on type
                              String emoji;
                              switch (item['type']) {
                                case 'protein':
                                  emoji = '🥩';
                                  break;
                                case 'carb':
                                  emoji = '🍚';
                                  break;
                                case 'fat':
                                  emoji = '🥑';
                                  break;
                                case 'vegetable':
                                  emoji = '🥦';
                                  break;
                                default:
                                  emoji = '🍽️';
                              }

                              final isDark = Theme.of(context).brightness ==
                                  Brightness.dark;

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6.0),
                                child: Card(
                                  elevation: 4,
                                  color: isDark
                                      ? Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withAlpha(30)
                                      : Theme.of(context)
                                          .colorScheme
                                          .primaryContainer
                                          ,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(emoji,
                                            style: TextStyle(fontSize: 32)),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['name'] ?? '',
                                                style: theme
                                                    .textTheme.titleMedium
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Text('⚖️',
                                                      style: TextStyle(
                                                          fontSize: 16)),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${item['estimated_grams']?.toStringAsFixed(0) ?? '-'}g',
                                                    style: theme
                                                        .textTheme.bodySmall,
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Text('🔥',
                                                      style: TextStyle(
                                                          fontSize: 16)),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${item['calories']?.toStringAsFixed(0) ?? '-'} kcal',
                                                    style: theme
                                                        .textTheme.bodySmall,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  _macroChip(
                                                    '💪',
                                                    '${item['protein_g']?.toStringAsFixed(1) ?? '0'}g',
                                                    Colors.green[100]!,
                                                    Colors.green[700]!,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  _macroChip(
                                                    '🌾',
                                                    '${item['carbs_g']?.toStringAsFixed(1) ?? '0'}g',
                                                    Colors.blue[100]!,
                                                    Colors.blue[700]!,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  _macroChip(
                                                    '🥑',
                                                    '${item['fat_g']?.toStringAsFixed(1) ?? '0'}g',
                                                    Colors.orange[100]!,
                                                    Colors.orange[700]!,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                  MealInfoButton(url: meal.url, source: meal.source),
                  meal.source == MealSourceEntity.off
                      ? const Column(
                          children: [
                            SizedBox(height: 32),
                            OffDisclaimer(),
                          ],
                        )
                      : const SizedBox(),
                  const SizedBox(height: 50.0),
                ],
              ),
            ),
          ]),
        ),
      ],
    );
  }

  Widget _macroChip(
      String emoji, String value, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 2),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class MealViewScreenArguments {
  final MealEntity mealEntity;
  final IntakeTypeEntity intakeTypeEntity;
  final DateTime day;
  final bool usesImperialUnits;

  MealViewScreenArguments(
    this.mealEntity,
    this.intakeTypeEntity,
    this.day,
    this.usesImperialUnits,
  );
}
