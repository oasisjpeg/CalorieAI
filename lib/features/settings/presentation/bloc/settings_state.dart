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

  const SettingsLoadedState(
    this.versionNumber,
    this.sendAnonymousData,
    this.appTheme,
    this.usesImperialUnits, {
    this.isSubscribed = false,
  });

  SettingsLoadedState copyWith({
    String? versionNumber,
    bool? sendAnonymousData,
    AppThemeEntity? appTheme,
    bool? usesImperialUnits,
    bool? isSubscribed,
  }) {
    return SettingsLoadedState(
      versionNumber ?? this.versionNumber,
      sendAnonymousData ?? this.sendAnonymousData,
      appTheme ?? this.appTheme,
      usesImperialUnits ?? this.usesImperialUnits,
      isSubscribed: isSubscribed ?? this.isSubscribed,
    );
  }

  @override
  List<Object?> get props =>
      [versionNumber, sendAnonymousData, appTheme, usesImperialUnits, isSubscribed];
}
