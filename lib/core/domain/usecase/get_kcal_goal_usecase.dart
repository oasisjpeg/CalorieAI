import 'package:collection/collection.dart';
import 'package:calorieai/core/data/repository/config_repository.dart';
import 'package:calorieai/core/data/repository/user_activity_repository.dart';
import 'package:calorieai/core/data/repository/user_repository.dart';
import 'package:calorieai/core/domain/entity/user_entity.dart';
import 'package:calorieai/core/utils/calc/calorie_goal_calc.dart';

class GetKcalGoalUsecase {
  final UserRepository _userRepository;
  final ConfigRepository _configRepository;
  final UserActivityRepository _userActivityRepository;

  GetKcalGoalUsecase(
      this._userRepository, this._configRepository, this._userActivityRepository);

  Future<double> getKcalGoal(
      {UserEntity? userEntity,
      double? totalKcalActivitiesParam,
      double? kcalUserAdjustment,
      bool includeActivityCalories = false}) async {
    final user = userEntity ?? await _userRepository.getUserData();
    final config = await _configRepository.getConfig();
    
    // Only include activity calories if explicitly requested
    // Otherwise, calculate goal without activities (to subtract from intake instead)
    final totalKcalActivities = includeActivityCalories
        ? (totalKcalActivitiesParam ??
            (await _userActivityRepository.getAllUserActivityByDate(DateTime.now()))
                .map((activity) => activity.burnedKcal)
                .toList()
                .sum
                .toDouble())
        : 0.0;
        
    return CalorieGoalCalc.getTotalKcalGoal(
      user,
      totalKcalActivities,
      kcalUserAdjustment: config.userKcalAdjustment,
      formula: config.bmrFormula,
    );
  }
  
  Future<double> getTotalKcalActivities(DateTime date) async {
    return (await _userActivityRepository.getAllUserActivityByDate(date))
        .map((activity) => activity.burnedKcal)
        .toList()
        .sum
        .toDouble();
  }
}
