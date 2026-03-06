import 'package:calorieai/features/fasting_timer/core/service/fasting_notification_service.dart';
import 'package:calorieai/features/fasting_timer/data/data_source/fasting_timer_data_source.dart';
import 'package:calorieai/features/fasting_timer/domain/entity/fasting_schedule_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'fasting_timer_event.dart';
part 'fasting_timer_state.dart';

class FastingTimerBloc extends Bloc<FastingTimerEvent, FastingTimerState> {
  final FastingTimerDataSource _dataSource;
  final FastingNotificationService _notificationService;

  FastingTimerBloc(
    this._dataSource,
    this._notificationService,
  ) : super(FastingTimerInitial()) {
    on<LoadFastingScheduleEvent>(_onLoadSchedule);
    on<SaveFastingScheduleEvent>(_onSaveSchedule);
    on<ToggleFastingTimerEvent>(_onToggleTimer);
    on<DeleteFastingScheduleEvent>(_onDeleteSchedule);
    on<UpdateTimerEvent>(_onUpdateTimer);
  }

  Future<void> _onLoadSchedule(
    LoadFastingScheduleEvent event,
    Emitter<FastingTimerState> emit,
  ) async {
    emit(FastingTimerLoading());
    try {
      final schedule = await _dataSource.getSchedule();
      if (schedule != null && schedule.isActive) {
        emit(FastingTimerActive(schedule: schedule, currentTime: DateTime.now()));
      } else if (schedule != null) {
        emit(FastingTimerInactive(schedule: schedule));
      } else {
        emit(FastingTimerEmpty());
      }
    } catch (e) {
      emit(FastingTimerError(message: e.toString()));
    }
  }

  Future<void> _onSaveSchedule(
    SaveFastingScheduleEvent event,
    Emitter<FastingTimerState> emit,
  ) async {
    emit(FastingTimerLoading());
    try {
      final schedule = FastingScheduleEntity(
        fastingStartHour: event.fastingStartHour,
        fastingStartMinute: event.fastingStartMinute,
        fastingEndHour: event.fastingEndHour,
        fastingEndMinute: event.fastingEndMinute,
        isActive: event.isActive,
        title: event.title,
      );
      await _dataSource.saveSchedule(schedule);
      if (event.isActive) {
        await _scheduleNotifications(schedule, event.localizations);
        emit(FastingTimerActive(schedule: schedule, currentTime: DateTime.now()));
      } else {
        await _notificationService.cancelAllFastingNotifications();
        emit(FastingTimerInactive(schedule: schedule));
      }
    } catch (e) {
      emit(FastingTimerError(message: e.toString()));
    }
  }

  Future<void> _onToggleTimer(
    ToggleFastingTimerEvent event,
    Emitter<FastingTimerState> emit,
  ) async {
    if (state is FastingTimerInactive) {
      final currentState = state as FastingTimerInactive;
      final activatedSchedule = currentState.schedule.copyWith(isActive: true);
      await _dataSource.saveSchedule(activatedSchedule);
      await _scheduleNotifications(activatedSchedule, event.localizations);
      emit(FastingTimerActive(schedule: activatedSchedule, currentTime: DateTime.now()));
    } else if (state is FastingTimerActive) {
      final currentState = state as FastingTimerActive;
      final deactivatedSchedule = currentState.schedule.copyWith(isActive: false);
      await _dataSource.saveSchedule(deactivatedSchedule);
      await _notificationService.cancelAllFastingNotifications();
      emit(FastingTimerInactive(schedule: deactivatedSchedule));
    }
  }

  Future<void> _onDeleteSchedule(
    DeleteFastingScheduleEvent event,
    Emitter<FastingTimerState> emit,
  ) async {
    emit(FastingTimerLoading());
    try {
      await _notificationService.cancelAllFastingNotifications();
      await _dataSource.deleteSchedule();
      emit(FastingTimerEmpty());
    } catch (e) {
      emit(FastingTimerError(message: e.toString()));
    }
  }

  Future<void> _onUpdateTimer(
    UpdateTimerEvent event,
    Emitter<FastingTimerState> emit,
  ) async {
    if (state is FastingTimerActive) {
      final currentState = state as FastingTimerActive;
      emit(FastingTimerActive(schedule: currentState.schedule, currentTime: DateTime.now()));
    }
  }

  Future<void> _scheduleNotifications(
    FastingScheduleEntity schedule,
    FastingLocalizations localizations,
  ) async {
    await _notificationService.scheduleFastingNotifications(
      schedule,
      localizations.fastingStartedTitle,
      localizations.fastingStartedBody,
      localizations.eatingStartedTitle,
      localizations.eatingStartedBody,
    );
  }
}

class FastingLocalizations {
  final String fastingStartedTitle;
  final String fastingStartedBody;
  final String eatingStartedTitle;
  final String eatingStartedBody;

  FastingLocalizations({
    required this.fastingStartedTitle,
    required this.fastingStartedBody,
    required this.eatingStartedTitle,
    required this.eatingStartedBody,
  });
}
