import 'package:flutter/material.dart';
import 'package:calorieai/features/home/presentation/widgets/dashboard_widget.dart';
import 'package:calorieai/features/home/presentation/widgets/fasting_timer_quick_view.dart';
import 'package:calorieai/features/weight_tracker/presentation/widgets/weight_tracker_widget.dart';
import 'package:calorieai/features/water_tracker/presentation/widgets/water_summary_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:calorieai/core/domain/entity/intake_entity.dart';
import 'package:calorieai/core/domain/entity/intake_type_entity.dart';
import 'package:calorieai/core/domain/entity/user_activity_entity.dart';
import 'package:calorieai/core/presentation/widgets/activity_vertial_list.dart';
import 'package:calorieai/core/presentation/widgets/delete_dialog.dart';
import 'package:calorieai/core/presentation/widgets/disclaimer_dialog.dart';
import 'package:calorieai/core/presentation/widgets/edit_dialog.dart';
import 'package:calorieai/core/utils/locator.dart';
import 'package:calorieai/features/add_meal/presentation/add_meal_type.dart';
import 'package:calorieai/features/home/presentation/bloc/home_bloc.dart';
import 'package:calorieai/features/home/presentation/widgets/intake_vertical_list.dart';
import 'package:calorieai/core/utils/navigation_options.dart';
import 'package:calorieai/features/meal_view/presentation/meal_view_screen.dart';
import 'package:calorieai/l10n/app_localizations.dart';
typedef S = AppLocalizations;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final log = Logger('HomePage');

  late HomeBloc _homeBloc;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _homeBloc = locator<HomeBloc>();
    _homeBloc.add(const LoadItemsEvent());
    // Refresh steps when home page becomes visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _homeBloc.add(const RefreshStepsEvent());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      bloc: _homeBloc,
      builder: (context, state) {
        if (state is HomeInitial) {
          _homeBloc.add(const LoadItemsEvent());
          return _getLoadingContent();
        } else if (state is HomeLoadingState) {
          return _getLoadingContent();
        } else if (state is HomeLoadedState) {
          return _getLoadedContent(
              context,
              state.showDisclaimerDialog,
              state.totalKcalDaily,
              state.totalKcalLeft,
              state.totalKcalSupplied,
              state.totalKcalBurned,
              state.totalCarbsIntake,
              state.totalFatsIntake,
              state.totalProteinsIntake,
              state.totalCarbsGoal,
              state.totalFatsGoal,
              state.totalProteinsGoal,
              state.totalSugarsIntake,
              state.totalSaturatedFatIntake,
              state.totalFiberIntake,
              state.breakfastIntakeList,
              state.lunchIntakeList,
              state.dinnerIntakeList,
              state.snackIntakeList,
              state.userActivityList,
              state.usesImperialUnits,
              state.todaySteps,
              state.showConsumedKcalAndMacros);
        } else {
          return _getLoadingContent();
        }
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      log.info('App resumed');
      _refreshPageOnDayChange();
      // Refresh steps without reloading entire UI
      _homeBloc.add(const RefreshStepsEvent());
    }
    super.didChangeAppLifecycleState(state);
  }

  Widget _getLoadingContent() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _getLoadedContent(
      BuildContext context,
      bool showDisclaimerDialog,
      double totalKcalDaily,
      double totalKcalLeft,
      double totalKcalSupplied,
      double totalKcalBurned,
      double totalCarbsIntake,
      double totalFatsIntake,
      double totalProteinsIntake,
      double totalCarbsGoal,
      double totalFatsGoal,
      double totalProteinsGoal,
      double totalSugarsIntake,
      double totalSaturatedFatIntake,
      double totalFiberIntake,
      List<IntakeEntity> breakfastIntakeList,
      List<IntakeEntity> lunchIntakeList,
      List<IntakeEntity> dinnerIntakeList,
      List<IntakeEntity> snackIntakeList,
      List<UserActivityEntity> userActivities,
      bool usesImperialUnits,
      int todaySteps,
      bool showConsumedKcalAndMacros) {
    if (showDisclaimerDialog) {
      _showDisclaimerDialog(context);
    }
    return Stack(children: [
      ListView(children: [
        // Using test widget instead of the real one
        // DashboardTestWidget(),
        const FastingTimerQuickView(),

        DashboardWidget(
          totalKcalDaily: totalKcalDaily,
          totalKcalLeft: totalKcalLeft,
          totalKcalSupplied: totalKcalSupplied,
          totalKcalBurned: totalKcalBurned,
          totalCarbsIntake: totalCarbsIntake,
          totalFatsIntake: totalFatsIntake,
          totalProteinsIntake: totalProteinsIntake,
          totalCarbsGoal: totalCarbsGoal,
          totalFatsGoal: totalFatsGoal,
          totalProteinsGoal: totalProteinsGoal,
          totalSugarsIntake: totalSugarsIntake,
          totalSaturatedFatIntake: totalSaturatedFatIntake,
          totalFiberIntake: totalFiberIntake,
          showConsumedKcalAndMacros: showConsumedKcalAndMacros,
        ),
        // Shortcuts section with water, weight, and steps in a row
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              const Icon(
                Icons.flash_on,
                size: 24,
              ),
              const SizedBox(width: 8.0),
              Text(
                'Shortcuts',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 120,
          child: Row(
            children: [
              Expanded(
                child: WeightTrackerWidget(
                  usesImperialUnits: usesImperialUnits,
                ),
              ),
              Expanded(
                child: WaterSummaryWidget(
                  usesImperialUnits: usesImperialUnits,
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.directions_walk,
                        size: 32,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        todaySteps.toString(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Steps',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        IntakeVerticalList(
          day: DateTime.now(),
          title: S.of(context).breakfastLabel,
          listIcon: IntakeTypeEntity.breakfast.getIconData(),
          addMealType: AddMealType.breakfastType,
          intakeList: breakfastIntakeList,
          onItemDragCallback: onIntakeItemDrag,
          onItemLongPressedCallback: onIntakeItemLongPressed,
          onItemTappedCallback: onIntakeItemTapped,
          usesImperialUnits: usesImperialUnits,
        ),
        IntakeVerticalList(
          day: DateTime.now(),
          title: S.of(context).lunchLabel,
          listIcon: IntakeTypeEntity.lunch.getIconData(),
          addMealType: AddMealType.lunchType,
          intakeList: lunchIntakeList,
          onItemDragCallback: onIntakeItemDrag,
          onItemTappedCallback: onIntakeItemTapped,
          onItemLongPressedCallback: onIntakeItemLongPressed,
          usesImperialUnits: usesImperialUnits,
        ),
        IntakeVerticalList(
          day: DateTime.now(),
          title: S.of(context).dinnerLabel,
          addMealType: AddMealType.dinnerType,
          listIcon: IntakeTypeEntity.dinner.getIconData(),
          intakeList: dinnerIntakeList,
          onItemDragCallback: onIntakeItemDrag,
          onItemTappedCallback: onIntakeItemTapped,
          onItemLongPressedCallback: onIntakeItemLongPressed,
          usesImperialUnits: usesImperialUnits,
        ),
        IntakeVerticalList(
          day: DateTime.now(),
          title: S.of(context).snackLabel,
          listIcon: IntakeTypeEntity.snack.getIconData(),
          addMealType: AddMealType.snackType,
          intakeList: snackIntakeList,
          onItemDragCallback: onIntakeItemDrag,
          onItemTappedCallback: onIntakeItemTapped,
          onItemLongPressedCallback: onIntakeItemLongPressed,
          usesImperialUnits: usesImperialUnits,
        ),
        
        ActivityVerticalList(
          day: DateTime.now(),
          title: S.of(context).activityLabel,
          userActivityList: userActivities,
          onItemLongPressedCallback: onActivityItemLongPressed,
        ),
       
      ]),
      Align(
          alignment: Alignment.bottomCenter,
          child: Visibility(
              visible: _isDragging,
              child: Container(
                height: 70,
                color: Theme.of(context).colorScheme.error
                  ..withValues(alpha: 0.3),
                child: DragTarget<IntakeEntity>(
                  onAcceptWithDetails: (data) {
                    _confirmDelete(context, data.data);
                  },
                  onLeave: (data) {
                    setState(() {
                      _isDragging = false;
                    });
                  },
                  builder: (context, candidateData, rejectedData) {
                    return const Center(
                      child: Icon(
                        Icons.delete_outline,
                        size: 36,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              )))
    ]);
  }

  void onActivityItemLongPressed(
      BuildContext context, UserActivityEntity activityEntity) async {
    final deleteIntake = await showDialog<bool>(
        context: context, builder: (context) => const DeleteDialog());

    if (deleteIntake != null) {
      _homeBloc.deleteUserActivityItem(activityEntity);
      _homeBloc.add(const LoadItemsEvent());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).itemDeletedSnackbar)));
      }
    }
  }

  void onIntakeItemLongPressed(BuildContext context, IntakeEntity intakeEntity,
      bool usesImperialUnits) async {
    await Navigator.of(context).pushNamed(
      NavigationOptions.mealViewRoute,
      arguments: MealViewScreenArguments(
        intakeEntity.meal,
        intakeEntity.type,
        DateTime.now(),
        usesImperialUnits,
      ),
    );
  }

/*   void onIntakeItemLongPressed(
      BuildContext context, IntakeEntity intakeEntity) async {
    final deleteIntake = await showDialog<bool>(
        context: context, builder: (context) => const DeleteDialog());

    if (deleteIntake != null) {
      _homeBloc.deleteIntakeItem(intakeEntity);
      _homeBloc.add(const LoadItemsEvent());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).itemDeletedSnackbar)));
      }
    }
  } */

  void onIntakeItemDrag(bool isDragging) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isDragging = isDragging;
      });
    });
  }

/*   void onIntakeItemTapped(BuildContext context, IntakeEntity intakeEntity,
      bool usesImperialUnits) async {
    await Navigator.of(context).pushNamed(
      NavigationOptions.mealDetailRoute,
      arguments: MealDetailScreenArguments(
        intakeEntity.meal,
        intakeEntity.type,
        DateTime.now(),
        usesImperialUnits,
      ),
    );
  } */

  void onIntakeItemTapped(BuildContext context, IntakeEntity intakeEntity,
      bool usesImperialUnits) async {
    final changeIntakeAmount = await showDialog<double>(
        context: context,
        builder: (context) => EditDialog(
            intakeEntity: intakeEntity, usesImperialUnits: usesImperialUnits));
    if (changeIntakeAmount != null) {
      _homeBloc
          .updateIntakeItem(intakeEntity.id, {'amount': changeIntakeAmount});
      _homeBloc.add(const LoadItemsEvent());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).itemUpdatedSnackbar)));
      }
    }
  }

  void _confirmDelete(BuildContext context, IntakeEntity intake) async {
    bool? delete = await showDialog<bool>(
        context: context, builder: (context) => const DeleteDialog());

    if (delete == true) {
      _homeBloc.deleteIntakeItem(intake);
      _homeBloc.add(const LoadItemsEvent());
    }
    setState(() {
      _isDragging = false;
    });
  }

  /// Show disclaimer dialog after build method
  void _showDisclaimerDialog(BuildContext context) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final dialogConfirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return const DisclaimerDialog();
          });
      if (dialogConfirmed != null) {
        _homeBloc.saveConfigData(dialogConfirmed);
        _homeBloc.add(const LoadItemsEvent());
      }
    });
  }

  /// Refresh page when day changes
  void _refreshPageOnDayChange() {
    if (!DateUtils.isSameDay(_homeBloc.currentDay, DateTime.now())) {
      _homeBloc.add(const LoadItemsEvent());
    }
  }
}
