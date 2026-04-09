import 'package:calorieai/core/data/dbo/water_entry_dbo.dart';
import 'package:calorieai/core/domain/entity/water_entry_entity.dart';
import 'package:hive_flutter/hive_flutter.dart';

class WaterRepository {
  static const String _boxName = 'water_entries';
  late Box<WaterEntryDBO> _box;

  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<WaterEntryDBO>(_boxName);
    } else {
      _box = Hive.box<WaterEntryDBO>(_boxName);
    }
  }

  Future<void> addWaterEntry(WaterEntryEntity entry) async {
    await init();
    final dbo = entry.toDBO();
    await _box.put(entry.date.toIso8601String(), dbo);
  }

  Future<void> deleteWaterEntry(DateTime date) async {
    await init();
    await _box.delete(date.toIso8601String());
  }

  Future<List<WaterEntryEntity>> getAllWaterEntries() async {
    await init();
    return _box.values
        .map((dbo) => WaterEntryEntity.fromWaterEntryDBO(dbo))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<List<WaterEntryEntity>> getWaterEntriesInRange(
      DateTime startDate, DateTime endDate) async {
    await init();
    return _box.values
        .where((dbo) =>
            dbo.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            dbo.date.isBefore(endDate.add(const Duration(days: 1))))
        .map((dbo) => WaterEntryEntity.fromWaterEntryDBO(dbo))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<WaterEntryEntity?> getLatestWaterEntry() async {
    await init();
    final entries = _box.values
        .map((dbo) => WaterEntryEntity.fromWaterEntryDBO(dbo))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    
    if (entries.isEmpty) return null;
    return entries.first;
  }

  Future<double> getTodayWaterTotal() async {
    await init();
    final today = DateTime.now();
    final todayEntries = _box.values
        .where((dbo) =>
            dbo.date.year == today.year &&
            dbo.date.month == today.month &&
            dbo.date.day == today.day)
        .map((dbo) => WaterEntryEntity.fromWaterEntryDBO(dbo))
        .toList();
    
    return todayEntries.fold<double>(0.0, (sum, entry) => sum + entry.amountML);
  }

  Future<void> clearAll() async {
    await init();
    await _box.clear();
  }

  Future<void> addAllWaterEntries(List<WaterEntryEntity> entries) async {
    await init();
    for (final entry in entries) {
      final dbo = entry.toDBO();
      await _box.put(entry.date.toIso8601String(), dbo);
    }
  }

  Future<List<WaterEntryDBO>> getAllWaterEntriesDBO() async {
    await init();
    return _box.values.toList();
  }
}
