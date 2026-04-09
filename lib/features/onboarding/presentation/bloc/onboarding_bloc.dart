import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:calorieai/core/domain/entity/user_entity.dart';
import 'package:calorieai/core/domain/usecase/add_config_usecase.dart';
import 'package:calorieai/core/domain/usecase/add_user_usecase.dart';
import 'package:calorieai/core/utils/calc/modern_tdee_calc.dart';
import 'package:calorieai/core/data/repository/weight_repository.dart';
import 'package:calorieai/core/domain/entity/weight_entry_entity.dart';
import 'package:calorieai/features/onboarding/domain/entity/user_data_mask_entity.dart';

part 'onboarding_event.dart';

part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final userSelection = UserDataMaskEntity();
  final AddUserUsecase _addUserUsecase;
  final AddConfigUsecase _addConfigUsecase;
  final WeightRepository _weightRepository = WeightRepository();

  OnboardingBloc(this._addUserUsecase, this._addConfigUsecase)
      : super(OnboardingInitialState()) {
    on<LoadOnboardingEvent>((event, emit) async {
      emit(OnboardingLoadingState());

      emit(OnboardingLoadedState());
    });
  }

  void saveOnboardingData(BuildContext context, UserEntity userEntity,
      bool hasAcceptedDataCollection, bool usesImperialUnits) async {
    _addUserUsecase.addUser(userEntity);
    _addConfigUsecase
        .setConfigHasAcceptedAnonymousData(hasAcceptedDataCollection);
    _addConfigUsecase.setConfigUsesImperialUnits(usesImperialUnits);
    
    // Save user's calorie and macro adjustments if they were modified
    if (userSelection.kcalAdjustment != 0) {
      _addConfigUsecase.setConfigKcalAdjustment(userSelection.kcalAdjustment);
    }
    if (userSelection.carbGoalPct != 0.5 || 
        userSelection.proteinGoalPct != 0.25 || 
        userSelection.fatGoalPct != 0.25) {
      _addConfigUsecase.setConfigMacroGoalPct(
        userSelection.carbGoalPct,
        userSelection.proteinGoalPct,
        userSelection.fatGoalPct,
      );
    }

    // Save initial weight entry from onboarding
    final weightEntry = WeightEntryEntity(
      date: DateTime.now(),
      weightKG: userEntity.weightKG,
    );
    await _weightRepository.addWeightEntry(weightEntry);
  }

  double? getOverviewCalorieGoal() {
    final userEntity = userSelection.toUserEntity();
    double? calorieGoal;
    if (userEntity != null) {
      final tdee = ModernTDEECalc.calculateTDEE(userEntity);
      calorieGoal = ModernTDEECalc.calculateCalorieGoal(
        userEntity,
        tdee,
        userAdjustment: userSelection.kcalAdjustment,
      );
    }
    return calorieGoal;
  }

  double? getOverviewCarbsGoal() {
    final userEntity = userSelection.toUserEntity();
    final calorieGoal = getOverviewCalorieGoal();
    double? carbsGoal;
    if (userEntity != null && calorieGoal != null) {
      // Use user's macro percentages if set, otherwise use calculated distribution
      final carbsPct = userSelection.carbGoalPct;
      carbsGoal = (calorieGoal * carbsPct) / 4;
    }
    return carbsGoal;
  }

  double? getOverviewFatGoal() {
    final userEntity = userSelection.toUserEntity();
    final calorieGoal = getOverviewCalorieGoal();
    double? fatGoal;
    if (userEntity != null && calorieGoal != null) {
      // Use user's macro percentages if set, otherwise use calculated distribution
      final fatPct = userSelection.fatGoalPct;
      fatGoal = (calorieGoal * fatPct) / 9;
    }
    return fatGoal;
  }

  double? getOverviewProteinGoal() {
    final userEntity = userSelection.toUserEntity();
    final calorieGoal = getOverviewCalorieGoal();
    double? proteinGoal;
    if (userEntity != null && calorieGoal != null) {
      // Use user's macro percentages if set, otherwise use calculated distribution
      final proteinPct = userSelection.proteinGoalPct;
      proteinGoal = (calorieGoal * proteinPct) / 4;
    }
    return proteinGoal;
  }
}
