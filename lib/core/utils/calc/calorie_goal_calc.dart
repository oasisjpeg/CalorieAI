import 'package:calorieai/core/domain/entity/user_entity.dart';
import 'package:calorieai/core/domain/entity/user_weight_goal_entity.dart';
import 'package:calorieai/core/utils/calc/modern_tdee_calc.dart';

class CalorieGoalCalc {
  static const double loseWeightKcalAdjustment = -500;
  static const double maintainWeightKcalAdjustment = 0;
  static const double gainWeightKcalAdjustment = 500;

  static double getDailyKcalLeft(
          double totalKcalGoal, double totalKcalIntake) =>
      totalKcalGoal - totalKcalIntake;

  static double getTdee(UserEntity userEntity, {BMRFormula? formula}) =>
      ModernTDEECalc.calculateTDEE(
        userEntity,
        formula: formula ?? BMRFormula.mifflinStJeor,
      );

  static double getTotalKcalGoal(
          UserEntity userEntity, double totalKcalActivities,
          {double? kcalUserAdjustment, BMRFormula? formula}) {
    final tdee = getTdee(userEntity, formula: formula);
    return ModernTDEECalc.calculateCalorieGoal(
      userEntity,
      tdee,
      userAdjustment: kcalUserAdjustment,
      activityCalories: totalKcalActivities,
    );
  }

  static double getKcalGoalAdjustment(UserWeightGoalEntity goal) {
    double kcalAdjustment;
    if (goal == UserWeightGoalEntity.loseWeight) {
      kcalAdjustment = loseWeightKcalAdjustment;
    } else if (goal == UserWeightGoalEntity.gainWeight) {
      kcalAdjustment = gainWeightKcalAdjustment;
    } else {
      kcalAdjustment = maintainWeightKcalAdjustment;
    }
    return kcalAdjustment;
  }
}
