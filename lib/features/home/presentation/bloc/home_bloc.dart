import 'dart:async';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:calorieai/core/domain/entity/intake_entity.dart';
import 'package:calorieai/core/domain/entity/user_activity_entity.dart';
import 'package:calorieai/core/domain/usecase/add_config_usecase.dart';
import 'package:calorieai/core/domain/usecase/add_tracked_day_usecase.dart';
import 'package:calorieai/core/domain/usecase/add_user_activity_usercase.dart';
import 'package:calorieai/core/domain/usecase/delete_intake_usecase.dart';
import 'package:calorieai/core/domain/usecase/delete_user_activity_usecase.dart';
import 'package:calorieai/core/domain/usecase/get_config_usecase.dart';
import 'package:calorieai/core/domain/usecase/get_intake_usecase.dart';
import 'package:calorieai/core/domain/usecase/get_kcal_goal_usecase.dart';
import 'package:calorieai/core/domain/usecase/get_macro_goal_usecase.dart';
import 'package:calorieai/core/domain/usecase/get_physical_activity_usecase.dart';
import 'package:calorieai/core/domain/usecase/get_tracked_day_usecase.dart';
import 'package:calorieai/core/domain/usecase/get_user_activity_usecase.dart';
import 'package:calorieai/core/domain/usecase/update_intake_usecase.dart';
import 'package:calorieai/core/services/apple_health_service.dart';
import 'package:calorieai/core/utils/calc/calorie_goal_calc.dart';
import 'package:calorieai/core/utils/calc/macro_calc.dart';
import 'package:calorieai/core/utils/locator.dart';
import 'package:calorieai/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:calorieai/features/diary/presentation/bloc/diary_bloc.dart';

part 'home_event.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetConfigUsecase _getConfigUsecase;
  final AddConfigUsecase _addConfigUsecase;
  final GetIntakeUsecase _getIntakeUsecase;
  final DeleteIntakeUsecase _deleteIntakeUsecase;
  final UpdateIntakeUsecase _updateIntakeUsecase;
  final GetUserActivityUsecase _getUserActivityUsecase;
  final DeleteUserActivityUsecase _deleteUserActivityUsecase;
  final AddTrackedDayUsecase _addTrackedDayUseCase;
  final GetTrackedDayUsecase _getTrackedDayUsecase;
  final GetKcalGoalUsecase _getKcalGoalUsecase;
  final GetMacroGoalUsecase _getMacroGoalUsecase;
  final AddUserActivityUsecase _addUserActivityUsecase;
  final GetPhysicalActivityUsecase _getPhysicalActivityUsecase;
  final AppleHealthService _appleHealthService;
  final log = Logger('HomeBloc');

  DateTime? currentDay;

  HomeBloc(
      this._getConfigUsecase,
      this._addConfigUsecase,
      this._getIntakeUsecase,
      this._deleteIntakeUsecase,
      this._updateIntakeUsecase,
      this._getUserActivityUsecase,
      this._deleteUserActivityUsecase,
      this._addTrackedDayUseCase,
      this._getTrackedDayUsecase,
      this._getKcalGoalUsecase,
      this._getMacroGoalUsecase,
      this._addUserActivityUsecase,
      this._getPhysicalActivityUsecase,
      this._appleHealthService)
      : super(HomeInitial()) {
    on<LoadItemsEvent>((event, emit) async {
      emit(HomeLoadingState());

      currentDay = DateTime.now();
      var configData = await _getConfigUsecase.getConfig();
      final usesImperialUnits = configData.usesImperialUnits;
      final showDisclaimerDialog = !configData.hasAcceptedDisclaimer;
      final showConsumedKcalAndMacros = configData.showConsumedKcalAndMacros;
      
      // Check if day has changed and convert yesterday's steps to walking activity
      if (configData.lastStepsUpdateDate != null) {
        final lastUpdateDate = configData.lastStepsUpdateDate!;
        final today = DateTime.now();
        final yesterday = DateTime(today.year, today.month, today.day);
        final lastUpdateDay = DateTime(lastUpdateDate.year, lastUpdateDate.month, lastUpdateDate.day);
        
        if (lastUpdateDay.isBefore(yesterday) && configData.lastStepsCount > 0) {
          log.info('Day has changed, converting yesterday\'s steps (${configData.lastStepsCount}) to walking activity');
          await _convertStepsToWalkingActivity(configData.lastStepsCount, lastUpdateDay);
          // Clear cached steps after converting to activity
          await _addConfigUsecase.clearLastSteps();
          configData = await _getConfigUsecase.getConfig();
        }
      }
      
      // Load cached steps immediately
      int todaySteps = configData.lastStepsCount;
      log.info('Loaded cached steps: $todaySteps, last updated: ${configData.lastStepsUpdateDate}');

      final breakfastIntakeList =
          await _getIntakeUsecase.getTodayBreakfastIntake();
      final totalBreakfastKcal = getTotalKcal(breakfastIntakeList);
      final totalBreakfastCarbs = getTotalCarbs(breakfastIntakeList);
      final totalBreakfastFats = getTotalFats(breakfastIntakeList);
      final totalBreakfastProteins = getTotalProteins(breakfastIntakeList);

      final lunchIntakeList = await _getIntakeUsecase.getTodayLunchIntake();
      final totalLunchKcal = getTotalKcal(lunchIntakeList);
      final totalLunchCarbs = getTotalCarbs(lunchIntakeList);
      final totalLunchFats = getTotalFats(lunchIntakeList);
      final totalLunchProteins = getTotalProteins(lunchIntakeList);

      final dinnerIntakeList = await _getIntakeUsecase.getTodayDinnerIntake();
      final totalDinnerKcal = getTotalKcal(dinnerIntakeList);
      final totalDinnerCarbs = getTotalCarbs(dinnerIntakeList);
      final totalDinnerFats = getTotalFats(dinnerIntakeList);
      final totalDinnerProteins = getTotalProteins(dinnerIntakeList);

      final snackIntakeList = await _getIntakeUsecase.getTodaySnackIntake();
      final totalSnackKcal = getTotalKcal(snackIntakeList);
      final totalSnackCarbs = getTotalCarbs(snackIntakeList);
      final totalSnackFats = getTotalFats(snackIntakeList);
      final totalSnackProteins = getTotalProteins(snackIntakeList);
      final totalSnackSugars = getTotalSugars(snackIntakeList);
      final totalSnackSaturatedFat = getTotalSaturatedFat(snackIntakeList);
      final totalSnackFiber = getTotalFiber(snackIntakeList);

      final totalKcalIntake = totalBreakfastKcal +
          totalLunchKcal +
          totalDinnerKcal +
          totalSnackKcal;
      final totalCarbsIntake = totalBreakfastCarbs +
          totalLunchCarbs +
          totalDinnerCarbs +
          totalSnackCarbs;
      final totalFatsIntake = totalBreakfastFats +
          totalLunchFats +
          totalDinnerFats +
          totalSnackFats;
      final totalProteinsIntake = totalBreakfastProteins +
          totalLunchProteins +
          totalDinnerProteins +
          totalSnackProteins;
      final totalSugarsIntake = getTotalSugars(breakfastIntakeList) +
          getTotalSugars(lunchIntakeList) +
          getTotalSugars(dinnerIntakeList) +
          totalSnackSugars;
      final totalSaturatedFatIntake = getTotalSaturatedFat(breakfastIntakeList) +
          getTotalSaturatedFat(lunchIntakeList) +
          getTotalSaturatedFat(dinnerIntakeList) +
          totalSnackSaturatedFat;
      final totalFiberIntake = getTotalFiber(breakfastIntakeList) +
          getTotalFiber(lunchIntakeList) +
          getTotalFiber(dinnerIntakeList) +
          totalSnackFiber;

      final userActivities =
          await _getUserActivityUsecase.getTodayUserActivity();
      final totalKcalActivities =
          userActivities.map((activity) => activity.burnedKcal).toList().sum;

      // Use tracked day goals when available to stay in sync with diary page
      final trackedDay = await _getTrackedDayUsecase.getTrackedDay(DateTime.now());
      final totalKcalGoal = trackedDay?.calorieGoal ??
          await _getKcalGoalUsecase.getKcalGoal(
              includeActivityCalories: true,
              totalKcalActivitiesParam: totalKcalActivities);
      final totalCarbsGoal = trackedDay?.carbsGoal ??
          await _getMacroGoalUsecase.getCarbsGoal(totalKcalGoal);
      final totalFatsGoal = trackedDay?.fatGoal ??
          await _getMacroGoalUsecase.getFatsGoal(totalKcalGoal);
      final totalProteinsGoal = trackedDay?.proteinGoal ??
          await _getMacroGoalUsecase.getProteinsGoal(totalKcalGoal);

      final totalKcalLeft =
          CalorieGoalCalc.getDailyKcalLeft(totalKcalGoal, totalKcalIntake);

      // Fetch fresh steps from HealthKit on initial load only
      final today = DateTime.now();
      final startDate = DateTime(today.year, today.month, today.day);
      final endDate = DateTime(today.year, today.month, today.day, 23, 59, 59);
      
      log.info('HealthKit authorized: ${_appleHealthService.isAuthorized}');
      
      // Try to restore authorization state if not authorized
      if (!_appleHealthService.isAuthorized) {
        log.info('HealthKit not authorized, attempting to restore authorization state');
        await _appleHealthService.restoreAuthorizationState();
        log.info('Authorization restoration complete: ${_appleHealthService.isAuthorized}');
      }
      
      if (_appleHealthService.isAuthorized) {
        final stepsMap = await _appleHealthService.getStepsFromHealthKit(startDate, endDate);
        final freshSteps = stepsMap[startDate] ?? 0;
        log.info('Fresh steps from HealthKit on app load: $freshSteps, stepsMap: $stepsMap');
        
        // Update cached steps if fresh data is available (even if 0, to reflect actual HealthKit state)
        todaySteps = freshSteps;
        log.info('Setting steps to: $todaySteps');
        
        // Update config with fresh steps
        try {
          await _addConfigUsecase.setLastSteps(todaySteps, DateTime.now());
        } catch (e) {
          log.warning('Failed to update cached steps: $e');
        }
      } else {
        log.info('HealthKit not authorized after restoration attempt, using cached steps: $todaySteps');
      }

      emit(HomeLoadedState(
          showDisclaimerDialog: showDisclaimerDialog,
          totalKcalDaily: totalKcalGoal,
          totalKcalLeft: totalKcalLeft,
          totalKcalSupplied: totalKcalIntake,
          totalKcalBurned: totalKcalActivities,
          totalCarbsIntake: totalCarbsIntake,
          totalFatsIntake: totalFatsIntake,
          totalCarbsGoal: totalCarbsGoal,
          totalFatsGoal: totalFatsGoal,
          totalProteinsGoal: totalProteinsGoal,
          totalProteinsIntake: totalProteinsIntake,
          totalSugarsIntake: totalSugarsIntake,
          totalSaturatedFatIntake: totalSaturatedFatIntake,
          totalFiberIntake: totalFiberIntake,
          breakfastIntakeList: breakfastIntakeList,
          lunchIntakeList: lunchIntakeList,
          dinnerIntakeList: dinnerIntakeList,
          snackIntakeList: snackIntakeList,
          userActivityList: userActivities,
          usesImperialUnits: usesImperialUnits,
          todaySteps: todaySteps,
          showConsumedKcalAndMacros: showConsumedKcalAndMacros));
    });

    on<RefreshStepsEvent>((event, emit) async {
      if (state is HomeLoadedState) {
        final currentState = state as HomeLoadedState;
        
        // Fetch fresh steps from HealthKit
        final today = DateTime.now();
        final startDate = DateTime(today.year, today.month, today.day);
        final endDate = DateTime(today.year, today.month, today.day, 23, 59, 59);
        
        // Try to restore authorization state if not authorized
        if (!_appleHealthService.isAuthorized) {
          log.info('HealthKit not authorized during refresh, attempting to restore authorization state');
          await _appleHealthService.restoreAuthorizationState();
          log.info('Authorization restoration complete: ${_appleHealthService.isAuthorized}');
        }
        
        if (_appleHealthService.isAuthorized) {
          final stepsMap = await _appleHealthService.getStepsFromHealthKit(startDate, endDate);
          final freshSteps = stepsMap[startDate] ?? 0;
          log.info('Refreshed steps from HealthKit: $freshSteps');
          
          // Update config with fresh steps
          try {
            await _addConfigUsecase.setLastSteps(freshSteps, DateTime.now());
          } catch (e) {
            log.warning('Failed to update cached steps: $e');
          }
          
          // Emit new state with updated steps only
          emit(currentState.copyWith(todaySteps: freshSteps));
        } else {
          log.warning('HealthKit not authorized after restoration attempt, cannot refresh steps');
        }
      }
    });
  }

  double getTotalKcal(List<IntakeEntity> intakeList) =>
      intakeList.map((intake) => intake.totalKcal).toList().sum;

  double getTotalCarbs(List<IntakeEntity> intakeList) =>
      intakeList.map((intake) => intake.totalCarbsGram).toList().sum;

  double getTotalFats(List<IntakeEntity> intakeList) =>
      intakeList.map((intake) => intake.totalFatsGram).toList().sum;

  double getTotalProteins(List<IntakeEntity> intakeList) =>
      intakeList.map((intake) => intake.totalProteinsGram).toList().sum;

  double getTotalSugars(List<IntakeEntity> intakeList) =>
      intakeList.map((intake) => intake.totalSugarsGram).toList().sum;

  double getTotalSaturatedFat(List<IntakeEntity> intakeList) =>
      intakeList.map((intake) => intake.totalSaturatedFatGram).toList().sum;

  double getTotalFiber(List<IntakeEntity> intakeList) =>
      intakeList.map((intake) => intake.totalFiberGram).toList().sum;

  Future<void> _convertStepsToWalkingActivity(int steps, DateTime date) async {
    try {
      // Estimate calories burned from steps (approx 0.04 kcal per step)
      final burnedKcal = (steps * 0.04).round();
      
      // Get walking physical activity (code "17160" for walking for pleasure)
      final physicalActivities = await _getPhysicalActivityUsecase.getAllPhysicalActivities();
      final walkingActivity = physicalActivities.firstWhere(
        (pa) => pa.code == '17160',
        orElse: () => physicalActivities.first,
      );
      
      // Create user activity for the walking
      final userActivity = UserActivityEntity(
        DateTime.now().millisecondsSinceEpoch.toString(),
        (steps / 100).round().toDouble(), // Rough estimate: 100 steps per minute
        burnedKcal.toDouble(),
        DateTime(date.year, date.month, date.day, 12, 0), // Mid-day
        walkingActivity,
      );
      
      // Add the activity
      await _addUserActivityUsecase.addUserActivity(userActivity);
      log.info('Created walking activity from $steps steps: $burnedKcal kcal burned');
      
      // Refresh calendar day to show the new activity
      locator<CalendarDayBloc>().add(RefreshCalendarDayEvent());
    } catch (e) {
      log.warning('Failed to convert steps to walking activity: $e');
    }
  }

  void saveConfigData(bool acceptedDisclaimer) async {
    _addConfigUsecase.setConfigDisclaimer(acceptedDisclaimer);
  }

  Future<void> updateIntakeItem(
      String intakeId, Map<String, dynamic> fields) async {
    final dateTime = DateTime.now();
    // Get old intake values
    final oldIntakeObject = await _getIntakeUsecase.getIntakeById(intakeId);
    assert(oldIntakeObject != null);
    final newIntakeObject =
        await _updateIntakeUsecase.updateIntake(intakeId, fields);
    assert(newIntakeObject != null);

    // Re-sync to HealthKit if enabled: remove the stale entry and write
    // the updated one so Apple Health reflects the new amount.
    final configData = await _getConfigUsecase.getConfig();
    if (configData.appleHealthSyncEnabled) {
      try {
        await _appleHealthService.deleteIntakeFromHealthKit(
          oldIntakeObject!.id,
          oldIntakeObject.dateTime,
          oldIntakeObject.totalKcal,
          oldIntakeObject.meal.name ?? 'Meal',
        );
        await _appleHealthService.syncIntake(newIntakeObject!);
      } catch (e) {
        log.warning('Failed to re-sync updated intake to HealthKit: $e');
      }
    }

    if (oldIntakeObject!.amount > newIntakeObject!.amount) {
      // Amounts shrunk
      await _addTrackedDayUseCase.removeDayCaloriesTracked(
          dateTime, oldIntakeObject.totalKcal - newIntakeObject.totalKcal);
      await _addTrackedDayUseCase.removeDayMacrosTracked(dateTime,
          carbsTracked:
              oldIntakeObject.totalCarbsGram - newIntakeObject.totalCarbsGram,
          fatTracked:
              oldIntakeObject.totalFatsGram - newIntakeObject.totalFatsGram,
          proteinTracked: oldIntakeObject.totalProteinsGram -
              newIntakeObject.totalProteinsGram);
    } else if (newIntakeObject.amount > oldIntakeObject.amount) {
      // Amounts gained
      await _addTrackedDayUseCase.addDayCaloriesTracked(
          dateTime, newIntakeObject.totalKcal - oldIntakeObject.totalKcal);
      await _addTrackedDayUseCase.addDayMacrosTracked(dateTime,
          carbsTracked:
              newIntakeObject.totalCarbsGram - oldIntakeObject.totalCarbsGram,
          fatTracked:
              newIntakeObject.totalFatsGram - oldIntakeObject.totalFatsGram,
          proteinTracked: newIntakeObject.totalProteinsGram -
              oldIntakeObject.totalProteinsGram);
    }
    _updateDiaryPage(dateTime);
  }

  Future<void> deleteIntakeItem(IntakeEntity intakeEntity) async {
    final dateTime = DateTime.now();
    
    // Delete from local database
    await _deleteIntakeUsecase.deleteIntake(intakeEntity);
    await _addTrackedDayUseCase.removeDayCaloriesTracked(
        dateTime, intakeEntity.totalKcal);
    await _addTrackedDayUseCase.removeDayMacrosTracked(dateTime,
        carbsTracked: intakeEntity.totalCarbsGram,
        fatTracked: intakeEntity.totalFatsGram,
        proteinTracked: intakeEntity.totalProteinsGram);
    
    // Delete from HealthKit if sync is enabled
    final configData = await _getConfigUsecase.getConfig();
    if (configData.appleHealthSyncEnabled) {
      try {
        await _appleHealthService.deleteIntakeFromHealthKit(
          intakeEntity.id,
          intakeEntity.dateTime,
          intakeEntity.totalKcal,
          intakeEntity.meal.name ?? 'Meal',
        );
      } catch (e) {
        log.warning('Failed to delete intake from HealthKit: $e');
      }
    }
    
    _updateDiaryPage(dateTime);
  }

  Future<void> deleteUserActivityItem(UserActivityEntity activityEntity) async {
    final dateTime = DateTime.now();
    await _deleteUserActivityUsecase.deleteUserActivity(activityEntity);
    _addTrackedDayUseCase.reduceDayCalorieGoal(
        dateTime, activityEntity.burnedKcal);

    final carbsAmount = MacroCalc.getTotalCarbsGoal(activityEntity.burnedKcal);
    final fatAmount = MacroCalc.getTotalFatsGoal(activityEntity.burnedKcal);
    final proteinAmount =
        MacroCalc.getTotalProteinsGoal(activityEntity.burnedKcal);

    _addTrackedDayUseCase.reduceDayMacroGoals(dateTime,
        carbsAmount: carbsAmount,
        fatAmount: fatAmount,
        proteinAmount: proteinAmount);
    _updateDiaryPage(dateTime);
  }

  Future<void> _updateDiaryPage(DateTime day) async {
    locator<DiaryBloc>().add(const LoadDiaryYearEvent());
    locator<CalendarDayBloc>().add(RefreshCalendarDayEvent());
  }
}
