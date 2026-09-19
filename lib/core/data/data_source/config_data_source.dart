import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';
import 'package:calorieai/core/data/dbo/app_theme_dbo.dart';
import 'package:calorieai/core/data/dbo/config_dbo.dart';

class ConfigDataSource {
  static const _configKey = "ConfigKey";

  final _log = Logger('ConfigDataSource');
  final Box<ConfigDBO> _configBox;

  ConfigDataSource(this._configBox);

  Future<bool> configInitialized() async => _configBox.containsKey(_configKey);

  Future<void> initializeConfig() async =>
      _configBox.put(_configKey, ConfigDBO.empty());

  Future<void> addConfig(ConfigDBO configDBO) async {
    _log.fine('Adding new config item to db');
    _configBox.put(_configKey, configDBO);
  }

  Future<void> setConfigDisclaimer(bool hasAcceptedDisclaimer) async {
    _log.fine(
        'Updating config hasAcceptedDisclaimer to $hasAcceptedDisclaimer');
    final config = _configBox.get(_configKey);
    config?.hasAcceptedDisclaimer = hasAcceptedDisclaimer;
    config?.save();
  }

  Future<void> setConfigAcceptedAnonymousData(
      bool hasAcceptedAnonymousData) async {
    _log.fine(
        'Updating config hasAcceptedAnonymousData to $hasAcceptedAnonymousData');
    final config = _configBox.get(_configKey);
    config?.hasAcceptedSendAnonymousData = hasAcceptedAnonymousData;
    config?.save();
  }

  Future<AppThemeDBO> getAppTheme() async {
    final config = _configBox.get(_configKey);
    return config?.selectedAppTheme ?? AppThemeDBO.defaultTheme;
  }

  Future<void> setConfigAppTheme(AppThemeDBO appTheme) async {
    _log.fine('Updating config appTheme to $appTheme');
    final config = _configBox.get(_configKey);
    config?.selectedAppTheme = appTheme;
    config?.save();
  }

  Future<void> setConfigUsesImperialUnits(bool usesImperialUnits) async {
    _log.fine('Updating config usesImperialUnits to $usesImperialUnits');
    final config = _configBox.get(_configKey);
    config?.usesImperialUnits = usesImperialUnits;
    config?.save();
  }

  Future<double> getKcalAdjustment() async {
    final config = _configBox.get(_configKey);
    return config?.userKcalAdjustment ?? 0;
  }

  Future<void> setConfigKcalAdjustment(double kcalAdjustment) async {
    _log.fine('Updating config kcalAdjustment to $kcalAdjustment');
    final config = _configBox.get(_configKey);
    config?.userKcalAdjustment = kcalAdjustment;
    config?.save();
  }

  Future<void> setConfigCarbGoalPct(double carbGoalPct) async {
    _log.fine('Updating config carbGoalPct to $carbGoalPct');
    final config = _configBox.get(_configKey);
    config?.userCarbGoalPct = carbGoalPct;
    config?.save();
  }

  Future<void> setConfigProteinGoalPct(double proteinGoalPct) async {
    _log.fine('Updating config proteinGoalPct to $proteinGoalPct');
    final config = _configBox.get(_configKey);
    config?.userProteinGoalPct = proteinGoalPct;
    config?.save();
  }

  Future<void> setConfigFatGoalPct(double fatGoalPct) async {
    _log.fine('Updating config fatGoalPct to $fatGoalPct');
    final config = _configBox.get(_configKey);
    config?.userFatGoalPct = fatGoalPct;
    config?.save();
  }

  Future<ConfigDBO> getConfig() async {
    return _configBox.get(_configKey) ?? ConfigDBO.empty();
  }

  Future<bool> getHasAcceptedAnonymousData() async {
    final config = _configBox.get(_configKey);
    return config?.hasAcceptedSendAnonymousData ?? false;
  }

  Future<bool> getFoodTrackingNotificationsEnabled() async {
    final config = _configBox.get(_configKey);
    // Default to true if not set (existing users)
    return config?.foodTrackingNotificationsEnabled ?? true;
  }

  Future<void> setFoodTrackingNotificationsEnabled(bool enabled) async {
    _log.fine('Updating config foodTrackingNotificationsEnabled to $enabled');
    final config = _configBox.get(_configKey);
    config?.foodTrackingNotificationsEnabled = enabled;
    config?.save();
  }

  Future<void> setConfigBMRFormula(String formulaString) async {
    _log.fine('Updating config bmrFormula to $formulaString');
    final config = _configBox.get(_configKey);
    config?.bmrFormula = formulaString;
    config?.save();
  }

  Future<bool> getAppleHealthSyncEnabled() async {
    final config = _configBox.get(_configKey);
    return config?.appleHealthSyncEnabled ?? false;
  }

  Future<void> setAppleHealthSyncEnabled(bool enabled) async {
    _log.fine('Updating config appleHealthSyncEnabled to $enabled');
    final config = _configBox.get(_configKey);
    config?.appleHealthSyncEnabled = enabled;
    config?.save();
  }

  Future<bool> getAppleHealthActivitySyncEnabled() async {
    final config = _configBox.get(_configKey);
    return config?.appleHealthActivitySyncEnabled ?? false;
  }

  Future<void> setAppleHealthActivitySyncEnabled(bool enabled) async {
    _log.fine('Updating config appleHealthActivitySyncEnabled to $enabled');
    final config = _configBox.get(_configKey);
    config?.appleHealthActivitySyncEnabled = enabled;
    config?.save();
  }

  Future<void> setLastSteps(int stepsCount, DateTime? updateDate) async {
    _log.fine('Updating config lastStepsCount to $stepsCount, lastStepsUpdateDate to $updateDate');
    final config = _configBox.get(_configKey);
    config?.lastStepsCount = stepsCount;
    config?.lastStepsUpdateDate = updateDate;
    config?.save();
  }

  Future<void> clearLastSteps() async {
    _log.fine('Clearing config lastStepsCount and lastStepsUpdateDate');
    final config = _configBox.get(_configKey);
    config?.lastStepsCount = 0;
    config?.lastStepsUpdateDate = null;
    config?.save();
  }

  Future<DateTime?> getLastHealthKitSyncTimestamp() async {
    final config = _configBox.get(_configKey);
    return config?.lastHealthKitSyncTimestamp;
  }

  Future<void> setLastHealthKitSyncTimestamp(DateTime? timestamp) async {
    _log.fine('Updating lastHealthKitSyncTimestamp to $timestamp');
    final config = _configBox.get(_configKey);
    config?.lastHealthKitSyncTimestamp = timestamp;
    config?.save();
  }

  Future<bool> getSynologyHealthSyncEnabled() async {
    final config = _configBox.get(_configKey);
    return config?.synologyHealthSyncEnabled ?? false;
  }

  Future<void> setSynologyHealthSyncEnabled(bool enabled) async {
    _log.fine('Updating config synologyHealthSyncEnabled to $enabled');
    final config = _configBox.get(_configKey);
    config?.synologyHealthSyncEnabled = enabled;
    config?.save();
  }

  Future<DateTime?> getSynologyHealthHistoricSyncedAt() async {
    final config = _configBox.get(_configKey);
    return config?.synologyHealthHistoricSyncedAt;
  }

  Future<void> setSynologyHealthHistoricSyncedAt(DateTime? timestamp) async {
    _log.fine('Updating config synologyHealthHistoricSyncedAt to $timestamp');
    final config = _configBox.get(_configKey);
    config?.synologyHealthHistoricSyncedAt = timestamp;
    config?.save();
  }

  Future<bool> getShowConsumedKcalAndMacros() async {
    final config = _configBox.get(_configKey);
    return config?.showConsumedKcalAndMacros ?? false;
  }

  Future<void> setShowConsumedKcalAndMacros(bool showConsumed) async {
    _log.fine('Updating config showConsumedKcalAndMacros to $showConsumed');
    final config = _configBox.get(_configKey);
    config?.showConsumedKcalAndMacros = showConsumed;
    config?.save();
  }
}
