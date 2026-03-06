import 'package:calorieai/features/fasting_timer/domain/entity/fasting_schedule_entity.dart';
import 'package:hive/hive.dart';

class FastingTimerDataSource {
  final Box<FastingScheduleEntity> _fastingBox;

  static const String _scheduleKey = 'fasting_schedule';

  FastingTimerDataSource(this._fastingBox);

  Future<FastingScheduleEntity?> getSchedule() async {
    return _fastingBox.get(_scheduleKey);
  }

  Future<void> saveSchedule(FastingScheduleEntity schedule) async {
    await _fastingBox.put(_scheduleKey, schedule);
  }

  Future<void> deleteSchedule() async {
    await _fastingBox.delete(_scheduleKey);
  }

  Future<bool> hasSchedule() async {
    return _fastingBox.containsKey(_scheduleKey);
  }
}
