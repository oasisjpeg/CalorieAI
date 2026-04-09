import 'package:calorieai/core/data/dbo/weight_entry_dbo.dart';

class WeightEntryEntity {
  final DateTime date;
  final double weightKG;

  WeightEntryEntity({
    required this.date,
    required this.weightKG,
  });

  factory WeightEntryEntity.fromWeightEntryDBO(WeightEntryDBO dbo) {
    return WeightEntryEntity(
      date: dbo.date,
      weightKG: dbo.weightKG,
    );
  }

  WeightEntryDBO toDBO() {
    return WeightEntryDBO(
      date: date,
      weightKG: weightKG,
    );
  }
}
