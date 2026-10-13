part of 'settings_bloc.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();
}

class SettingsInitial extends SettingsState {
  @override
  List<Object> get props => [];
}

class SettingsLoadingState extends SettingsState {
  @override
  List<Object?> get props => [];
}

class SettingsLoadedState extends SettingsState {
  final String versionNumber;
  final bool sendAnonymousData;
  final AppThemeEntity appTheme;
  final bool usesImperialUnits;
  final bool isSubscribed;
  final bool foodTrackingNotificationsEnabled;
  final bool appleHealthSyncEnabled;
  final bool appleHealthActivitySyncEnabled;
  final bool showConsumedKcalAndMacros;
  final bool synologyHealthSyncEnabled;
  final DateTime? synologyHealthHistoricSyncedAt;
  final bool synologyServerReachable;
  final bool showWeightShortcut;
  final bool showWaterShortcut;
  final bool showStepsShortcut;

  const SettingsLoadedState(
    this.versionNumber,
    this.sendAnonymousData,
    this.appTheme,
    this.usesImperialUnits, {
    this.isSubscribed = false,
    this.foodTrackingNotificationsEnabled = true,
    this.appleHealthSyncEnabled = false,
    this.appleHealthActivitySyncEnabled = false,
    this.showConsumedKcalAndMacros = false,
    this.synologyHealthSyncEnabled = false,
    this.synologyHealthHistoricSyncedAt,
    this.synologyServerReachable = true,
    this.showWeightShortcut = true,
    this.showWaterShortcut = true,
    this.showStepsShortcut = true,
  });

  SettingsLoadedState copyWith({
    String? versionNumber,
    bool? sendAnonymousData,
    AppThemeEntity? appTheme,
    bool? usesImperialUnits,
    bool? isSubscribed,
    bool? foodTrackingNotificationsEnabled,
    bool? appleHealthSyncEnabled,
    bool? appleHealthActivitySyncEnabled,
    bool? showConsumedKcalAndMacros,
    bool? synologyHealthSyncEnabled,
    DateTime? synologyHealthHistoricSyncedAt,
    bool? synologyServerReachable,
    bool? showWeightShortcut,
    bool? showWaterShortcut,
    bool? showStepsShortcut,
  }) {
    return SettingsLoadedState(
      versionNumber ?? this.versionNumber,
      sendAnonymousData ?? this.sendAnonymousData,
      appTheme ?? this.appTheme,
      usesImperialUnits ?? this.usesImperialUnits,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      foodTrackingNotificationsEnabled: foodTrackingNotificationsEnabled ?? this.foodTrackingNotificationsEnabled,
      appleHealthSyncEnabled: appleHealthSyncEnabled ?? this.appleHealthSyncEnabled,
      appleHealthActivitySyncEnabled: appleHealthActivitySyncEnabled ?? this.appleHealthActivitySyncEnabled,
      showConsumedKcalAndMacros:
          showConsumedKcalAndMacros ?? this.showConsumedKcalAndMacros,
      synologyHealthSyncEnabled: synologyHealthSyncEnabled ?? this.synologyHealthSyncEnabled,
      synologyHealthHistoricSyncedAt: synologyHealthHistoricSyncedAt ?? this.synologyHealthHistoricSyncedAt,
      synologyServerReachable: synologyServerReachable ?? this.synologyServerReachable,
      showWeightShortcut: showWeightShortcut ?? this.showWeightShortcut,
      showWaterShortcut: showWaterShortcut ?? this.showWaterShortcut,
      showStepsShortcut: showStepsShortcut ?? this.showStepsShortcut,
    );
  }

  @override
  List<Object?> get props =>
      [versionNumber, sendAnonymousData, appTheme, usesImperialUnits, isSubscribed, foodTrackingNotificationsEnabled, appleHealthSyncEnabled, appleHealthActivitySyncEnabled, showConsumedKcalAndMacros, synologyHealthSyncEnabled, synologyHealthHistoricSyncedAt, synologyServerReachable, showWeightShortcut, showWaterShortcut, showStepsShortcut];
}
