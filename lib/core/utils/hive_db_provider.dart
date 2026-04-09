import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:calorieai/core/data/data_source/user_activity_dbo.dart';
import 'package:calorieai/core/data/dbo/app_theme_dbo.dart';
import 'package:calorieai/core/data/dbo/config_dbo.dart';
import 'package:calorieai/core/data/dbo/intake_dbo.dart';
import 'package:calorieai/core/data/dbo/intake_type_dbo.dart';
import 'package:calorieai/core/data/dbo/physical_activity_dbo.dart';
import 'package:calorieai/core/data/dbo/meal_dbo.dart';
import 'package:calorieai/core/data/dbo/meal_nutriments_dbo.dart';
import 'package:calorieai/core/data/dbo/saved_recipe_dbo.dart';
import 'package:calorieai/core/data/dbo/tracked_day_dbo.dart';
import 'package:calorieai/core/data/dbo/user_dbo.dart';
import 'package:calorieai/core/data/dbo/user_gender_dbo.dart';
import 'package:calorieai/core/data/dbo/user_pal_dbo.dart';
import 'package:calorieai/core/data/dbo/user_weight_goal_dbo.dart';
import 'package:calorieai/core/data/dbo/weight_entry_dbo.dart';
import 'package:calorieai/core/data/dbo/water_entry_dbo.dart';
import 'package:calorieai/core/data/repository/weight_repository.dart';
import 'package:calorieai/core/domain/entity/weight_entry_entity.dart';
import 'package:calorieai/features/fasting_timer/domain/entity/fasting_schedule_entity.dart';

class HiveDBProvider extends ChangeNotifier {
  static const configBoxName = 'ConfigBox';
  static const intakeBoxName = 'IntakeBox';
  static const userActivityBoxName = 'UserActivityBox';
  static const userBoxName = 'UserBox';
  static const trackedDayBoxName = 'TrackedDayBox';
  static const fastingTimerBoxName = 'FastingTimerBox';

  late Box<ConfigDBO> configBox;
  late Box<IntakeDBO> intakeBox;
  late Box<UserActivityDBO> userActivityBox;
  late Box<UserDBO> userBox;
  late Box<TrackedDayDBO> trackedDayBox;
  late Box<FastingScheduleEntity> fastingTimerBox;

  Future<void> initHiveDB(Uint8List encryptionKey) async {
    final encryptionCypher = HiveAesCipher(encryptionKey);
    await Hive.initFlutter();
    Hive.registerAdapter(ConfigDBOAdapter());
    Hive.registerAdapter(IntakeDBOAdapter());
    Hive.registerAdapter(MealDBOAdapter());
    Hive.registerAdapter(MealNutrimentsDBOAdapter());
    Hive.registerAdapter(MealSourceDBOAdapter());
    Hive.registerAdapter(IntakeTypeDBOAdapter());
    Hive.registerAdapter(UserDBOAdapter());
    Hive.registerAdapter(UserGenderDBOAdapter());
    Hive.registerAdapter(UserWeightGoalDBOAdapter());
    Hive.registerAdapter(UserPALDBOAdapter());
    Hive.registerAdapter(TrackedDayDBOAdapter());
    Hive.registerAdapter(UserActivityDBOAdapter());
    Hive.registerAdapter(PhysicalActivityDBOAdapter());
    Hive.registerAdapter(PhysicalActivityTypeDBOAdapter());
    Hive.registerAdapter(AppThemeDBOAdapter());
    Hive.registerAdapter(SavedRecipeDBOAdapter());
    Hive.registerAdapter(FastingScheduleEntityAdapter());
    Hive.registerAdapter(WeightEntryDBOAdapter());
    Hive.registerAdapter(WaterEntryDBOAdapter());

    configBox =
        await Hive.openBox(configBoxName, encryptionCipher: encryptionCypher);
    
    intakeBox =
        await Hive.openBox(intakeBoxName, encryptionCipher: encryptionCypher);
    userActivityBox = await Hive.openBox(userActivityBoxName,
        encryptionCipher: encryptionCypher);
    userBox =
        await Hive.openBox(userBoxName, encryptionCipher: encryptionCypher);
    trackedDayBox = await Hive.openBox(trackedDayBoxName,
        encryptionCipher: encryptionCypher);
    fastingTimerBox = await Hive.openBox(fastingTimerBoxName,
        encryptionCipher: encryptionCypher);
    
    // Migrate onboarding weight to weight tracker if weight entries are empty
    await _migrateOnboardingWeightToWeightTracker();
  }

  static generateNewHiveEncryptionKey() => Hive.generateSecureKey();

  Future<void> _migrateOnboardingWeightToWeightTracker() async {
    try {
      // Get user from already opened userBox using the correct key
      final user = userBox.get('UserKey');
      
      if (user != null) {
        print('Migration: Found user with weight ${user.weightKG}kg');
        
        // Check if weight entries exist by trying to get them
        final weightRepository = WeightRepository();
        final weightEntries = await weightRepository.getAllWeightEntries();
        
        print('Migration: Found ${weightEntries.length} weight entries');
        
        // If no weight entries exist, create one from onboarding weight
        if (weightEntries.isEmpty) {
          print('Migration: No weight entries found, creating from onboarding weight');
          final weightEntry = WeightEntryEntity(
            date: DateTime.now(),
            weightKG: user.weightKG,
          );
          await weightRepository.addWeightEntry(weightEntry);
          print('Migration: Successfully added onboarding weight');
        } else {
          print('Migration: Weight entries already exist, skipping migration');
        }
      } else {
        print('Migration: No user found, skipping migration');
      }
    } catch (e) {
      // Migration failed, log but don't crash the app
      print('Failed to migrate onboarding weight: $e');
    }
  }
}
