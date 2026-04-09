import 'package:calorieai/core/data/dbo/weight_entry_dbo.dart';
import 'package:calorieai/core/domain/entity/weight_entry_entity.dart';
import 'package:hive_flutter/hive_flutter.dart';

class WeightRepository {
  static const String _boxName = 'weight_entries';
  late Box<WeightEntryDBO> _box;

  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<WeightEntryDBO>(_boxName);
    } else {
      _box = Hive.box<WeightEntryDBO>(_boxName);
    }
  }

  Future<void> addWeightEntry(WeightEntryEntity entry) async {
    await init();
    final dbo = entry.toDBO();
    await _box.put(entry.date.toIso8601String(), dbo);
  }

  Future<void> deleteWeightEntry(DateTime date) async {
    await init();
    await _box.delete(date.toIso8601String());
  }

  Future<List<WeightEntryEntity>> getAllWeightEntries() async {
    await init();
    return _box.values
        .map((dbo) => WeightEntryEntity.fromWeightEntryDBO(dbo))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<List<WeightEntryEntity>> getWeightEntriesInRange(
      DateTime startDate, DateTime endDate) async {
    await init();
    return _box.values
        .where((dbo) =>
            dbo.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            dbo.date.isBefore(endDate.add(const Duration(days: 1))))
        .map((dbo) => WeightEntryEntity.fromWeightEntryDBO(dbo))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<WeightEntryEntity?> getLatestWeightEntry() async {
    await init();
    final entries = _box.values
        .map((dbo) => WeightEntryEntity.fromWeightEntryDBO(dbo))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    
    if (entries.isEmpty) return null;
    return entries.first;
  }

  Future<void> clearAll() async {
    await init();
    await _box.clear();
  }

  Future<void> addAllWeightEntries(List<WeightEntryEntity> entries) async {
    await init();
    for (final entry in entries) {
      final dbo = entry.toDBO();
      await _box.put(entry.date.toIso8601String(), dbo);
    }
  }

  Future<List<WeightEntryDBO>> getAllWeightEntriesDBO() async {
    await init();
    return _box.values.toList();
  }
}
