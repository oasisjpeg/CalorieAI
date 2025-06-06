import 'package:equatable/equatable.dart';
import 'package:opennutritracker/core/utils/iap_constants.dart';

enum AppPurchaseState { notPurchased, pending, purchased, error }

class PurchaseStatus extends Equatable {
  final AppPurchaseState state;
  final bool isSubscribed;
  final int remainingDailyAnalyses;
  final DateTime? lastAnalysisDate;
  final String? error;

  const PurchaseStatus({
    this.state = AppPurchaseState.notPurchased,
    this.isSubscribed = false,
    this.remainingDailyAnalyses = IAPConstants.dailyFreeAnalysisLimit,
    this.lastAnalysisDate,
    this.error,
  });

  PurchaseStatus copyWith({
    AppPurchaseState? state,
    bool? isSubscribed,
    int? remainingDailyAnalyses,
    DateTime? lastAnalysisDate,
    String? error,
  }) {
    return PurchaseStatus(
      state: state ?? this.state,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      remainingDailyAnalyses: remainingDailyAnalyses ?? this.remainingDailyAnalyses,
      lastAnalysisDate: lastAnalysisDate ?? this.lastAnalysisDate,
      error: error ?? this.error,
    );
  }

  bool get canPerformAnalysis {
    if (isSubscribed) return true;
    if (lastAnalysisDate == null) return true;
    
    final now = DateTime.now();
    final lastDate = lastAnalysisDate!;
    
    // Reset counter if it's a new day
    if (now.year != lastDate.year || 
        now.month != lastDate.month || 
        now.day != lastDate.day) {
      return true;
    }
    
    return remainingDailyAnalyses > 0;
  }

  @override
  List<Object?> get props => [
        state,
        isSubscribed,
        remainingDailyAnalyses,
        lastAnalysisDate,
        error,
      ];
}
