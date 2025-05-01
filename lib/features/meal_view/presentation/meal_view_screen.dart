import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/domain/entity/intake_type_entity.dart';
import 'package:opennutritracker/core/presentation/widgets/meal_value_unit_text.dart';
import 'package:opennutritracker/core/presentation/widgets/image_full_screen.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/core/utils/navigation_options.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/features/edit_meal/presentation/edit_meal_screen.dart';
import 'package:opennutritracker/features/meal_detail/presentation/bloc/meal_detail_bloc.dart';
import 'package:opennutritracker/features/meal_detail/presentation/widgets/meal_detail_macro_nutrients.dart';
import 'package:opennutritracker/features/meal_detail/presentation/widgets/meal_detail_nutriments_table.dart';
import 'package:opennutritracker/features/meal_detail/presentation/widgets/meal_info_button.dart';
import 'package:opennutritracker/features/meal_detail/presentation/widgets/meal_placeholder.dart';
import 'package:opennutritracker/features/meal_detail/presentation/widgets/meal_title_expanded.dart';
import 'package:opennutritracker/features/meal_detail/presentation/widgets/off_disclaimer.dart';
import 'package:opennutritracker/generated/l10n.dart';

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

  @override
  void initState() {
    _mealDetailBloc = locator<MealDetailBloc>();

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

    // Initialize the bloc with meal's values
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
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }

  Widget _getLoadedContent(
      BuildContext context,
      String totalQuantity,
      double totalKcal,
      double totalCarbs,
      double totalFat,
      double totalProtein,
      String selectedUnit) {
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
                expandedTitleScale: 1, // don't scale title
                background: MealTitleExpanded(
                    meal: meal, usesImperialUnits: _usesImperialUnits),
                title: AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 300),
                    child:
                        top > barsHeight - offset && top < barsHeight + offset
                            ? Text(meal.name ?? '',
                                style: Theme.of(context).textTheme.titleLarge,
                                overflow: TextOverflow.ellipsis)
                            : const SizedBox()));
          }),
          actions: [],
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
                            ImageFullScreenArguments(meal.mainImageUrl ?? ""));
                  }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Text('${totalKcal.toInt()} ${S.of(context).kcalLabel}',
                        style: Theme.of(context).textTheme.headlineSmall),
                    MealValueUnitText(
                      value: double.parse(totalQuantity),
                      meal: meal,
                      displayUnit:
                          selectedUnit == UnitDropdownItem.serving.toString()
                              ? meal.servingUnit
                              : selectedUnit,
                      usesImperialUnits: _usesImperialUnits,
                      textStyle: Theme.of(context).textTheme.bodyMedium,
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
                        value: totalCarbs),
                    MealDetailMacroNutrients(
                        typeString: S.of(context).fatLabel, value: totalFat),
                    MealDetailMacroNutrients(
                        typeString: S.of(context).proteinLabel,
                        value: totalProtein)
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16.0),
                MealDetailNutrimentsTable(
                  product: meal,
                  usesImperialUnits: _usesImperialUnits,
                  servingQuantity: double.parse(totalQuantity),
                  servingUnit: selectedUnit == UnitDropdownItem.serving.toString()
                      ? meal.servingUnit
                      : selectedUnit,
                ),
                const SizedBox(height: 32.0),
                if (meal.foodItems != null && meal.foodItems!.isNotEmpty) ...[
                  const Text(
                    'Food Components',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...meal.foodItems!.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['name'] ?? 'Unknown',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(
                          '${item['estimated_grams']?.toStringAsFixed(1) ?? '0'}g',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 32.0),
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
                const SizedBox(height: 50.0) // height added to scroll
              ],
            ),
          )
        ]))
      ],
    );
  }


}

class MealViewScreenArguments {
  final MealEntity mealEntity;
  final IntakeTypeEntity intakeTypeEntity;
  final DateTime day;
  final bool usesImperialUnits;

  MealViewScreenArguments(
      this.mealEntity, this.intakeTypeEntity, this.day, this.usesImperialUnits);
}
