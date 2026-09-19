import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:calorieai/core/data/data_source/user_activity_dbo.dart';
import 'package:calorieai/core/domain/entity/physical_activity_entity.dart';

class UserActivityEntity extends Equatable {
  final String id;
  final double duration;
  final double burnedKcal;
  final DateTime date;

  final PhysicalActivityEntity physicalActivityEntity;
  final String? healthKitWorkoutId;
  final bool isFromHealthKit;
  final String? note;

  const UserActivityEntity(
      this.id,
      this.duration,
      this.burnedKcal,
      this.date,
      this.physicalActivityEntity,
      [this.healthKitWorkoutId,
      this.isFromHealthKit = false,
      this.note]);

  factory UserActivityEntity.fromUserActivityDBO(UserActivityDBO activityDBO) {
    return UserActivityEntity(
        activityDBO.id,
        activityDBO.duration,
        activityDBO.burnedKcal,
        activityDBO.date,
        PhysicalActivityEntity.fromPhysicalActivityDBO(
            activityDBO.physicalActivityDBO),
        activityDBO.healthKitWorkoutId,
        activityDBO.isFromHealthKit,
        activityDBO.note);
  }

  @override
  List<Object?> get props => [id, duration, burnedKcal, date, healthKitWorkoutId, isFromHealthKit];

  static IconData getIconData() => Icons.directions_run_outlined;
}
