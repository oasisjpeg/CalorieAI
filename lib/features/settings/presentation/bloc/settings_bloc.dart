import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:calorieai/shared/iap_service.dart';
import 'package:calorieai/core/domain/entity/app_theme_entity.dart';
import 'package:calorieai/core/domain/usecase/add_config_usecase.dart';
import 'package:calorieai/core/domain/usecase/add_tracked_day_usecase.dart';
import 'package:calorieai/core/domain/usecase/get_config_usecase.dart';
import 'package:calorieai/core/domain/usecase/get_kcal_goal_usecase.dart';
import 'package:calorieai/core/domain/usecase/get_macro_goal_usecase.dart';
import 'package:calorieai/core/service/food_tracking_notification_service.dart';
import 'package:calorieai/core/services/apple_health_service.dart';
import 'package:calorieai/core/services/synology_health_service.dart';
import 'package:calorieai/core/utils/app_const.dart';
import 'package:calorieai/core/utils/calc/modern_tdee_calc.dart';
import 'package:calorieai/core/data/repository/intake_repository.dart';
import 'package:calorieai/core/data/repository/user_activity_repository.dart';
import 'package:calorieai/core/data/repository/physical_activity_repository.dart';
import 'package:calorieai/core/utils/locator.dart';

part 'settings_event.dart';

part 'settings_state.dart';

class SettingsResyncProgress {
  final int total;
  final int current;
  final String status;
  final bool isComplete;

  const SettingsResyncProgress({
    this.total = 0,
    this.current = 0,
    this.status = '',
    this.isComplete = false,
  });

  double get progress => total > 0 ? current / total : 0.0;
}

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final log = Logger('SettingsBloc');

  final GetConfigUsecase _getConfigUsecase;
  final AddConfigUsecase _addConfigUsecase;
  final AddTrackedDayUsecase _addTrackedDayUsecase;
  final GetKcalGoalUsecase _getKcalGoalUsecase;
  final GetMacroGoalUsecase _getMacroGoalUsecase;
  final FoodTrackingNotificationService _foodTrackingNotificationService;
  final IAPService _iapService = IAPService();

  final StreamController<SettingsResyncProgress> _resyncProgressController = StreamController<SettingsResyncProgress>.broadcast();
  Stream<SettingsResyncProgress> get resyncProgressStream => _resyncProgressController.stream;

  SettingsBloc(
      this._getConfigUsecase,
      this._addConfigUsecase,
      this._addTrackedDayUsecase,
      this._getKcalGoalUsecase,
      this._getMacroGoalUsecase,
      this._foodTrackingNotificationService)
      : super(SettingsInitial()) {
    // Initialize IAP service when the bloc is created
    _iapService.init();
  
    on<LoadSettingsEvent>((event, emit) async {
      emit(SettingsLoadingState());

      final userConfig = await _getConfigUsecase.getConfig();
      final appVersion = await AppConst.getVersionNumber();
      final usesImperialUnits = userConfig.usesImperialUnits;
      final foodTrackingNotificationsEnabled = userConfig.foodTrackingNotificationsEnabled;
      final appleHealthSyncEnabled = userConfig.appleHealthSyncEnabled;
      final appleHealthActivitySyncEnabled = userConfig.appleHealthActivitySyncEnabled;
      final showConsumedKcalAndMacros = userConfig.showConsumedKcalAndMacros;
      final synologyHealthSyncEnabled = userConfig.synologyHealthSyncEnabled;
      final synologyHealthHistoricSyncedAt = userConfig.synologyHealthHistoricSyncedAt;

      // Check Synology server reachability
      final synologyService = locator<SynologyHealthService>();
      final synologyServerReachable = synologyService.isServerReachable;

      // Get subscription status
      final isSubscribed = await _iapService.hasActiveSubscription();

      emit(SettingsLoadedState(
          appVersion,
          userConfig.hasAcceptedSendAnonymousData,
          userConfig.appTheme,
          usesImperialUnits,
          isSubscribed: isSubscribed,
          foodTrackingNotificationsEnabled: foodTrackingNotificationsEnabled,
          appleHealthSyncEnabled: appleHealthSyncEnabled,
          appleHealthActivitySyncEnabled: appleHealthActivitySyncEnabled,
          showConsumedKcalAndMacros: showConsumedKcalAndMacros,
          synologyHealthSyncEnabled: synologyHealthSyncEnabled,
          synologyHealthHistoricSyncedAt: synologyHealthHistoricSyncedAt,
          synologyServerReachable: synologyServerReachable));
    });

    on<ToggleFoodTrackingNotificationsEvent>((event, emit) async {
      if (state is SettingsLoadedState) {
        final currentState = state as SettingsLoadedState;
        await _addConfigUsecase.setFoodTrackingNotificationsEnabled(event.enabled);
        // Schedule or cancel notifications based on the toggle
        await _foodTrackingNotificationService.setNotificationsEnabled(event.enabled);
        emit(currentState.copyWith(foodTrackingNotificationsEnabled: event.enabled));
      }
    });

    on<ToggleConsumedDashboardModeEvent>((event, emit) async {
      if (state is SettingsLoadedState) {
        final currentState = state as SettingsLoadedState;
        await _addConfigUsecase.setShowConsumedKcalAndMacros(event.enabled);
        emit(currentState.copyWith(showConsumedKcalAndMacros: event.enabled));
      }
    });

    on<ToggleAppleHealthSyncEvent>((event, emit) async {
      if (state is SettingsLoadedState) {
        final currentState = state as SettingsLoadedState;

        if (event.enabled) {
          // Request both nutrition and activity permissions when enabling
          final appleHealthService = locator<AppleHealthService>();
          final nutritionGranted = await appleHealthService.requestPermissions();
          final activityGranted = await appleHealthService.requestActivityPermissions();

          if (nutritionGranted && activityGranted) {
            await _addConfigUsecase.setAppleHealthSyncEnabled(true);
            await _addConfigUsecase.setAppleHealthActivitySyncEnabled(true);
            emit(currentState.copyWith(
              appleHealthSyncEnabled: true,
              appleHealthActivitySyncEnabled: true,
            ));

            // Fetch and store today's steps
            try {
              final today = DateTime.now();
              final startDate = DateTime(today.year, today.month, today.day);
              final endDate = DateTime(today.year, today.month, today.day, 23, 59, 59);
              final stepsMap = await appleHealthService.getStepsFromHealthKit(startDate, endDate);
              final todaySteps = stepsMap[startDate] ?? 0;
              if (todaySteps > 0) {
                await _addConfigUsecase.setLastSteps(todaySteps, DateTime.now());
                log.info('Stored initial steps: $todaySteps');
              }
            } catch (e) {
              log.warning('Failed to fetch steps on health sync enable: $e');
            }

            // Trigger historic sync in the background
            syncAllIntakesToHealthKit();
            _syncHistoricActivities();
          }
          // If not granted, don't enable the setting
        } else {
          // Clear cached steps when disabling Apple Health sync
          await _addConfigUsecase.clearLastSteps();
          log.info('Cleared cached steps on Apple Health sync disable');

          await _addConfigUsecase.setAppleHealthSyncEnabled(false);
          await _addConfigUsecase.setAppleHealthActivitySyncEnabled(false);
          emit(currentState.copyWith(
            appleHealthSyncEnabled: false,
            appleHealthActivitySyncEnabled: false,
          ));
        }
      }
    });

    on<ResyncAppleHealthIntakesEvent>((event, emit) async {
      await syncAllIntakesToHealthKit(force: true);
    });

    on<ToggleSynologyHealthSyncEvent>((event, emit) async {
      if (state is SettingsLoadedState) {
        final currentState = state as SettingsLoadedState;

        if (event.enabled) {
          // Proactively check if server is reachable before enabling
          final synologyService = locator<SynologyHealthService>();
          if (!synologyService.isServerReachable) {
            log.warning('Refusing to enable Synology sync: server is unreachable');
            emit(currentState.copyWith(
              synologyHealthSyncEnabled: false,
              synologyServerReachable: false,
            ));
            return;
          }
        }

        await _addConfigUsecase.setSynologyHealthSyncEnabled(event.enabled);
        emit(currentState.copyWith(
          synologyHealthSyncEnabled: event.enabled,
        ));

        if (event.enabled) {
          // Trigger historic sync in the background
          _syncHistoricSynology();
        }
      }
    });

    on<ResyncSynologyHealthEvent>((event, emit) async {
      await _resyncSynologyHealth();
    });

  }

  void setHasAcceptedAnonymousData(bool hasAcceptedAnonymousData) {
    _addConfigUsecase
        .setConfigHasAcceptedAnonymousData(hasAcceptedAnonymousData);
  }

  void setAppTheme(AppThemeEntity appTheme) async {
    await _addConfigUsecase.setConfigAppTheme(appTheme);
  }

  void setUsesImperialUnits(bool usesImperialUnits) {
    _addConfigUsecase.setConfigUsesImperialUnits(usesImperialUnits);
  }

  Future<double> getKcalAdjustment() async {
    final config = await _getConfigUsecase.getConfig();
    return config.userKcalAdjustment ?? 0;
  }

  Future<double?> getUserCarbGoalPct() async {
    final config = await _getConfigUsecase.getConfig();
    return config.userCarbGoalPct;
  }

  Future<double?> getUserProteinGoalPct() async {
    final config = await _getConfigUsecase.getConfig();
    return config.userProteinGoalPct;
  }

  Future<double?> getUserFatGoalPct() async {
    final config = await _getConfigUsecase.getConfig();
    return config.userFatGoalPct;
  }

  void setKcalAdjustment(double kcalAdjustment) {
    _addConfigUsecase.setConfigKcalAdjustment(kcalAdjustment);
  }
  void setMacroGoals(
      double carbGoalPct, double proteinGoalPct, double fatGoalPct) {
    _addConfigUsecase.setConfigMacroGoalPct(carbGoalPct.toInt() / 100,
        proteinGoalPct.toInt() / 100, fatGoalPct.toInt() / 100);
  }

  Future<BMRFormula?> getBMRFormula() async {
    final config = await _getConfigUsecase.getConfig();
    return config.bmrFormula;
  }

  void setBMRFormula(BMRFormula formula) {
    _addConfigUsecase.setConfigBMRFormula(formula);
  }

  Future<void> setLastStepsCount(int stepsCount) async {
    await _addConfigUsecase.setLastSteps(stepsCount, DateTime.now());
  }

  Future<void> clearLastSteps() async {
    await _addConfigUsecase.clearLastSteps();
  }

  void updateTrackedDay(DateTime day) async {
    final day = DateTime.now();
    final totalKcalGoal = await _getKcalGoalUsecase.getKcalGoal();
    final totalCarbsGoal =
        await _getMacroGoalUsecase.getCarbsGoal(totalKcalGoal);
    final totalFatGoal = await _getMacroGoalUsecase.getFatsGoal(totalKcalGoal);
    final totalProteinGoal =
        await _getMacroGoalUsecase.getProteinsGoal(totalKcalGoal);

    final hasTrackedDay = await _addTrackedDayUsecase.hasTrackedDay(day);

    if (hasTrackedDay) {
      await _addTrackedDayUsecase.updateDayCalorieGoal(day, totalKcalGoal);
      await _addTrackedDayUsecase.updateDayMacroGoals(day,
          carbsGoal: totalCarbsGoal,
          fatGoal: totalFatGoal,
          proteinGoal: totalProteinGoal);
    }
  }

  Future<(int successCount, int failureCount)> syncAllIntakesToHealthKit({bool force = false}) async {
    try {
      log.info('Historic Apple Health sync started (force=$force)');

      // Check if sync was done recently (within last hour) to prevent duplicate syncs
      if (!force) {
        final lastSyncTimestamp = await _addConfigUsecase.getLastHealthKitSyncTimestamp();
        if (lastSyncTimestamp != null) {
          final timeSinceLastSync = DateTime.now().difference(lastSyncTimestamp);
          if (timeSinceLastSync.inHours < 1) {
            log.info('Skipping historic sync - last sync was ${timeSinceLastSync.inMinutes} minutes ago');
            return (0, 0);
          }
        }
      }

      final appleHealthService = locator<AppleHealthService>();
      final intakeRepository = locator<IntakeRepository>();
      final allIntakes = await intakeRepository.getAllIntakes();

      // When forcing (resync), first delete all existing nutrition data from HealthKit
      if (force) {
        _resyncProgressController.add(const SettingsResyncProgress(
          status: 'Deleting existing nutrition data...',
        ));
        final deleteStart = DateTime(2000, 1, 1);
        final deleteEnd = DateTime.now().add(const Duration(days: 1));
        final deletedCount = await appleHealthService.deleteAllNutritionData(deleteStart, deleteEnd);
        log.info('Deleted $deletedCount existing nutrition samples from HealthKit');
      }

      final total = allIntakes.length;
      int successCount = 0;
      int failureCount = 0;

      _resyncProgressController.add(SettingsResyncProgress(
        total: total,
        status: 'Syncing $total meal intakes...',
      ));

      for (var i = 0; i < allIntakes.length; i++) {
        final intake = allIntakes[i];
        try {
          await appleHealthService.syncIntake(intake);
          successCount++;
        } catch (e) {
          log.warning('Failed to sync intake ${intake.id}: $e');
          failureCount++;
        }
        _resyncProgressController.add(SettingsResyncProgress(
          total: total,
          current: i + 1,
          status: 'Syncing $total meal intakes...',
        ));
      }

      // Update sync timestamp
      await _addConfigUsecase.setLastHealthKitSyncTimestamp(DateTime.now());

      _resyncProgressController.add(SettingsResyncProgress(
        total: total,
        current: total,
        status: 'Done! $successCount synced, $failureCount failed.',
        isComplete: true,
      ));

      log.info('Historic sync complete: $successCount succeeded, $failureCount failed');
      return (successCount, failureCount);
    } catch (e) {
      log.severe('Error syncing historic intakes: $e');
      _resyncProgressController.add(const SettingsResyncProgress(
        status: 'Error during sync.',
        isComplete: true,
      ));
      return (0, 0);
    }
  }

  Future<void> _syncHistoricActivities() async {
    try {
      log.info('Historic Apple Health activity sync started');

      // Check if sync was done recently (within last hour) to prevent duplicate syncs
      final lastSyncTimestamp = await _addConfigUsecase.getLastHealthKitSyncTimestamp();
      if (lastSyncTimestamp != null) {
        final timeSinceLastSync = DateTime.now().difference(lastSyncTimestamp);
        if (timeSinceLastSync.inHours < 1) {
          log.info('Skipping historic activity sync - last sync was ${timeSinceLastSync.inMinutes} minutes ago');
          return;
        }
      }

      final appleHealthService = locator<AppleHealthService>();
      final userActivityRepository = locator<UserActivityRepository>();
      final physicalActivityRepository = locator<PhysicalActivityRepository>();

      // Sync historic workouts
      final workoutsSynced = await appleHealthService.syncHistoricActivitiesFromHealthKit(
        userActivityRepository.isActivityAlreadySynced,
        userActivityRepository.addUserActivityWithHealthKitId,
        physicalActivityRepository.getAllPhysicalActivities,
      );

      // Update sync timestamp
      await _addConfigUsecase.setLastHealthKitSyncTimestamp(DateTime.now());

      log.info('Historic activity sync complete: $workoutsSynced workouts synced');

      // Trigger nutrition recalculation for synced activities
      if (workoutsSynced > 0) {
        await _recalculateNutritionForSyncedActivities();
      }
    } catch (e) {
      log.severe('Error syncing historic activities: $e');
    }
  }

  Future<void> _recalculateNutritionForSyncedActivities() async {
    try {
      log.info('Recalculating nutrition for synced activities');
      // Nutrition recalculation will happen automatically when the home screen refreshes
      // The user will see updated calorie goals based on synced activities
    } catch (e) {
      log.severe('Error recalculating nutrition: $e');
    }
  }

  Future<void> _syncHistoricSynology() async {
    try {
      final alreadySynced = await _addConfigUsecase.getSynologyHealthHistoricSyncedAt();
      if (alreadySynced != null) {
        log.info('Skipping historic Synology sync - already synced at $alreadySynced');
        return;
      }

      await _runSynologyHistoricSync();
    } catch (e) {
      log.severe('Error syncing historic intakes to Synology: $e');
    }
  }

  Future<void> _resyncSynologyHealth() async {
    try {
      log.info('Manual historic Synology resync started');
      await _runSynologyHistoricSync();
    } catch (e) {
      log.severe('Error resyncing historic intakes to Synology: $e');
    }
  }

  Future<void> _runSynologyHistoricSync() async {
    final synologyService = locator<SynologyHealthService>();
    final intakeRepository = locator<IntakeRepository>();
    final allIntakes = await intakeRepository.getAllIntakes();
    await synologyService.syncHistoricIntakes(allIntakes);
  }

  @override
  Future<void> close() {
    _resyncProgressController.close();
    return super.close();
  }
}

enum SystemDropDownType { metric, imperial }
