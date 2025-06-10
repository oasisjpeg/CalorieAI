import 'package:equatable/equatable.dart';
import 'package:calorieai/core/domain/entity/iap_product.dart';
import 'package:calorieai/core/domain/entity/purchase_status.dart';

class IAPState extends Equatable {
  final bool isLoading;
  final String? error;
  final bool hasPremiumAccess;
  final bool canAccessRecipeFinder;
  final bool canPerformAnalysis;
  final int remainingDailyAnalyses;
  final List<IAPProduct> availableProducts;
  final bool isPurchasing;
  final bool isRestoring;

  const IAPState({
    this.isLoading = false,
    this.error,
    this.hasPremiumAccess = false,
    this.canAccessRecipeFinder = false,
    this.canPerformAnalysis = true,
    this.remainingDailyAnalyses = 3,
    this.availableProducts = const [],
    this.isPurchasing = false,
    this.isRestoring = false,
  });

  IAPState copyWith({
    bool? isLoading,
    String? error,
    bool? hasPremiumAccess,
    bool? canAccessRecipeFinder,
    bool? canPerformAnalysis,
    int? remainingDailyAnalyses,
    List<IAPProduct>? availableProducts,
    bool? isPurchasing,
    bool? isRestoring,
  }) {
    return IAPState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasPremiumAccess: hasPremiumAccess ?? this.hasPremiumAccess,
      canAccessRecipeFinder: canAccessRecipeFinder ?? this.canAccessRecipeFinder,
      canPerformAnalysis: canPerformAnalysis ?? this.canPerformAnalysis,
      remainingDailyAnalyses: remainingDailyAnalyses ?? this.remainingDailyAnalyses,
      availableProducts: availableProducts ?? this.availableProducts,
      isPurchasing: isPurchasing ?? this.isPurchasing,
      isRestoring: isRestoring ?? this.isRestoring,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        hasPremiumAccess,
        canAccessRecipeFinder,
        canPerformAnalysis,
        remainingDailyAnalyses,
        availableProducts,
        isPurchasing,
        isRestoring,
      ];
}
