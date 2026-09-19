part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();
}

class HomeInitial extends HomeState {
  @override
  List<Object> get props => [];
}

class HomeLoadingState extends HomeState {
  @override
  List<Object?> get props => [];
}

class HomeLoadedState extends HomeState {
  final bool showDisclaimerDialog;
  final double totalKcalDaily;
  final double totalKcalLeft;
  final double totalKcalSupplied;
  final double totalKcalBurned;
  final double totalCarbsIntake;
  final double totalFatsIntake;
  final double totalProteinsIntake;
  final double totalCarbsGoal;
  final double totalFatsGoal;
  final double totalProteinsGoal;
  final double totalSugarsIntake;
  final double totalSaturatedFatIntake;
  final double totalFiberIntake;
  final List<UserActivityEntity> userActivityList;
  final List<IntakeEntity> breakfastIntakeList;
  final List<IntakeEntity> lunchIntakeList;
  final List<IntakeEntity> dinnerIntakeList;
  final List<IntakeEntity> snackIntakeList;
  final bool usesImperialUnits;
  final int todaySteps;
  final bool showConsumedKcalAndMacros;

  const HomeLoadedState({
    required this.showDisclaimerDialog,
    required this.totalKcalDaily,
    required this.totalKcalLeft,
    required this.totalKcalSupplied,
    required this.totalKcalBurned,
    required this.totalCarbsIntake,
    required this.totalFatsIntake,
    required this.totalProteinsIntake,
    required this.totalCarbsGoal,
    required this.totalFatsGoal,
    required this.totalProteinsGoal,
    required this.totalSugarsIntake,
    required this.totalSaturatedFatIntake,
    required this.totalFiberIntake,
    required this.userActivityList,
    required this.breakfastIntakeList,
    required this.lunchIntakeList,
    required this.dinnerIntakeList,
    required this.snackIntakeList,
    required this.usesImperialUnits,
    this.todaySteps = 0,
    this.showConsumedKcalAndMacros = false,
  });

  HomeLoadedState copyWith({int? todaySteps}) {
    return HomeLoadedState(
      showDisclaimerDialog: showDisclaimerDialog,
      totalKcalDaily: totalKcalDaily,
      totalKcalLeft: totalKcalLeft,
      totalKcalSupplied: totalKcalSupplied,
      totalKcalBurned: totalKcalBurned,
      totalCarbsIntake: totalCarbsIntake,
      totalFatsIntake: totalFatsIntake,
      totalProteinsIntake: totalProteinsIntake,
      totalCarbsGoal: totalCarbsGoal,
      totalFatsGoal: totalFatsGoal,
      totalProteinsGoal: totalProteinsGoal,
      totalSugarsIntake: totalSugarsIntake,
      totalSaturatedFatIntake: totalSaturatedFatIntake,
      totalFiberIntake: totalFiberIntake,
      userActivityList: userActivityList,
      breakfastIntakeList: breakfastIntakeList,
      lunchIntakeList: lunchIntakeList,
      dinnerIntakeList: dinnerIntakeList,
      snackIntakeList: snackIntakeList,
      usesImperialUnits: usesImperialUnits,
      todaySteps: todaySteps ?? this.todaySteps,
      showConsumedKcalAndMacros: showConsumedKcalAndMacros,
    );
  }

  @override
  List<Object?> get props => [
        showDisclaimerDialog,
        totalKcalDaily,
        totalKcalLeft,
        totalKcalSupplied,
        totalKcalBurned,
        totalCarbsIntake,
        totalFatsIntake,
        totalProteinsIntake,
        totalCarbsGoal,
        totalFatsGoal,
        totalProteinsGoal,
        totalSugarsIntake,
        totalSaturatedFatIntake,
        totalFiberIntake,
        userActivityList,
        breakfastIntakeList,
        lunchIntakeList,
        dinnerIntakeList,
        snackIntakeList,
        usesImperialUnits,
        todaySteps,
        showConsumedKcalAndMacros,
      ];
}
