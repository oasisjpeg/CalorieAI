import 'dart:io';
import 'package:health/health.dart';
import 'package:logging/logging.dart';
import 'package:calorieai/core/domain/entity/intake_entity.dart';
import 'package:calorieai/core/domain/entity/intake_type_entity.dart';
import 'package:calorieai/core/domain/entity/user_activity_entity.dart';
import 'package:calorieai/core/domain/entity/physical_activity_entity.dart';

class AppleHealthService {
  static final _log = Logger('AppleHealthService');
  static final AppleHealthService _instance = AppleHealthService._internal();
  
  factory AppleHealthService() => _instance;
  AppleHealthService._internal();

  Health? _health;
  bool _isAuthorized = false;

  /// Nutrition types this app writes via [Health.writeMeal].
  /// NUTRITION is the .food correlation; the quantity types are the
  /// nutrient samples contained in that correlation. Requesting access to
  /// all of them lets us query and sweep orphaned nutrient samples.
  static const List<HealthDataType> _nutritionTypes = [
    HealthDataType.NUTRITION,
    HealthDataType.DIETARY_ENERGY_CONSUMED,
    HealthDataType.DIETARY_CARBS_CONSUMED,
    HealthDataType.DIETARY_PROTEIN_CONSUMED,
    HealthDataType.DIETARY_FATS_CONSUMED,
    HealthDataType.DIETARY_SUGAR,
    HealthDataType.DIETARY_FAT_SATURATED,
    HealthDataType.DIETARY_FIBER,
  ];

  /// Initialize HealthKit
  Future<void> init() async {
    if (!Platform.isIOS && !Platform.isMacOS) {
      _log.warning('HealthKit is only available on iOS/macOS');
      return;
    }

    _health = Health();
    _log.info('HealthKit initialized successfully');
  }

  /// Request HealthKit permissions for nutrition data
  Future<bool> requestPermissions() async {
    if (_health == null) {
      await init();
    }

    if (_health == null) {
      _log.severe('Failed to initialize HealthKit');
      return false;
    }

    try {
      // Request permissions for the food correlation AND every nutrient
      // quantity type writeMeal creates, so we can also read/delete them.
      final bool wasGranted = await _health!.requestAuthorization(
        _nutritionTypes,
        permissions:
            List.filled(_nutritionTypes.length, HealthDataAccess.READ_WRITE),
      );
      
      _isAuthorized = wasGranted;
      _log.info('HealthKit authorization ${wasGranted ? "granted" : "denied"}');
      return wasGranted;
    } catch (e) {
      _log.severe('Error requesting HealthKit permissions: $e');
      return false;
    }
  }

  /// Request HealthKit permissions for activity sync
  Future<bool> requestActivityPermissions() async {
    _log.info('requestActivityPermissions called: _health=$_health, _isAuthorized=$_isAuthorized');
    
    if (_health == null) {
      _log.info('HealthKit not initialized, calling init()');
      await init();
    }

    if (_health == null) {
      _log.severe('Failed to initialize HealthKit');
      return false;
    }

    try {
      // Request permissions for activity data types
      _log.info('Requesting HealthKit activity permissions for STEPS, WORKOUT, DISTANCE_WALKING_RUNNING');
      final bool wasGranted = await _health!.requestAuthorization(
        [
          HealthDataType.STEPS,
          HealthDataType.WORKOUT,
          HealthDataType.DISTANCE_WALKING_RUNNING,
        ],
        permissions: [
          HealthDataAccess.READ_WRITE,
          HealthDataAccess.READ_WRITE,
          HealthDataAccess.READ_WRITE,
        ],
      );
      
      _isAuthorized = wasGranted;
      _log.info('HealthKit activity authorization ${wasGranted ? "granted" : "denied"}');
      return wasGranted;
    } catch (e) {
      _log.severe('Error requesting HealthKit activity permissions: $e');
      return false;
    }
  }

  /// Check if HealthKit is authorized
  bool get isAuthorized => _isAuthorized;

  /// Check if HealthKit has permissions
  Future<bool> hasPermissions() async {
    if (_health == null) return false;
    
    try {
      final hasPermissions = await _health!.hasPermissions(
        _nutritionTypes,
        permissions:
            List.filled(_nutritionTypes.length, HealthDataAccess.READ_WRITE),
      );
      _isAuthorized = hasPermissions ?? false;
      return hasPermissions ?? false;
    } catch (e) {
      _log.severe('Error checking HealthKit permissions: $e');
      return false;
    }
  }

  /// Check if HealthKit has activity permissions
  Future<bool> hasActivityPermissions() async {
    if (_health == null) return false;
    
    try {
      final hasPermissions = await _health!.hasPermissions(
        [
          HealthDataType.STEPS,
          HealthDataType.WORKOUT,
          HealthDataType.DISTANCE_WALKING_RUNNING,
        ],
        permissions: [
          HealthDataAccess.READ_WRITE,
          HealthDataAccess.READ_WRITE,
          HealthDataAccess.READ_WRITE,
        ],
      );
      _isAuthorized = hasPermissions ?? false;
      _log.info('HealthKit activity permissions check: ${hasPermissions ?? false}');
      return hasPermissions ?? false;
    } catch (e) {
      _log.severe('Error checking HealthKit activity permissions: $e');
      return false;
    }
  }

  /// Restore authorization state from HealthKit
  /// This checks if permissions were previously granted and restores the _isAuthorized flag
  Future<void> restoreAuthorizationState() async {
    if (_health == null) {
      _log.warning('HealthKit not initialized, cannot restore authorization state');
      await init();
    }

    if (_health == null) {
      _log.severe('Failed to initialize HealthKit for authorization restoration');
      return;
    }

    try {
      // Check both nutrition and activity permissions
      final hasNutritionPermission = await hasPermissions();
      final hasActivityPermission = await hasActivityPermissions();
      
      // Authorize if either permission type is granted
      _isAuthorized = hasNutritionPermission || hasActivityPermission;
      
      _log.info('Authorization state restored: _isAuthorized=$_isAuthorized, nutrition=$hasNutritionPermission, activity=$hasActivityPermission');
    } catch (e) {
      _log.severe('Error restoring authorization state: $e');
      _isAuthorized = false;
    }
  }

  /// Ensure nutrition permissions are granted, requesting if needed
  Future<bool> _ensureNutritionPermissions() async {
    if (_health == null) {
      await init();
    }
    if (_health == null) return false;

    // Check specifically for nutrition permissions
    final hasNutrition = await hasPermissions();
    if (hasNutrition) return true;

    // Try requesting permissions
    return await requestPermissions();
  }

  /// Ensure activity permissions are granted, requesting if needed
  Future<bool> _ensureActivityPermissions() async {
    if (_health == null) {
      await init();
    }
    if (_health == null) return false;

    // Check specifically for activity permissions
    final hasActivity = await hasActivityPermissions();
    if (hasActivity) return true;

    // Try requesting permissions
    return await requestActivityPermissions();
  }

  /// Map IntakeTypeEntity to HealthKit MealType
  MealType _mapMealType(IntakeTypeEntity intakeType) {
    switch (intakeType) {
      case IntakeTypeEntity.breakfast:
        return MealType.BREAKFAST;
      case IntakeTypeEntity.lunch:
        return MealType.LUNCH;
      case IntakeTypeEntity.dinner:
        return MealType.DINNER;
      case IntakeTypeEntity.snack:
        return MealType.SNACK;
    }
  }

  /// Sync a single intake to HealthKit using writeMeal method
  Future<bool> syncIntake(IntakeEntity intake) async {
    final hasPermissions = await _ensureNutritionPermissions();
    if (!hasPermissions) {
      _log.warning('HealthKit not initialized or not authorized');
      return false;
    }

    try {
      final now = intake.dateTime;
      final endTime = now.add(const Duration(minutes: 1));

      // Use writeMeal to sync all nutrition data at once
      final success = await _health!.writeMeal(
        mealType: _mapMealType(intake.type),
        startTime: now,
        endTime: endTime,
        caloriesConsumed: intake.totalKcal,
        carbohydrates: intake.totalCarbsGram,
        protein: intake.totalProteinsGram,
        fatTotal: intake.totalFatsGram,
        sugar: intake.totalSugarsGram,
        fatSaturated: intake.totalSaturatedFatGram,
        fiber: intake.totalFiberGram,
        name: intake.meal.name ?? 'Meal',
        recordingMethod: RecordingMethod.manual,
      );

      if (success) {
        _log.info('Successfully synced intake: ${intake.meal.name}');
      } else {
        _log.warning('Failed to sync intake: ${intake.meal.name}');
      }
      
      return success;
    } catch (e) {
      _log.severe('Error syncing intake to HealthKit: $e');
      return false;
    }
  }

  /// Delete intake from HealthKit.
  ///
  /// writeMeal stores each intake as a single .food correlation (NUTRITION)
  /// that owns all of its nutrient samples. Deleting the correlation
  /// cascades to every contained sample, so we only need to find and delete
  /// the matching correlation.
  ///
  /// IMPORTANT: we must only query NUTRITION here. Querying nutrient
  /// quantity types (e.g. DIETARY_ENERGY_CONSUMED) without read permission
  /// makes the whole getHealthDataFromTypes call throw, which previously
  /// caused every delete to silently abort.
  Future<bool> deleteIntakeFromHealthKit(String intakeId, DateTime dateTime, double totalKcal, String mealName) async {
    final hasPermissions = await _ensureNutritionPermissions();
    if (!hasPermissions) {
      _log.warning('HealthKit not initialized or not authorized');
      return false;
    }

    try {
      // Query food correlations on the given date
      final startDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
      final endDate = DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59);

      final samples = await _health!.getHealthDataFromTypes(
        startTime: startDate,
        endTime: endDate,
        types: [HealthDataType.NUTRITION],
      );

      _log.info('Found ${samples.length} food correlations to check for deletion of intake $intakeId (target calories: $totalKcal, meal: $mealName, targetTime: $dateTime)');

      final matches = <HealthDataPoint>[];

      // Pass 1: strict matching on time + calories + name
      for (final sample in samples) {
        final timeDiff = sample.dateFrom.difference(dateTime).abs();

        double? sampleCalories;
        String? sampleMealName;

        if (sample.value is NutritionHealthValue) {
          final nv = sample.value as NutritionHealthValue;
          sampleCalories = nv.calories;
          sampleMealName = nv.name;
        }

        _log.info('Food correlation: dateFrom=${sample.dateFrom}, timeDiff=${timeDiff.inSeconds}s, calories=$sampleCalories, name=$sampleMealName');

        if (timeDiff.inSeconds >= 60 || sampleCalories == null) continue;

        final isCalorieMatch = (sampleCalories - totalKcal).abs() < 10.0;

        bool isNameMatch = true;
        if (sampleMealName != null && sampleMealName.isNotEmpty && mealName.isNotEmpty) {
          isNameMatch = sampleMealName == mealName ||
                        sampleMealName.contains(mealName) ||
                        mealName.contains(sampleMealName);
        }

        if (isCalorieMatch && isNameMatch) {
          matches.add(sample);
        }
      }

      // Pass 2: if no strict match found, fall back to tight time-only matching
      if (matches.isEmpty) {
        _log.info('No strict match found, falling back to time-only matching');
        for (final sample in samples) {
          final timeDiff = sample.dateFrom.difference(dateTime).abs();
          if (timeDiff.inSeconds < 5) {
            matches.add(sample);
          }
        }
      }

      int deletedCount = 0;
      for (final match in matches) {
        // The plugin's delete() uses a .strictStartDate predicate on
        // millisecond-truncated dates, so pad the window around the
        // correlation's start date to guarantee it is included. Deleting
        // the correlation also deletes all contained nutrient samples.
        final success = await _health!.delete(
          type: HealthDataType.NUTRITION,
          startTime: match.dateFrom.subtract(const Duration(seconds: 1)),
          endTime: match.dateFrom.add(const Duration(seconds: 1)),
        );
        if (success) {
          deletedCount++;
          _log.info('Deleted food correlation from HealthKit: $intakeId ($mealName) at ${match.dateFrom}');
        } else {
          _log.warning('delete() returned false for correlation at ${match.dateFrom}');
        }
      }

      // Sweep standalone nutrient samples in the same time window.
      // writeMeal stores nutrients inside the .food correlation (deleted
      // above), but entries written without a correlation or orphaned by
      // previously failed deletes survive as standalone samples that
      // still show up in Apple Health.
      for (final type in _nutritionTypes.skip(1)) {
        final nutrientSamples = await _health!.getHealthDataFromTypes(
          startTime: startDate,
          endTime: endDate,
          types: [type],
        );
        for (final s in nutrientSamples) {
          final timeDiff = s.dateFrom.difference(dateTime).abs();
          if (timeDiff.inSeconds >= 10) continue;
          final success = await _health!.delete(
            type: type,
            startTime: s.dateFrom.subtract(const Duration(seconds: 1)),
            endTime: s.dateFrom.add(const Duration(seconds: 1)),
          );
          if (success) {
            deletedCount++;
            _log.info('Deleted standalone ${type.name} sample at ${s.dateFrom} for intake $intakeId');
          }
        }
      }

      if (deletedCount > 0) {
        _log.info('Deleted $deletedCount HealthKit entries for intake $intakeId');
      } else {
        _log.warning('No matching HealthKit entry found to delete for intake $intakeId');
      }

      return deletedCount > 0;
    } catch (e) {
      _log.severe('Error deleting intake from HealthKit: $e');
      return false;
    }
  }

  /// Map Apple Health workout type to PhysicalActivityEntity code
  String _mapWorkoutTypeToActivityCode(int workoutType) {
    // Map HealthKit workout types to existing activity codes
    // Reference: https://developer.apple.com/documentation/healthkit/hkworkoutactivitytype
    switch (workoutType) {
      case 1: // HKWorkoutActivityType.running
        return '12150'; // Running General
      case 2: // HKWorkoutActivityType.cycling
        return '01015'; // Bicycling General
      case 3: // HKWorkoutActivityType.walking
        return '17160'; // Walking For Pleasure
      case 4: // HKWorkoutActivityType.swimming
        return '18350'; // Swimming General
      case 5: // HKWorkoutActivityType.hiking
        return '17080'; // Hiking Cross Country
      case 6: // HKWorkoutActivityType.yoga
        return '02030'; // Calisthenics General (closest match)
      case 7: // HKWorkoutActivityType.functionalStrengthTraining
        return '02050'; // Resistance Training
      case 8: // HKWorkoutActivityType.traditionalStrengthTraining
        return '02050'; // Resistance Training
      case 9: // HKWorkoutActivityType.crossTraining
        return '02030'; // Calisthenics General
      case 10: // HKWorkoutActivityType.flexibilityTraining
        return '02030'; // Calisthenics General
      case 11: // HKWorkoutActivityType.walkingStairs
        return '17160'; // Walking For Pleasure
      case 12: // HKWorkoutActivityType.stairs
        return '17160'; // Walking For Pleasure
      case 13: // HKWorkoutActivityType.stepTraining
        return '17160'; // Walking For Pleasure
      case 14: // HKWorkoutActivityType.fitnessGaming
        return '02030'; // Calisthenics General
      case 15: // HKWorkoutActivityType.dance
        return '03015'; // Dancing Aerobic General
      case 16: // HKWorkoutActivityType.barre
        return '02030'; // Calisthenics General
      case 17: // HKWorkoutActivityType.coreTraining
        return '02030'; // Calisthenics General
      case 18: // HKWorkoutActivityType.flexibility
        return '02030'; // Calisthenics General
      case 19: // HKWorkoutActivityType.highIntensityIntervalTraining
        return '02068'; // Rope Skipping General (high intensity)
      case 20: // HKWorkoutActivityType.jumpRope
        return '02068'; // Rope Skipping General
      case 21: // HKWorkoutActivityType.pilates
        return '02030'; // Calisthenics General
      case 22: // HKWorkoutActivityType.racketSports
        return '15675'; // Tennis General (generic racket sport)
      case 23: // HKWorkoutActivityType.swimBikeRun
        return '12150'; // Running General (triathlon)
      case 24: // HKWorkoutActivityType.preparationAndRecovery
        return '02030'; // Calisthenics General
      case 25: // HKWorkoutActivityType.wheelchairWalkPace
        return '17160'; // Walking For Pleasure
      case 26: // HKWorkoutActivityType.wheelchairRunPace
        return '12150'; // Running General
      case 27: // HKWorkoutActivityType.basketball
        return '15055'; // Basketball General
      case 28: // HKWorkoutActivityType.football
        return '15230'; // American Football General
      case 29: // HKWorkoutActivityType.soccer
        return '15610'; // Soccer General
      case 30: // HKWorkoutActivityType.tennis
        return '15675'; // Tennis General
      case 31: // HKWorkoutActivityType.hockey
        return '15360'; // Ice Hockey General
      case 32: // HKWorkoutActivityType.other
        return '02030'; // Calisthenics General (fallback)
      default:
        // Default to walking for unknown types
        return '17160'; // Walking For Pleasure
    }
  }

  /// Fetch workouts from HealthKit for a date range
  Future<List<HealthDataPoint>> fetchWorkouts(DateTime startDate, DateTime endDate) async {
    final hasPermissions = await _ensureActivityPermissions();
    if (!hasPermissions) {
      _log.warning('HealthKit not initialized or not authorized');
      return [];
    }

    try {
      final now = DateTime.now();
      // HealthKit requires end date to be in the past
      final adjustedEndDate = endDate.isAfter(now) ? now : endDate;

      final healthData = await _health!.getHealthDataFromTypes(
        startTime: startDate,
        endTime: adjustedEndDate,
        types: [HealthDataType.WORKOUT],
      );

      _log.info('Fetched ${healthData.length} workouts from HealthKit');
      return healthData;
    } catch (e) {
      _log.severe('Error fetching workouts from HealthKit: $e');
      return [];
    }
  }

  /// Fetch steps from HealthKit for a date range
  Future<List<HealthDataPoint>> fetchSteps(DateTime startDate, DateTime endDate) async {
    final hasPermissions = await _ensureActivityPermissions();
    if (!hasPermissions) {
      _log.warning('HealthKit not initialized or not authorized');
      return [];
    }

    try {
      final now = DateTime.now();
      final adjustedEndDate = endDate.isAfter(now) ? now : endDate;

      final healthData = await _health!.getHealthDataFromTypes(
        startTime: startDate,
        endTime: adjustedEndDate,
        types: [HealthDataType.STEPS],
      );

      _log.info('Fetched ${healthData.length} step entries from HealthKit');
      return healthData;
    } catch (e) {
      _log.severe('Error fetching steps from HealthKit: $e');
      return [];
    }
  }

  /// Fetch distance data from HealthKit for accurate step conversion
  Future<List<HealthDataPoint>> fetchDistance(DateTime startDate, DateTime endDate) async {
    final hasPermissions = await _ensureActivityPermissions();
    if (!hasPermissions) {
      _log.warning('HealthKit not initialized or not authorized');
      return [];
    }

    try {
      final now = DateTime.now();
      final adjustedEndDate = endDate.isAfter(now) ? now : endDate;

      final healthData = await _health!.getHealthDataFromTypes(
        startTime: startDate,
        endTime: adjustedEndDate,
        types: [HealthDataType.DISTANCE_WALKING_RUNNING],
      );

      _log.info('Fetched ${healthData.length} distance entries from HealthKit');
      return healthData;
    } catch (e) {
      _log.severe('Error fetching distance from HealthKit: $e');
      return [];
    }
  }

  /// Convert HealthKit workout to UserActivityEntity
  /// Note: This requires PhysicalActivityEntity to be provided or looked up
  UserActivityEntity? convertWorkoutToUserActivity(
    HealthDataPoint workout,
    PhysicalActivityEntity physicalActivity,
  ) {
    try {
      // Calculate duration from dateFrom and dateTo
      final duration = workout.dateTo.difference(workout.dateFrom);
      final durationInMinutes = duration.inMinutes.toDouble();
      
      // Extract calories from WorkoutHealthValue if available
      double burnedKcal = 0;
      final workoutValue = workout.value as dynamic;
      if (workoutValue.toString().contains('WorkoutHealthValue')) {
        final totalEnergyBurned = workoutValue.totalEnergyBurned as num?;
        burnedKcal = totalEnergyBurned?.toDouble() ?? 0;
      }
      
      // Fallback: Calculate burned calories based on MET value and duration if no calories from HealthKit
      if (burnedKcal == 0 && durationInMinutes > 0) {
        burnedKcal = (physicalActivity.mets * 3.5 * 70 / 200 * durationInMinutes).round().toDouble();
      }

      return UserActivityEntity(
        workout.dateFrom.toString(), // Use dateFrom as ID (will be replaced with UUID in DB)
        durationInMinutes,
        burnedKcal,
        workout.dateFrom,
        physicalActivity,
      );
    } catch (e) {
      _log.severe('Error converting workout to UserActivityEntity: $e');
      return null;
    }
  }

  /// Sync a single activity to HealthKit
  /// Note: This is a placeholder implementation. The actual HealthKit API for writing workouts
  /// requires more complex setup. This will be refined after the database schema is updated.
  Future<bool> syncActivityToHealthKit(UserActivityEntity activity) async {
    final hasPermissions = await _ensureActivityPermissions();
    if (!hasPermissions) {
      _log.warning('HealthKit not initialized or not authorized');
      return false;
    }

    try {
      // TODO: Implement actual HealthKit workout writing
      // The health package requires specific HealthDataPoint structure with uuid, source info, etc.
      // For now, return true to not block the app flow
      _log.info('Sync activity to HealthKit (placeholder): ${activity.physicalActivityEntity.specificActivity}');
      return true;
    } catch (e) {
      _log.severe('Error syncing activity to HealthKit: $e');
      return false;
    }
  }

  /// Delete all nutrition data from HealthKit within a date range.
  /// Uses broad-range deletion per type (more reliable than querying
  /// individual samples). Returns the number of type-ranges successfully deleted.
  Future<int> deleteAllNutritionData(DateTime startDate, DateTime endDate) async {
    final hasPermissions = await _ensureNutritionPermissions();
    if (!hasPermissions) {
      _log.warning('HealthKit not initialized or not authorized');
      return 0;
    }

    try {
      // HealthKit does not allow future end dates for delete operations
      final now = DateTime.now();
      final adjustedEndDate = endDate.isAfter(now) ? now : endDate;

      int deletedRanges = 0;
      // Delete the food correlations AND every nutrient quantity type.
      // Deleting a correlation cascades to its contained samples, but
      // sweeping the quantity types also removes orphaned nutrient samples
      // left behind by earlier failed deletions.
      for (final type in _nutritionTypes) {
        try {
          final success = await _health!.delete(
            type: type,
            startTime: startDate,
            endTime: adjustedEndDate,
          );
          if (success) {
            deletedRanges++;
            _log.info('Deleted all $type data from $startDate to $adjustedEndDate');
          } else {
            _log.warning('delete() returned false for $type');
          }
        } catch (e) {
          _log.warning('Error deleting $type: $e');
        }
      }

      _log.info('Deleted $deletedRanges/${_nutritionTypes.length} nutrition type ranges from HealthKit');
      return deletedRanges;
    } catch (e) {
      _log.severe('Error deleting all nutrition data from HealthKit: $e');
      return 0;
    }
  }

  /// Delete activity from HealthKit
  Future<bool> deleteActivityFromHealthKit(String activityId, DateTime dateTime) async {
    final hasPermissions = await _ensureActivityPermissions();
    if (!hasPermissions) {
      _log.warning('HealthKit not initialized or not authorized');
      return false;
    }

    try {
      // HealthKit doesn't provide a direct way to delete by ID
      // We would need to query for workouts at the given datetime and delete them
      _log.info('Delete not implemented for activity: $activityId');
      return true; // Return true to not block the app flow
    } catch (e) {
      _log.severe('Error deleting activity from HealthKit: $e');
      return false;
    }
  }

  /// Sync historic activities from HealthKit (all time, excluding today)
  /// Returns the number of activities synced
  Future<int> syncHistoricActivitiesFromHealthKit(
    Future<bool> Function(String) isActivityAlreadySynced,
    Future<void> Function(UserActivityEntity, String) addActivityWithHealthKitId,
    Future<List<PhysicalActivityEntity>> Function() getAllPhysicalActivities,
  ) async {
    final hasPermissions = await _ensureActivityPermissions();
    if (!hasPermissions) {
      _log.warning('HealthKit not initialized or not authorized');
      return 0;
    }

    try {
      // Fetch all workouts from HealthKit (from the beginning of time)
      final startDate = DateTime(2000, 1, 1); // Arbitrary early date
      // Only sync workouts up to yesterday, not today's workouts
      final endDate = DateTime.now().subtract(const Duration(days: 1));
      
      final workouts = await fetchWorkouts(startDate, endDate);
      _log.info('Fetched ${workouts.length} workouts from HealthKit for historic sync');

      // Get all physical activities for mapping
      final physicalActivities = await getAllPhysicalActivities();
      final activityMap = {for (var pa in physicalActivities) pa.code: pa};

      int syncedCount = 0;
      int skippedCount = 0;

      for (final workout in workouts) {
        try {
          // Extract workout type from metadata - try multiple possible locations
          int? workoutType = workout.metadata?['workoutActivityType'] as int?;
          
          // Fallback: try to get from unit if metadata doesn't have it
          if (workoutType == null && workout.unit is int) {
            workoutType = workout.unit as int?;
          }
          
          // Fallback: try other common metadata keys
          workoutType ??= workout.metadata?['HKWorkoutActivityType'] as int?;
          
          // Fallback: try to get from value if it's an int (some health packages store type in value)
          if (workoutType == null && workout.value is int) {
            workoutType = workout.value as int?;
          }
          
          // Fallback: try to get from WorkoutHealthValue.workoutActivityType
          if (workoutType == null) {
            final workoutValue = workout.value as dynamic;
            if (workoutValue.toString().contains('WorkoutHealthValue')) {
              final activityType = workoutValue.workoutActivityType;
              // HealthWorkoutActivityType is an enum, convert to index
              if (activityType != null) {
                workoutType = (activityType as dynamic).index as int?;
              }
            }
          }
          
          if (workoutType == null) {
            _log.warning('Workout missing activity type, metadata: ${workout.metadata}, unit: ${workout.unit}, value: ${workout.value}, value type: ${workout.value.runtimeType}, skipping');
            skippedCount++;
            continue;
          }

          // Map to activity code
          final activityCode = _mapWorkoutTypeToActivityCode(workoutType);
          final physicalActivity = activityMap[activityCode];

          if (physicalActivity == null) {
            _log.warning('No physical activity found for code: $activityCode, skipping workout');
            skippedCount++;
            continue;
          }

          // Convert to UserActivityEntity
          final userActivity = convertWorkoutToUserActivity(workout, physicalActivity);
          if (userActivity == null) {
            _log.warning('Failed to convert workout to UserActivityEntity, skipping');
            skippedCount++;
            continue;
          }

          // Get HealthKit workout UUID
          final healthKitWorkoutId = workout.uuid;

          // Check if already synced
          final alreadySynced = await isActivityAlreadySynced(healthKitWorkoutId);
          if (alreadySynced) {
            //_log.fine('Activity already synced: $healthKitWorkoutId, skipping');
            skippedCount++;
            continue;
          }

          // Add to database with HealthKit ID
          await addActivityWithHealthKitId(userActivity, healthKitWorkoutId);
          syncedCount++;
          _log.fine('Synced activity: ${physicalActivity.specificActivity} from $healthKitWorkoutId');
        } catch (e) {
          _log.severe('Error syncing individual workout: $e');
          skippedCount++;
        }
      }

      _log.info('Historic activity sync complete: $syncedCount synced, $skippedCount skipped');
      return syncedCount;
    } catch (e) {
      _log.severe('Error syncing historic activities from HealthKit: $e');
      return 0;
    }
  }

  /// Get steps from HealthKit for a date range
  /// Returns a map of date to step count
  Future<Map<DateTime, int>> getStepsFromHealthKit(DateTime startDate, DateTime endDate) async {
    _log.info('getStepsFromHealthKit called: _health=$_health, _isAuthorized=$_isAuthorized');

    if (_health == null) {
      _log.warning('HealthKit not initialized - call init() first');
      return {};
    }

    final hasPermissions = await _ensureActivityPermissions();
    if (!hasPermissions) {
      _log.warning('HealthKit not authorized - call requestActivityPermissions() first');
      return {};
    }

    try {
      final stepsData = await fetchSteps(startDate, endDate);
      _log.info('Fetched ${stepsData.length} step entries from HealthKit for range $startDate to $endDate');

      // Group steps by date and sum them (samples appear to be incremental)
      final stepsByDate = <DateTime, int>{};
      for (final stepData in stepsData) {
        final date = DateTime(stepData.dateFrom.year, stepData.dateFrom.month, stepData.dateFrom.day);
        final value = stepData.value;
        // NumericHealthValue has a numericValue property
        final numericValue = (value as dynamic).numericValue as num?;
        final steps = numericValue?.toInt() ?? 0;
        
        _log.fine('Step sample: date=$date, time=${stepData.dateFrom}, steps=$steps, value=$value');
        
        // Sum steps for each date (samples are incremental, not cumulative)
        stepsByDate[date] = (stepsByDate[date] ?? 0) + steps;
      }

      _log.info('Steps by date: $stepsByDate');
      return stepsByDate;
    } catch (e) {
      _log.severe('Error getting steps from HealthKit: $e');
      return {};
    }
  }

  /// Perform background sync of yesterday's activities from HealthKit
  /// This should be called daily to sync the previous day's completed workouts
  /// Returns the number of activities synced
  Future<int> syncRecentActivities(
    Future<bool> Function(String) isActivityAlreadySynced,
    Future<void> Function(UserActivityEntity, String) addActivityWithHealthKitId,
    Future<List<PhysicalActivityEntity>> Function() getAllPhysicalActivities,
  ) async {
    final hasPermissions = await _ensureActivityPermissions();
    if (!hasPermissions) {
      _log.warning('HealthKit not initialized or not authorized');
      return 0;
    }

    try {
      // Only sync yesterday's workouts (completed day)
      final startDate = DateTime.now().subtract(const Duration(days: 1));
      final endDate = DateTime.now().subtract(const Duration(days: 1));

      final workouts = await fetchWorkouts(startDate, endDate);
      _log.info('Fetched ${workouts.length} workouts from HealthKit for background sync');

      // Get all physical activities for mapping
      final physicalActivities = await getAllPhysicalActivities();
      final activityMap = {for (var pa in physicalActivities) pa.code: pa};

      int syncedCount = 0;

      for (final workout in workouts) {
        try {
          // Extract workout type from metadata - try multiple possible locations
          int? workoutType = workout.metadata?['workoutActivityType'] as int?;
          
          // Fallback: try to get from unit if metadata doesn't have it
          if (workoutType == null && workout.unit is int) {
            workoutType = workout.unit as int?;
          }
          
          // Fallback: try other common metadata keys
          workoutType ??= workout.metadata?['HKWorkoutActivityType'] as int?;
          
          // Fallback: try to get from value if it's an int (some health packages store type in value)
          if (workoutType == null && workout.value is int) {
            workoutType = workout.value as int?;
          }
          
          // Fallback: try to get from WorkoutHealthValue.workoutActivityType
          if (workoutType == null) {
            final workoutValue = workout.value as dynamic;
            if (workoutValue.toString().contains('WorkoutHealthValue')) {
              final activityType = workoutValue.workoutActivityType;
              // HealthWorkoutActivityType is an enum, convert to index
              if (activityType != null) {
                workoutType = (activityType as dynamic).index as int?;
              }
            }
          }
          
          if (workoutType == null) {
            _log.warning('Workout missing activity type, metadata: ${workout.metadata}, unit: ${workout.unit}, value: ${workout.value}, value type: ${workout.value.runtimeType}, skipping');
            continue;
          }

          // Map to activity code
          final activityCode = _mapWorkoutTypeToActivityCode(workoutType);
          final physicalActivity = activityMap[activityCode];

          if (physicalActivity == null) {
            _log.warning('No physical activity found for code: $activityCode, skipping workout');
            continue;
          }

          // Convert to UserActivityEntity
          final userActivity = convertWorkoutToUserActivity(workout, physicalActivity);
          if (userActivity == null) {
            _log.warning('Failed to convert workout to UserActivityEntity, skipping');
            continue;
          }

          // Get HealthKit workout UUID
          final healthKitWorkoutId = workout.uuid;

          // Check if already synced
          final alreadySynced = await isActivityAlreadySynced(healthKitWorkoutId);
          if (alreadySynced) {
            //_log.fine('Activity already synced: $healthKitWorkoutId, skipping');
            continue;
          }

          // Add to database with HealthKit ID
          await addActivityWithHealthKitId(userActivity, healthKitWorkoutId);
          syncedCount++;
          _log.fine('Background synced activity: ${physicalActivity.specificActivity}');
        } catch (e) {
          _log.severe('Error syncing individual workout in background: $e');
        }
      }

      _log.info('Background activity sync complete: $syncedCount synced');
      return syncedCount;
    } catch (e) {
      _log.severe('Error in background activity sync: $e');
      return 0;
    }
  }
}
