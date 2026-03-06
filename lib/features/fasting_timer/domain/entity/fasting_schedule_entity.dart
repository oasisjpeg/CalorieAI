import 'package:hive/hive.dart';

part 'fasting_schedule_entity.g.dart';

@HiveType(typeId: 21)
class FastingScheduleEntity extends HiveObject {
  @HiveField(0)
  final int fastingStartHour;

  @HiveField(1)
  final int fastingStartMinute;

  @HiveField(2)
  final int fastingEndHour;

  @HiveField(3)
  final int fastingEndMinute;

  @HiveField(4)
  final bool isActive;

  @HiveField(5)
  final DateTime? lastStartedAt;

  @HiveField(6)
  final String? title;

  FastingScheduleEntity({
    required this.fastingStartHour,
    required this.fastingStartMinute,
    required this.fastingEndHour,
    required this.fastingEndMinute,
    this.isActive = false,
    this.lastStartedAt,
    this.title,
  });

  FastingScheduleEntity copyWith({
    int? fastingStartHour,
    int? fastingStartMinute,
    int? fastingEndHour,
    int? fastingEndMinute,
    bool? isActive,
    DateTime? lastStartedAt,
    String? title,
  }) {
    return FastingScheduleEntity(
      fastingStartHour: fastingStartHour ?? this.fastingStartHour,
      fastingStartMinute: fastingStartMinute ?? this.fastingStartMinute,
      fastingEndHour: fastingEndHour ?? this.fastingEndHour,
      fastingEndMinute: fastingEndMinute ?? this.fastingEndMinute,
      isActive: isActive ?? this.isActive,
      lastStartedAt: lastStartedAt ?? this.lastStartedAt,
      title: title ?? this.title,
    );
  }

  Duration get fastingDuration {
    final startMinutes = fastingStartHour * 60 + fastingStartMinute;
    final endMinutes = fastingEndHour * 60 + fastingEndMinute;
    var durationMinutes = endMinutes - startMinutes;
    if (durationMinutes < 0) {
      durationMinutes += 24 * 60;
    }
    return Duration(minutes: durationMinutes);
  }

  Duration get eatingWindowDuration {
    return Duration(hours: 24) - fastingDuration;
  }

  DateTime getNextFastingStart(DateTime from) {
    var start = DateTime(
      from.year,
      from.month,
      from.day,
      fastingStartHour,
      fastingStartMinute,
    );
    if (start.isBefore(from)) {
      start = start.add(const Duration(days: 1));
    }
    return start;
  }

  DateTime getNextEatingStart(DateTime from) {
    var end = DateTime(
      from.year,
      from.month,
      from.day,
      fastingEndHour,
      fastingEndMinute,
    );
    if (end.isBefore(from)) {
      end = end.add(const Duration(days: 1));
    }
    return end;
  }

  bool isCurrentlyInFastingWindow(DateTime now) {
    final startMinutes = fastingStartHour * 60 + fastingStartMinute;
    final endMinutes = fastingEndHour * 60 + fastingEndMinute;
    final currentMinutes = now.hour * 60 + now.minute;

    if (startMinutes < endMinutes) {
      return currentMinutes >= startMinutes && currentMinutes < endMinutes;
    } else {
      return currentMinutes >= startMinutes || currentMinutes < endMinutes;
    }
  }
}
