import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:calorieai/core/data/dbo/app_theme_dbo.dart';
import 'package:calorieai/core/domain/entity/config_entity.dart';

part 'config_dbo.g.dart';

@HiveType(typeId: 13)
@JsonSerializable() // Used for exporting to JSON
class ConfigDBO extends HiveObject {
  @HiveField(0)
  bool? hasAcceptedDisclaimer;
  @HiveField(1)
  bool? hasAcceptedPolicy;
  @HiveField(2)
  bool? hasAcceptedSendAnonymousData;
  @HiveField(3)
  AppThemeDBO selectedAppTheme;
  @HiveField(4)
  bool? usesImperialUnits;
  @HiveField(5)
  double? userKcalAdjustment;
  @HiveField(6)
  double? userCarbGoalPct;
  @HiveField(7)
  double? userProteinGoalPct;
  @HiveField(8)
  double? userFatGoalPct;
  @HiveField(9)
  bool? foodTrackingNotificationsEnabled;
  @HiveField(10)
  String? bmrFormula;
  @HiveField(11)
  bool? appleHealthSyncEnabled;
  @HiveField(12)
  bool? appleHealthActivitySyncEnabled;
  @HiveField(13)
  int? lastStepsCount;
  @HiveField(14)
  DateTime? lastStepsUpdateDate;
  @HiveField(15)
  bool? showConsumedKcalAndMacros;
  @HiveField(16)
  DateTime? lastHealthKitSyncTimestamp;
  @HiveField(17)
  bool? synologyHealthSyncEnabled;
  @HiveField(18)
  DateTime? synologyHealthHistoricSyncedAt;

  ConfigDBO(
      {this.hasAcceptedDisclaimer = false,
      this.hasAcceptedPolicy = false,
      this.hasAcceptedSendAnonymousData = false,
      required this.selectedAppTheme,
      this.usesImperialUnits = false,
      this.userKcalAdjustment,
      this.userCarbGoalPct,
      this.userProteinGoalPct,
      this.userFatGoalPct,
      this.foodTrackingNotificationsEnabled,
      this.bmrFormula,
      this.appleHealthSyncEnabled,
      this.appleHealthActivitySyncEnabled,
      this.lastStepsCount,
      this.lastStepsUpdateDate,
      this.showConsumedKcalAndMacros = false,
      this.lastHealthKitSyncTimestamp,
      this.synologyHealthSyncEnabled = false,
      this.synologyHealthHistoricSyncedAt});

  factory ConfigDBO.empty() =>
      ConfigDBO(selectedAppTheme: AppThemeDBO.system);

  factory ConfigDBO.fromConfigEntity(ConfigEntity entity) => ConfigDBO(
      hasAcceptedDisclaimer: entity.hasAcceptedDisclaimer,
      hasAcceptedPolicy: entity.hasAcceptedPolicy,
      hasAcceptedSendAnonymousData: entity.hasAcceptedSendAnonymousData,
      selectedAppTheme: AppThemeDBO.fromAppThemeEntity(entity.appTheme),
      usesImperialUnits: entity.usesImperialUnits,
      userKcalAdjustment: entity.userKcalAdjustment,
      userCarbGoalPct: entity.userCarbGoalPct,
      userProteinGoalPct: entity.userProteinGoalPct,
      userFatGoalPct: entity.userFatGoalPct,
      foodTrackingNotificationsEnabled: entity.foodTrackingNotificationsEnabled,
      bmrFormula: entity.bmrFormulaString,
      appleHealthSyncEnabled: entity.appleHealthSyncEnabled,
      appleHealthActivitySyncEnabled: entity.appleHealthActivitySyncEnabled,
      lastStepsCount: entity.lastStepsCount,
      lastStepsUpdateDate: entity.lastStepsUpdateDate,
      showConsumedKcalAndMacros: entity.showConsumedKcalAndMacros,
      lastHealthKitSyncTimestamp: entity.lastHealthKitSyncTimestamp,
      synologyHealthSyncEnabled: entity.synologyHealthSyncEnabled,
      synologyHealthHistoricSyncedAt: entity.synologyHealthHistoricSyncedAt);

  factory ConfigDBO.fromJson(Map<String, dynamic> json) =>
      _$ConfigDBOFromJson(json);

  Map<String, dynamic> toJson() => _$ConfigDBOToJson(this);
}
