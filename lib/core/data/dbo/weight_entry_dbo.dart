import 'package:hive_flutter/hive_flutter.dart';

part 'weight_entry_dbo.g.dart';

@HiveType(typeId: 22)
class WeightEntryDBO extends HiveObject {
  @HiveField(0)
  DateTime date;
  @HiveField(1)
  double weightKG;

  WeightEntryDBO({
    required this.date,
    required this.weightKG,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'weightKG': weightKG,
    };
  }

  factory WeightEntryDBO.fromJson(Map<String, dynamic> json) {
    return WeightEntryDBO(
      date: DateTime.parse(json['date'] as String),
      weightKG: json['weightKG'] as double,
    );
  }
}
