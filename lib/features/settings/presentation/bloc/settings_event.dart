part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
}

class LoadSettingsEvent extends SettingsEvent {
  @override
  List<Object?> get props => [];
}

class ToggleFoodTrackingNotificationsEvent extends SettingsEvent {
  final bool enabled;

  const ToggleFoodTrackingNotificationsEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class ToggleConsumedDashboardModeEvent extends SettingsEvent {
  final bool enabled;

  const ToggleConsumedDashboardModeEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class ToggleAppleHealthSyncEvent extends SettingsEvent {
  final bool enabled;

  const ToggleAppleHealthSyncEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class ToggleAppleHealthActivitySyncEvent extends SettingsEvent {
  final bool enabled;

  const ToggleAppleHealthActivitySyncEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class ResyncAppleHealthIntakesEvent extends SettingsEvent {
  @override
  List<Object?> get props => [];
}

class ResyncSynologyHealthEvent extends SettingsEvent {
  @override
  List<Object?> get props => [];
}

class ToggleSynologyHealthSyncEvent extends SettingsEvent {
  final bool enabled;

  const ToggleSynologyHealthSyncEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}
