import 'package:calorieai/core/data/dbo/water_entry_dbo.dart';

class WaterEntryEntity {
  final DateTime date;
  final double amountML;

  WaterEntryEntity({
    required this.date,
    required this.amountML,
  });

  factory WaterEntryEntity.fromWaterEntryDBO(WaterEntryDBO dbo) {
    return WaterEntryEntity(
      date: dbo.date,
      amountML: dbo.amountML,
    );
  }

  WaterEntryDBO toDBO() {
    return WaterEntryDBO(
      date: date,
      amountML: amountML,
    );
  }
}
