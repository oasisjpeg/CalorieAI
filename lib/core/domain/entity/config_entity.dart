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

  const ConfigEntity(this.hasAcceptedDisclaimer, this.hasAcceptedPolicy,
      this.hasAcceptedSendAnonymousData, this.appTheme,
      {this.usesImperialUnits = false,
      this.userKcalAdjustment,
      this.userCarbGoalPct,
      this.userProteinGoalPct,
      this.userFatGoalPct,
      this.foodTrackingNotificationsEnabled = true,
      this.bmrFormula});

  factory ConfigEntity.fromConfigDBO(ConfigDBO dbo) => ConfigEntity(
        dbo.hasAcceptedDisclaimer,
        dbo.hasAcceptedPolicy,
        dbo.hasAcceptedSendAnonymousData,
        AppThemeEntity.fromAppThemeDBO(dbo.selectedAppTheme),
        usesImperialUnits: dbo.usesImperialUnits ?? false,
        userKcalAdjustment: dbo.userKcalAdjustment,
        userCarbGoalPct: dbo.userCarbGoalPct,
        userProteinGoalPct: dbo.userProteinGoalPct,
        userFatGoalPct: dbo.userFatGoalPct,
        foodTrackingNotificationsEnabled: dbo.foodTrackingNotificationsEnabled ?? true,
        bmrFormula: _parseBMRFormula(dbo.bmrFormula),
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
      ];
}
