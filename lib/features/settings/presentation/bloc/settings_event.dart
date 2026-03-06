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
