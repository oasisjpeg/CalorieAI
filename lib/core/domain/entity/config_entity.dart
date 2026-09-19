import 'package:equatable/equatable.dart';
import 'package:calorieai/core/data/dbo/config_dbo.dart';
import 'package:calorieai/core/domain/entity/app_theme_entity.dart';
import 'package:calorieai/core/utils/calc/modern_tdee_calc.dart';

class ConfigEntity extends Equatable {
  final bool hasAcceptedDisclaimer;
  final bool hasAcceptedPolicy;
  final bool hasAcceptedSendAnonymousData;
  final AppThemeEntity appTheme;
  final bool usesImperialUnits;
  final double? userKcalAdjustment;
  final double? userCarbGoalPct;
  final double? userProteinGoalPct;
  final double? userFatGoalPct;
  final bool foodTrackingNotificationsEnabled;
  final BMRFormula? bmrFormula;
  final bool appleHealthSyncEnabled;
  final bool appleHealthActivitySyncEnabled;
  final int lastStepsCount;
  final DateTime? lastStepsUpdateDate;
  final bool showConsumedKcalAndMacros;
  final DateTime? lastHealthKitSyncTimestamp;
  final bool synologyHealthSyncEnabled;
  final DateTime? synologyHealthHistoricSyncedAt;

  const ConfigEntity(this.hasAcceptedDisclaimer, this.hasAcceptedPolicy,
      this.hasAcceptedSendAnonymousData, this.appTheme,
      {this.usesImperialUnits = false,
      this.userKcalAdjustment,
      this.userCarbGoalPct,
      this.userProteinGoalPct,
      this.userFatGoalPct,
      this.foodTrackingNotificationsEnabled = true,
      this.bmrFormula,
      this.appleHealthSyncEnabled = false,
      this.appleHealthActivitySyncEnabled = false,
      this.lastStepsCount = 0,
      this.lastStepsUpdateDate,
      this.showConsumedKcalAndMacros = false,
      this.lastHealthKitSyncTimestamp,
      this.synologyHealthSyncEnabled = false,
      this.synologyHealthHistoricSyncedAt});

  factory ConfigEntity.fromConfigDBO(ConfigDBO dbo) => ConfigEntity(
        dbo.hasAcceptedDisclaimer ?? false,
        dbo.hasAcceptedPolicy ?? false,
        dbo.hasAcceptedSendAnonymousData ?? false,
        AppThemeEntity.fromAppThemeDBO(dbo.selectedAppTheme),
        usesImperialUnits: dbo.usesImperialUnits ?? false,
        userKcalAdjustment: dbo.userKcalAdjustment,
        userCarbGoalPct: dbo.userCarbGoalPct,
        userProteinGoalPct: dbo.userProteinGoalPct,
        userFatGoalPct: dbo.userFatGoalPct,
        foodTrackingNotificationsEnabled: dbo.foodTrackingNotificationsEnabled ?? true,
        bmrFormula: _parseBMRFormula(dbo.bmrFormula),
        appleHealthSyncEnabled: dbo.appleHealthSyncEnabled ?? false,
        appleHealthActivitySyncEnabled: dbo.appleHealthActivitySyncEnabled ?? false,
        lastStepsCount: dbo.lastStepsCount ?? 0,
        lastStepsUpdateDate: dbo.lastStepsUpdateDate,
        showConsumedKcalAndMacros: dbo.showConsumedKcalAndMacros ?? false,
        lastHealthKitSyncTimestamp: dbo.lastHealthKitSyncTimestamp,
        synologyHealthSyncEnabled: dbo.synologyHealthSyncEnabled ?? false,
        synologyHealthHistoricSyncedAt: dbo.synologyHealthHistoricSyncedAt,
      );

  static BMRFormula? _parseBMRFormula(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'mifflinStJeor':
        return BMRFormula.mifflinStJeor;
      case 'harrisBenedictRevised':
        return BMRFormula.harrisBenedictRevised;
      case 'katchMcArdle':
        return BMRFormula.katchMcArdle;
      default:
        return null;
    }
  }

  String? get bmrFormulaString {
    switch (bmrFormula) {
      case BMRFormula.mifflinStJeor:
        return 'mifflinStJeor';
      case BMRFormula.harrisBenedictRevised:
        return 'harrisBenedictRevised';
      case BMRFormula.katchMcArdle:
        return 'katchMcArdle';
      case null:
        return null;
    }
  }

  ConfigEntity copyWith({
    bool? hasAcceptedDisclaimer,
    bool? hasAcceptedPolicy,
    bool? hasAcceptedSendAnonymousData,
    AppThemeEntity? appTheme,
    bool? usesImperialUnits,
    double? userKcalAdjustment,
    double? userCarbGoalPct,
    double? userProteinGoalPct,
    double? userFatGoalPct,
    bool? foodTrackingNotificationsEnabled,
    BMRFormula? bmrFormula,
    bool? appleHealthSyncEnabled,
    bool? appleHealthActivitySyncEnabled,
    int? lastStepsCount,
    DateTime? lastStepsUpdateDate,
    bool? showConsumedKcalAndMacros,
    DateTime? lastHealthKitSyncTimestamp,
    bool? synologyHealthSyncEnabled,
    DateTime? synologyHealthHistoricSyncedAt,
  }) {
    return ConfigEntity(
      hasAcceptedDisclaimer ?? this.hasAcceptedDisclaimer,
      hasAcceptedPolicy ?? this.hasAcceptedPolicy,
      hasAcceptedSendAnonymousData ?? this.hasAcceptedSendAnonymousData,
      appTheme ?? this.appTheme,
      usesImperialUnits: usesImperialUnits ?? this.usesImperialUnits,
      userKcalAdjustment: userKcalAdjustment ?? this.userKcalAdjustment,
      userCarbGoalPct: userCarbGoalPct ?? this.userCarbGoalPct,
      userProteinGoalPct: userProteinGoalPct ?? this.userProteinGoalPct,
      userFatGoalPct: userFatGoalPct ?? this.userFatGoalPct,
      foodTrackingNotificationsEnabled: foodTrackingNotificationsEnabled ?? this.foodTrackingNotificationsEnabled,
      bmrFormula: bmrFormula ?? this.bmrFormula,
      appleHealthSyncEnabled: appleHealthSyncEnabled ?? this.appleHealthSyncEnabled,
      appleHealthActivitySyncEnabled: appleHealthActivitySyncEnabled ?? this.appleHealthActivitySyncEnabled,
      lastStepsCount: lastStepsCount ?? this.lastStepsCount,
      lastStepsUpdateDate: lastStepsUpdateDate ?? this.lastStepsUpdateDate,
      showConsumedKcalAndMacros:
          showConsumedKcalAndMacros ?? this.showConsumedKcalAndMacros,
      lastHealthKitSyncTimestamp: lastHealthKitSyncTimestamp ?? this.lastHealthKitSyncTimestamp,
      synologyHealthSyncEnabled: synologyHealthSyncEnabled ?? this.synologyHealthSyncEnabled,
      synologyHealthHistoricSyncedAt: synologyHealthHistoricSyncedAt ?? this.synologyHealthHistoricSyncedAt,
    );
  }

  @override
  List<Object?> get props => [
        hasAcceptedDisclaimer,
        hasAcceptedPolicy,
        hasAcceptedSendAnonymousData,
        usesImperialUnits,
        userKcalAdjustment,
        userCarbGoalPct,
        userProteinGoalPct,
        userFatGoalPct,
        foodTrackingNotificationsEnabled,
        bmrFormula,
        appleHealthSyncEnabled,
        appleHealthActivitySyncEnabled,
        lastStepsCount,
        lastStepsUpdateDate,
        showConsumedKcalAndMacros,
        lastHealthKitSyncTimestamp,
        synologyHealthSyncEnabled,
        synologyHealthHistoricSyncedAt,
      ];
}
