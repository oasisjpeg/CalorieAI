import 'package:flutter/material.dart';
import 'package:opennutritracker/core/data/dbo/user_weight_goal_dbo.dart';
import 'package:opennutritracker/l10n/app_localizations.dart';
typedef S = AppLocalizations;
enum UserWeightGoalEntity {
  loseWeight,
  maintainWeight,
  gainWeight;

  factory UserWeightGoalEntity.fromUserWeightGoalDBO(
      UserWeightGoalDBO weightGoalDBO) {
    UserWeightGoalEntity weightGoalEntity;
    switch (weightGoalDBO) {
      case UserWeightGoalDBO.gainWeight:
        weightGoalEntity = UserWeightGoalEntity.gainWeight;
        break;
      case UserWeightGoalDBO.maintainWeight:
        weightGoalEntity = UserWeightGoalEntity.maintainWeight;
        break;
      case UserWeightGoalDBO.loseWeight:
        weightGoalEntity = UserWeightGoalEntity.loseWeight;
        break;
    }
    return weightGoalEntity;
  }

  String getName(BuildContext context) {
    String name;
    switch (this) {
      case UserWeightGoalEntity.loseWeight:
        name = S.of(context).goalLoseWeight;
        break;
      case UserWeightGoalEntity.maintainWeight:
        name = S.of(context).goalMaintainWeight;
        break;
      case UserWeightGoalEntity.gainWeight:
        name = S.of(context).goalGainWeight;
        break;
    }
    return name;
  }
}
