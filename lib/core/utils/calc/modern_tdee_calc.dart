import 'package:calorieai/core/domain/entity/user_entity.dart';
import 'package:calorieai/core/domain/entity/user_gender_entity.dart';
import 'package:calorieai/core/domain/entity/user_weight_goal_entity.dart';
import 'package:calorieai/core/domain/entity/user_pal_entity.dart';

/// BMR Formula Types
enum BMRFormula {
  mifflinStJeor, // Most accurate for modern populations (1990)
  harrisBenedictRevised, // Revised Harris-Benedict (1984)
  katchMcArdle, // Best for athletes (requires body fat %)
}

/// Modern TDEE (Total Daily Energy Expenditure) Calculator
/// 
/// Uses evidence-based formulas and updated PAL values
/// Based on current research and best practices
class ModernTDEECalc {

  /// Calculate BMR using Mifflin-St.Jeor equation (1990)
  /// Most accurate for modern populations
  /// Reference: Mifflin MD, et al. Am J Clin Nutr. 1990
  static double calculateBMRMifflinStJeor(UserEntity user) {
    final weight = user.weightKG;
    final height = user.heightCM;
    final age = user.age;
    
    double bmr;
    if (user.gender == UserGenderEntity.male) {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
    
    return bmr;
  }

  /// Calculate BMR using Revised Harris-Benedict equation (1984)
  /// Reference: Roza AM, Shizgal HM. Am J Clin Nutr. 1984
  static double calculateBMRHarrisBenedictRevised(UserEntity user) {
    final weight = user.weightKG;
    final height = user.heightCM;
    final age = user.age;
    
    double bmr;
    if (user.gender == UserGenderEntity.male) {
      bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }
    
    return bmr;
  }

  /// Calculate BMR using Katch-McArdle formula
  /// Best for athletes and those with known body fat percentage
  /// Reference: Katch FI, McArdle WD. 1973
  static double calculateBMRKatchMcArdle(double leanBodyMassKG) {
    return 370 + (21.6 * leanBodyMassKG);
  }

  /// Modern PAL values based on current research
  /// Reference: WHO/FAO/UNU Expert Consultation (2001) updated
  static double getModernPALValue(UserEntity user) {
    // Map existing PAL categories to modern values
    switch (user.pal) {
      case UserPALEntity.sedentary:
        return 1.2; // Little to no exercise
      case UserPALEntity.lowActive:
        return 1.375; // Light exercise 1-3 days/week
      case UserPALEntity.active:
        return 1.55; // Moderate exercise 3-5 days/week
      case UserPALEntity.veryActive:
        return 1.725; // Hard exercise 6-7 days/week
    }
  }

  /// Calculate TDEE using specified BMR formula
  static double calculateTDEE(
    UserEntity user, {
    BMRFormula formula = BMRFormula.mifflinStJeor,
    double? customPAL,
  }) {
    double bmr;
    
    switch (formula) {
      case BMRFormula.mifflinStJeor:
        bmr = calculateBMRMifflinStJeor(user);
        break;
      case BMRFormula.harrisBenedictRevised:
        bmr = calculateBMRHarrisBenedictRevised(user);
        break;
      case BMRFormula.katchMcArdle:
        // Requires body fat percentage - not implemented yet
        // Fall back to Mifflin-St.Jeor
        bmr = calculateBMRMifflinStJeor(user);
        break;
    }
    
    final pal = customPAL ?? getModernPALValue(user);
    return bmr * pal;
  }

  /// Calculate recommended calorie goal based on weight goal
  /// Uses more nuanced adjustments than simple ±500
  static double calculateCalorieGoal(
    UserEntity user,
    double tdee, {
    double? userAdjustment,
    double? activityCalories,
  }) {
    double goalAdjustment;
    
    switch (user.goal) {
      case UserWeightGoalEntity.loseWeight:
        // More aggressive for higher BMI, moderate for normal BMI
        final bmi = user.weightKG / ((user.heightCM / 100) * (user.heightCM / 100));
        if (bmi > 30) {
          goalAdjustment = -750; // More aggressive for obesity
        } else if (bmi > 25) {
          goalAdjustment = -500; // Standard for overweight
        } else {
          goalAdjustment = -300; // Conservative for normal weight
        }
        break;
      case UserWeightGoalEntity.maintainWeight:
        goalAdjustment = 0;
        break;
      case UserWeightGoalEntity.gainWeight:
        goalAdjustment = 500; // Standard for muscle gain
        break;
    }
    
    return tdee + goalAdjustment + (userAdjustment ?? 0) + (activityCalories ?? 0);
  }

  /// Calculate recommended protein intake based on goal and weight
  /// Based on current research (1.6-2.2g per kg for most goals)
  static double calculateProteinGrams(
    UserEntity user,
    double calorieGoal,
  ) {
    double proteinPerKg;
    
    switch (user.goal) {
      case UserWeightGoalEntity.loseWeight:
        // Higher protein to preserve muscle during deficit
        proteinPerKg = 2.0; // 2g per kg
        break;
      case UserWeightGoalEntity.maintainWeight:
        proteinPerKg = 1.6; // 1.6g per kg
        break;
      case UserWeightGoalEntity.gainWeight:
        proteinPerKg = 1.8; // 1.8g per kg for muscle gain
        break;
    }
    
    return user.weightKG * proteinPerKg;
  }

  /// Calculate recommended macro distribution based on goal
  /// Returns (carbs%, protein%, fat%)
  static MacroDistribution calculateMacroDistribution(
    UserEntity user,
    double calorieGoal,
  ) {
    // First calculate protein based on weight (more accurate than %)
    final proteinGrams = calculateProteinGrams(user, calorieGoal);
    final proteinCalories = proteinGrams * 4;
    var proteinPercentage = proteinCalories / calorieGoal;
    
    double fatPercentage;
    double carbsPercentage;
    
    switch (user.goal) {
      case UserWeightGoalEntity.loseWeight:
        // Higher protein, moderate fat, lower carbs
        fatPercentage = 0.30; // 30% fat
        carbsPercentage = 1.0 - proteinPercentage - fatPercentage;
        break;
      case UserWeightGoalEntity.maintainWeight:
        // Balanced distribution
        fatPercentage = 0.35; // 35% fat
        carbsPercentage = 1.0 - proteinPercentage - fatPercentage;
        break;
      case UserWeightGoalEntity.gainWeight:
        // Higher carbs for energy, moderate fat
        fatPercentage = 0.25; // 25% fat
        carbsPercentage = 1.0 - proteinPercentage - fatPercentage;
        break;
    }
    
    // Ensure percentages are valid
    if (carbsPercentage < 0.10) carbsPercentage = 0.10;
    if (fatPercentage < 0.20) fatPercentage = 0.20;
    if (proteinPercentage < 0.15) proteinPercentage = 0.15;
    
    // Normalize to ensure they sum to 1.0
    final total = carbsPercentage + proteinPercentage + fatPercentage;
    return MacroDistribution(
      carbsPercentage: carbsPercentage / total,
      proteinPercentage: proteinPercentage / total,
      fatPercentage: fatPercentage / total,
    );
  }
}

/// Macro distribution data class
class MacroDistribution {
  final double carbsPercentage;
  final double proteinPercentage;
  final double fatPercentage;
  
  MacroDistribution({
    required this.carbsPercentage,
    required this.proteinPercentage,
    required this.fatPercentage,
  });
  
  /// Calculate macro grams from calorie goal
  MacroGrams calculateGrams(double calorieGoal) {
    return MacroGrams(
      carbsGrams: (calorieGoal * carbsPercentage) / 4,
      proteinGrams: (calorieGoal * proteinPercentage) / 4,
      fatGrams: (calorieGoal * fatPercentage) / 9,
    );
  }
}

/// Macro grams data class
class MacroGrams {
  final double carbsGrams;
  final double proteinGrams;
  final double fatGrams;
  
  MacroGrams({
    required this.carbsGrams,
    required this.proteinGrams,
    required this.fatGrams,
  });
}
