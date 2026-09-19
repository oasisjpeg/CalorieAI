import 'package:calorieai/core/data/data_source/config_data_source.dart';
import 'package:calorieai/core/data/dbo/app_theme_dbo.dart';
import 'package:calorieai/core/data/dbo/config_dbo.dart';
import 'package:calorieai/core/domain/entity/app_theme_entity.dart';
import 'package:calorieai/core/domain/entity/config_entity.dart';
import 'package:calorieai/core/utils/calc/modern_tdee_calc.dart';

class ConfigRepository {
  final ConfigDataSource _configDataSource;

  ConfigRepository(this._configDataSource);

  Future<void> updateConfig(ConfigEntity configEntity) async {
    final configDBO = ConfigDBO.fromConfigEntity(configEntity);
    _configDataSource.addConfig(configDBO);
  }

  Future<void> setConfigDisclaimer(bool hasAcceptedDisclaimer) async {
    _configDataSource.setConfigDisclaimer(hasAcceptedDisclaimer);
  }

  Future<void> setConfigHasAcceptedAnonymousData(
      bool hasAcceptedAnonymousData) async {
    _configDataSource.setConfigAcceptedAnonymousData(hasAcceptedAnonymousData);
  }

  Future<bool> getConfigHasAcceptedAnonymousData() async {
    return await _configDataSource.getHasAcceptedAnonymousData();
  }

  Future<AppThemeEntity> getConfigAppTheme() async {
    final appThemeDBO = await _configDataSource.getAppTheme();
    return AppThemeEntity.fromAppThemeDBO(appThemeDBO);
  }

  Future<void> setConfigAppTheme(AppThemeEntity appTheme) async {
    await _configDataSource
        .setConfigAppTheme(AppThemeDBO.fromAppThemeEntity(appTheme));
  }

  Future<ConfigEntity> getConfig() async {
    final configDBO = await _configDataSource.getConfig();
    return ConfigEntity.fromConfigDBO(configDBO);
  }

  Future<ConfigDBO> getConfigDBO() async {
    final configDBO = await _configDataSource.getConfig();
    return configDBO;
  }
  Future<void> setConfigUsesImperialUnits(bool usesImperialUnits) async {
    _configDataSource.setConfigUsesImperialUnits(usesImperialUnits);
  }

  Future<double> getConfigKcalAdjustment() async {
    return await _configDataSource.getKcalAdjustment();
  }

  Future<void> setConfigKcalAdjustment(double kcalAdjustment) async {
    _configDataSource.setConfigKcalAdjustment(kcalAdjustment);
  }

  Future<void> setUserMacroPct(double carbs, double protein, double fat) async {
    _configDataSource.setConfigCarbGoalPct(carbs);
    _configDataSource.setConfigProteinGoalPct(protein);
    _configDataSource.setConfigFatGoalPct(fat);
  }

  Future<bool> getFoodTrackingNotificationsEnabled() async {
    return await _configDataSource.getFoodTrackingNotificationsEnabled();
  }

  Future<void> setFoodTrackingNotificationsEnabled(bool enabled) async {
    await _configDataSource.setFoodTrackingNotificationsEnabled(enabled);
  }

  Future<void> setConfigBMRFormula(BMRFormula formula) async {
    String formulaString;
    switch (formula) {
      case BMRFormula.mifflinStJeor:
        formulaString = 'mifflinStJeor';
        break;
      case BMRFormula.harrisBenedictRevised:
        formulaString = 'harrisBenedictRevised';
        break;
      case BMRFormula.katchMcArdle:
        formulaString = 'katchMcArdle';
        break;
    }
    await _configDataSource.setConfigBMRFormula(formulaString);
  }

  Future<bool> getAppleHealthSyncEnabled() async {
    return await _configDataSource.getAppleHealthSyncEnabled();
  }

  Future<void> setAppleHealthSyncEnabled(bool enabled) async {
    await _configDataSource.setAppleHealthSyncEnabled(enabled);
  }

  Future<bool> getAppleHealthActivitySyncEnabled() async {
    return await _configDataSource.getAppleHealthActivitySyncEnabled();
  }

  Future<void> setAppleHealthActivitySyncEnabled(bool enabled) async {
    await _configDataSource.setAppleHealthActivitySyncEnabled(enabled);
  }

  Future<void> setLastSteps(int stepsCount, DateTime? updateDate) async {
    await _configDataSource.setLastSteps(stepsCount, updateDate);
  }

  Future<void> clearLastSteps() async {
    await _configDataSource.clearLastSteps();
  }

  Future<bool> getSynologyHealthSyncEnabled() async {
    return await _configDataSource.getSynologyHealthSyncEnabled();
  }

  Future<void> setSynologyHealthSyncEnabled(bool enabled) async {
    await _configDataSource.setSynologyHealthSyncEnabled(enabled);
  }

  Future<DateTime?> getSynologyHealthHistoricSyncedAt() async {
    return await _configDataSource.getSynologyHealthHistoricSyncedAt();
  }

  Future<void> setSynologyHealthHistoricSyncedAt(DateTime? timestamp) async {
    await _configDataSource.setSynologyHealthHistoricSyncedAt(timestamp);
  }

  Future<bool> getShowConsumedKcalAndMacros() async {
    return await _configDataSource.getShowConsumedKcalAndMacros();
  }

  Future<void> setShowConsumedKcalAndMacros(bool showConsumed) async {
    await _configDataSource.setShowConsumedKcalAndMacros(showConsumed);
  }

  Future<DateTime?> getLastHealthKitSyncTimestamp() async {
    return await _configDataSource.getLastHealthKitSyncTimestamp();
  }

  Future<void> setLastHealthKitSyncTimestamp(DateTime? timestamp) async {
    await _configDataSource.setLastHealthKitSyncTimestamp(timestamp);
  }
}
