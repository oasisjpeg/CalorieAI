part of 'fasting_timer_bloc.dart';

abstract class FastingTimerState extends Equatable {
  const FastingTimerState();

  @override
  List<Object?> get props => [];
}

class FastingTimerInitial extends FastingTimerState {
  const FastingTimerInitial();
}

class FastingTimerLoading extends FastingTimerState {
  const FastingTimerLoading();
}

class FastingTimerActive extends FastingTimerState {
  final FastingScheduleEntity schedule;
  final DateTime currentTime;

  const FastingTimerActive({
    required this.schedule,
    required this.currentTime,
  });

  @override
  List<Object?> get props => [schedule, currentTime];

  bool get isInFastingWindow => schedule.isCurrentlyInFastingWindow(currentTime);

  Duration get remainingTime {
    if (isInFastingWindow) {
      final end = schedule.getNextEatingStart(currentTime);
      return end.difference(currentTime);
    } else {
      final start = schedule.getNextFastingStart(currentTime);
      return start.difference(currentTime);
    }
  }

  String get currentPhase => isInFastingWindow ? 'fasting' : 'eating';
}

class FastingTimerInactive extends FastingTimerState {
  final FastingScheduleEntity schedule;

  const FastingTimerInactive({required this.schedule});

  @override
  List<Object?> get props => [schedule];
}

class FastingTimerEmpty extends FastingTimerState {
  const FastingTimerEmpty();
}

class FastingTimerError extends FastingTimerState {
  final String message;

  const FastingTimerError({required this.message});

  @override
  List<Object?> get props => [message];
}
