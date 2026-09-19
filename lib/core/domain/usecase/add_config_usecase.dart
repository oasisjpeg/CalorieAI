import 'package:calorieai/core/data/repository/config_repository.dart';
import 'package:calorieai/core/domain/entity/app_theme_entity.dart';
import 'package:calorieai/core/domain/entity/config_entity.dart';
import 'package:calorieai/core/utils/calc/modern_tdee_calc.dart';

class AddConfigUsecase {
  final ConfigRepository _configRepository;

  AddConfigUsecase(this._configRepository);

  Future<void> addConfig(ConfigEntity configEntity) async {
    _configRepository.updateConfig(configEntity);
  }

  Future<void> setConfigDisclaimer(bool hasAcceptedDisclaimer) async {
    _configRepository.setConfigDisclaimer(hasAcceptedDisclaimer);
  }

  Future<void> setConfigHasAcceptedAnonymousData(
      bool hasAcceptedAnonymousData) async {
    _configRepository
        .setConfigHasAcceptedAnonymousData(hasAcceptedAnonymousData);
  }

  Future<void> setConfigAppTheme(AppThemeEntity appTheme) async {
    await _configRepository.setConfigAppTheme(appTheme);
  }

  Future<void> setConfigUsesImperialUnits(bool usesImperialUnits) async {
    _configRepository.setConfigUsesImperialUnits(usesImperialUnits);
  }

  Future<void> setConfigKcalAdjustment(double kcalAdjustment) async {
    _configRepository.setConfigKcalAdjustment(kcalAdjustment);
  }

  Future<void> setConfigMacroGoalPct(
      double carbGoalPct, double proteinGoalPct, double fatPctGoal) async {
    _configRepository.setUserMacroPct(carbGoalPct, proteinGoalPct, fatPctGoal);
  }

  Future<void> setFoodTrackingNotificationsEnabled(bool enabled) async {
    await _configRepository.setFoodTrackingNotificationsEnabled(enabled);
  }

  Future<void> setConfigBMRFormula(BMRFormula formula) async {
    await _configRepository.setConfigBMRFormula(formula);
  }

  Future<void> setAppleHealthSyncEnabled(bool enabled) async {
    await _configRepository.setAppleHealthSyncEnabled(enabled);
  }

  Future<void> setAppleHealthActivitySyncEnabled(bool enabled) async {
    await _configRepository.setAppleHealthActivitySyncEnabled(enabled);
  }

  Future<void> setLastSteps(int stepsCount, DateTime? updateDate) async {
    await _configRepository.setLastSteps(stepsCount, updateDate);
  }

  Future<void> clearLastSteps() async {
    await _configRepository.clearLastSteps();
  }

  Future<DateTime?> getLastHealthKitSyncTimestamp() async {
    return await _configRepository.getLastHealthKitSyncTimestamp();
  }

  Future<void> setLastHealthKitSyncTimestamp(DateTime? timestamp) async {
    await _configRepository.setLastHealthKitSyncTimestamp(timestamp);
  }

  Future<void> setShowConsumedKcalAndMacros(bool showConsumed) async {
    await _configRepository.setShowConsumedKcalAndMacros(showConsumed);
  }

  Future<void> setSynologyHealthSyncEnabled(bool enabled) async {
    await _configRepository.setSynologyHealthSyncEnabled(enabled);
  }

  Future<DateTime?> getSynologyHealthHistoricSyncedAt() async {
    return await _configRepository.getSynologyHealthHistoricSyncedAt();
  }

  Future<void> setSynologyHealthHistoricSyncedAt(DateTime? timestamp) async {
    await _configRepository.setSynologyHealthHistoricSyncedAt(timestamp);
  }
}
