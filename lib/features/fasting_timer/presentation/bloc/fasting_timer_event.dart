part of 'fasting_timer_bloc.dart';

abstract class FastingTimerEvent extends Equatable {
  const FastingTimerEvent();

  @override
  List<Object?> get props => [];
}

class LoadFastingScheduleEvent extends FastingTimerEvent {
  const LoadFastingScheduleEvent();
}

class SaveFastingScheduleEvent extends FastingTimerEvent {
  final int fastingStartHour;
  final int fastingStartMinute;
  final int fastingEndHour;
  final int fastingEndMinute;
  final bool isActive;
  final String? title;
  final FastingLocalizations localizations;

  const SaveFastingScheduleEvent({
    required this.fastingStartHour,
    required this.fastingStartMinute,
    required this.fastingEndHour,
    required this.fastingEndMinute,
    required this.isActive,
    this.title,
    required this.localizations,
  });

  @override
  List<Object?> get props => [
        fastingStartHour,
        fastingStartMinute,
        fastingEndHour,
        fastingEndMinute,
        isActive,
        title,
        localizations,
      ];
}

class ToggleFastingTimerEvent extends FastingTimerEvent {
  final FastingLocalizations localizations;

  const ToggleFastingTimerEvent({required this.localizations});

  @override
  List<Object?> get props => [localizations];
}

class DeleteFastingScheduleEvent extends FastingTimerEvent {
  const DeleteFastingScheduleEvent();
}

class UpdateTimerEvent extends FastingTimerEvent {
  const UpdateTimerEvent();
}
