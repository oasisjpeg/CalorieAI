import 'package:hive_flutter/hive_flutter.dart';

part 'water_entry_dbo.g.dart';

@HiveType(typeId: 23)
class WaterEntryDBO extends HiveObject {
  @HiveField(0)
  DateTime date;
  @HiveField(1)
  double amountML;

  WaterEntryDBO({
    required this.date,
    required this.amountML,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'amountML': amountML,
    };
  }

  factory WaterEntryDBO.fromJson(Map<String, dynamic> json) {
    return WaterEntryDBO(
      date: DateTime.parse(json['date'] as String),
      amountML: json['amountML'] as double,
    );
  }
}
