// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_dbo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConfigDBOAdapter extends TypeAdapter<ConfigDBO> {
  @override
  final int typeId = 13;

  @override
  ConfigDBO read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConfigDBO(
      hasAcceptedDisclaimer: fields[0] as bool?,
      hasAcceptedPolicy: fields[1] as bool?,
      hasAcceptedSendAnonymousData: fields[2] as bool?,
      selectedAppTheme: fields[3] as AppThemeDBO,
      usesImperialUnits: fields[4] as bool?,
      userKcalAdjustment: fields[5] as double?,
      userCarbGoalPct: fields[6] as double?,
      userProteinGoalPct: fields[7] as double?,
      userFatGoalPct: fields[8] as double?,
      foodTrackingNotificationsEnabled: fields[9] as bool?,
      bmrFormula: fields[10] as String?,
      appleHealthSyncEnabled: fields[11] as bool?,
      appleHealthActivitySyncEnabled: fields[12] as bool?,
      lastStepsCount: fields[13] as int?,
      lastStepsUpdateDate: fields[14] as DateTime?,
      showConsumedKcalAndMacros: fields[15] as bool?,
      lastHealthKitSyncTimestamp: fields[16] as DateTime?,
      synologyHealthSyncEnabled: fields[17] as bool?,
      synologyHealthHistoricSyncedAt: fields[18] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ConfigDBO obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.hasAcceptedDisclaimer)
      ..writeByte(1)
      ..write(obj.hasAcceptedPolicy)
      ..writeByte(2)
      ..write(obj.hasAcceptedSendAnonymousData)
      ..writeByte(3)
      ..write(obj.selectedAppTheme)
      ..writeByte(4)
      ..write(obj.usesImperialUnits)
      ..writeByte(5)
      ..write(obj.userKcalAdjustment)
      ..writeByte(6)
      ..write(obj.userCarbGoalPct)
      ..writeByte(7)
      ..write(obj.userProteinGoalPct)
      ..writeByte(8)
      ..write(obj.userFatGoalPct)
      ..writeByte(9)
      ..write(obj.foodTrackingNotificationsEnabled)
      ..writeByte(10)
      ..write(obj.bmrFormula)
      ..writeByte(11)
      ..write(obj.appleHealthSyncEnabled)
      ..writeByte(12)
      ..write(obj.appleHealthActivitySyncEnabled)
      ..writeByte(13)
      ..write(obj.lastStepsCount)
      ..writeByte(14)
      ..write(obj.lastStepsUpdateDate)
      ..writeByte(15)
      ..write(obj.showConsumedKcalAndMacros)
      ..writeByte(16)
      ..write(obj.lastHealthKitSyncTimestamp)
      ..writeByte(17)
      ..write(obj.synologyHealthSyncEnabled)
      ..writeByte(18)
      ..write(obj.synologyHealthHistoricSyncedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigDBOAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConfigDBO _$ConfigDBOFromJson(Map<String, dynamic> json) => ConfigDBO(
      hasAcceptedDisclaimer: json['hasAcceptedDisclaimer'] as bool? ?? false,
      hasAcceptedPolicy: json['hasAcceptedPolicy'] as bool? ?? false,
      hasAcceptedSendAnonymousData:
          json['hasAcceptedSendAnonymousData'] as bool? ?? false,
      selectedAppTheme:
          $enumDecode(_$AppThemeDBOEnumMap, json['selectedAppTheme']),
      usesImperialUnits: json['usesImperialUnits'] as bool? ?? false,
      userKcalAdjustment: (json['userKcalAdjustment'] as num?)?.toDouble(),
      userCarbGoalPct: (json['userCarbGoalPct'] as num?)?.toDouble(),
      userProteinGoalPct: (json['userProteinGoalPct'] as num?)?.toDouble(),
      userFatGoalPct: (json['userFatGoalPct'] as num?)?.toDouble(),
      foodTrackingNotificationsEnabled:
          json['foodTrackingNotificationsEnabled'] as bool?,
      bmrFormula: json['bmrFormula'] as String?,
      appleHealthSyncEnabled: json['appleHealthSyncEnabled'] as bool?,
      appleHealthActivitySyncEnabled:
          json['appleHealthActivitySyncEnabled'] as bool?,
      lastStepsCount: (json['lastStepsCount'] as num?)?.toInt(),
      lastStepsUpdateDate: json['lastStepsUpdateDate'] == null
          ? null
          : DateTime.parse(json['lastStepsUpdateDate'] as String),
      showConsumedKcalAndMacros:
          json['showConsumedKcalAndMacros'] as bool? ?? false,
      lastHealthKitSyncTimestamp: json['lastHealthKitSyncTimestamp'] == null
          ? null
          : DateTime.parse(json['lastHealthKitSyncTimestamp'] as String),
      synologyHealthSyncEnabled:
          json['synologyHealthSyncEnabled'] as bool? ?? false,
      synologyHealthHistoricSyncedAt: json['synologyHealthHistoricSyncedAt'] ==
              null
          ? null
          : DateTime.parse(json['synologyHealthHistoricSyncedAt'] as String),
    );

Map<String, dynamic> _$ConfigDBOToJson(ConfigDBO instance) => <String, dynamic>{
      'hasAcceptedDisclaimer': instance.hasAcceptedDisclaimer,
      'hasAcceptedPolicy': instance.hasAcceptedPolicy,
      'hasAcceptedSendAnonymousData': instance.hasAcceptedSendAnonymousData,
      'selectedAppTheme': _$AppThemeDBOEnumMap[instance.selectedAppTheme]!,
      'usesImperialUnits': instance.usesImperialUnits,
      'userKcalAdjustment': instance.userKcalAdjustment,
      'userCarbGoalPct': instance.userCarbGoalPct,
      'userProteinGoalPct': instance.userProteinGoalPct,
      'userFatGoalPct': instance.userFatGoalPct,
      'foodTrackingNotificationsEnabled':
          instance.foodTrackingNotificationsEnabled,
      'bmrFormula': instance.bmrFormula,
      'appleHealthSyncEnabled': instance.appleHealthSyncEnabled,
      'appleHealthActivitySyncEnabled': instance.appleHealthActivitySyncEnabled,
      'lastStepsCount': instance.lastStepsCount,
      'lastStepsUpdateDate': instance.lastStepsUpdateDate?.toIso8601String(),
      'showConsumedKcalAndMacros': instance.showConsumedKcalAndMacros,
      'lastHealthKitSyncTimestamp':
          instance.lastHealthKitSyncTimestamp?.toIso8601String(),
      'synologyHealthSyncEnabled': instance.synologyHealthSyncEnabled,
      'synologyHealthHistoricSyncedAt':
          instance.synologyHealthHistoricSyncedAt?.toIso8601String(),
    };

const _$AppThemeDBOEnumMap = {
  AppThemeDBO.light: 'light',
  AppThemeDBO.dark: 'dark',
  AppThemeDBO.system: 'system',
};
