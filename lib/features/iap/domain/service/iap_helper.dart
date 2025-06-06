import 'package:flutter/material.dart';
import 'package:opennutritracker/features/iap/domain/service/daily_limit_service.dart';
import 'package:opennutritracker/features/iap/presentation/bloc/iap_bloc.dart';
import 'package:opennutritracker/features/iap/presentation/bloc/iap_event.dart';
import 'package:opennutritracker/features/iap/presentation/widgets/out_of_limits_dialog.dart';
import 'package:opennutritracker/features/iap/presentation/widgets/premium_feature_locked_dialog.dart';

class IAPHelper {
  final BuildContext context;
  final IAPBloc iapBloc;
  final DailyLimitService dailyLimitService;

  IAPHelper({
    required this.context,
    required this.iapBloc,
    required this.dailyLimitService,
  });

  /// Checks if the user can perform an analysis, showing a dialog if needed
  /// Returns true if the user can proceed, false otherwise
  Future<bool> checkAnalysisLimit() async {
    final canPerform = await dailyLimitService.canPerformAnalysis();
    if (!canPerform) {
      final remaining = await dailyLimitService.getRemainingUses();
      await OutOfLimitsDialog.show(context, remaining);
      return false;
    }
    return true;
  }

  /// Checks if a premium feature is available, showing a dialog if not
  /// Returns true if the feature is available, false otherwise
  Future<bool> checkPremiumFeature(String featureName) async {
    final state = iapBloc.state;
    if (!state.hasPremiumAccess) {
      final result = await PremiumFeatureLockedDialog.show(context, featureName);
      return result == true;
    }
    return true;
  }

  /// Records that an analysis was performed
  Future<void> recordAnalysis() async {
    await dailyLimitService.recordAnalysis();
  }

  /// Gets the remaining number of free analyses
  Future<int> getRemainingAnalyses() async {
    return await dailyLimitService.getRemainingUses();
  }

  /// Refreshes the IAP status
  void refreshIAPStatus() {
    iapBloc.add(const LoadIAPStatus());
  }
}
