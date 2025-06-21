import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:calorieai/core/data/datasource/local/iap_local_data_source.dart';
import 'package:calorieai/core/domain/entity/iap_product.dart';
import 'package:calorieai/core/domain/entity/purchase_status.dart';
import 'package:calorieai/features/iap/domain/service/daily_limit_service.dart';
import 'package:calorieai/shared/iap_service.dart';
import 'package:calorieai/features/iap/presentation/bloc/iap_event.dart';
import 'package:calorieai/features/iap/presentation/bloc/iap_state.dart';

class IAPBloc extends Bloc<IAPEvent, IAPState> {
  final IAPService _iapService = IAPService();
  final DailyLimitService _dailyLimitService;
  
  StreamSubscription<PurchaseStatus>? _purchaseStatusSubscription;
  StreamSubscription<List<IAPProduct>>? _productsSubscription;
  StreamSubscription<bool>? _purchaseStatusChangeSubscription;

  IAPBloc({
    DailyLimitService? dailyLimitService,
  }) : _dailyLimitService = dailyLimitService ?? DailyLimitService(
          localDataSource: IAPLocalDataSource(),
        ),
        super(const IAPState()) {
    on<LoadIAPStatus>(_onLoadIAPStatus);
    on<PurchaseProduct>(_onPurchaseProduct);
    on<RestorePurchases>(_onRestorePurchases);
    on<CheckAnalysisAccess>(_onCheckAnalysisAccess);
    on<RecordAnalysisPerformed>(_onRecordAnalysisPerformed);
    on<CheckRecipeFinderAccess>(_onCheckRecipeFinderAccess);
    on<ResetAnalysisCounter>(_onResetAnalysisCounter);
    
    // Initialize the service
    _initialize();
  }

  Future<void> _initialize() async {
    await _iapService.init();
    
    // Listen to purchase status changes
    _purchaseStatusSubscription = _iapService.purchaseStatusStream.listen(
      (status) {
        add(const LoadIAPStatus());
      },
      onError: (error) {
        add(LoadIAPStatus());
      },
    );
    
    // Listen to product updates
    _productsSubscription = _iapService.productsStream.listen(
      (products) {
        add(const LoadIAPStatus());
      },
      onError: (error) {
        add(LoadIAPStatus());
      },
    );
    
    // Initial load
    add(const LoadIAPStatus());
  }

  Future<void> _onLoadIAPStatus(
    LoadIAPStatus event,
    Emitter<IAPState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final status = await _iapService.getPurchaseStatus();
      final products = await _iapService.getProducts();
      final remainingUses = await _dailyLimitService.getRemainingUses();
      
      emit(state.copyWith(
        isLoading: false,
        hasPremiumAccess: status.isSubscribed,
        availableProducts: products,
        canAccessRecipeFinder: status.isSubscribed,
        canPerformAnalysis: status.isSubscribed || (remainingUses > 0),
        remainingDailyAnalyses: remainingUses,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onPurchaseProduct(
    PurchaseProduct event,
    Emitter<IAPState> emit,
  ) async {
    emit(state.copyWith(
      isPurchasing: true,
      showSuccessScreen: false,
      error: null,
    ));
    
    try {
      final success = await _iapService.purchaseProduct(event.productId);
      
      if (success) {
        // Update state to reflect successful purchase
        emit(state.copyWith(
          isPurchasing: false,
          showSuccessScreen: true,
          hasPremiumAccess: true,
          canAccessRecipeFinder: true,
          canPerformAnalysis: true,
        ));
        
        // After showing success, reset the flag
        await Future.delayed(const Duration(milliseconds: 100));
        emit(state.copyWith(showSuccessScreen: false));
      } else {
        emit(state.copyWith(
          isPurchasing: false,
          error: 'Purchase was not successful. Please try again.',
        ));
      }
    } on PlatformException catch (e) {
      if (e.code == 'storekit2_purchase_pending') {
        // Handle pending purchase - the purchase will complete asynchronously
        emit(state.copyWith(
          isPurchasing: false,
          error: 'Your purchase is being processed. You will be notified when it completes.',
        ));
        return;
      }
      // Re-throw other platform exceptions with a user-friendly message
      emit(state.copyWith(
        isPurchasing: false,
        error: 'Purchase failed: ${e.message}',
      ));
    } catch (e) {
      // Handle any other exceptions
      emit(state.copyWith(
        isPurchasing: false,
        error: 'An unexpected error occurred. Please try again.',
      ));
    }
  }

  Future<void> _onRestorePurchases(
    RestorePurchases event,
    Emitter<IAPState> emit,
  ) async {
    try {
      emit(state.copyWith(isRestoring: true));
      
      final success = await _iapService.restorePurchases();
      
      if (!success) {
        emit(state.copyWith(
          isRestoring: false,
          error: 'Failed to restore purchases',
        ));
        return;
      }
      
      // Status will be updated via the stream
    } catch (e) {
      emit(state.copyWith(
        isRestoring: false,
        error: 'Restore error: $e',
      ));
    }
  }

  Future<void> _onCheckAnalysisAccess(
    CheckAnalysisAccess event,
    Emitter<IAPState> emit,
  ) async {
    try {
      final canPerform = await _dailyLimitService.canPerformAnalysis();
      final remainingUses = await _dailyLimitService.getRemainingUses();
      
      emit(state.copyWith(
        canPerformAnalysis: canPerform,
        remainingDailyAnalyses: remainingUses,
      ));
    } catch (e) {
emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onRecordAnalysisPerformed(
    RecordAnalysisPerformed event,
    Emitter<IAPState> emit,
  ) async {
    try {
      await _dailyLimitService.recordAnalysis();
      final remainingUses = await _dailyLimitService.getRemainingUses();
      
      emit(state.copyWith(
        remainingDailyAnalyses: remainingUses,
        canPerformAnalysis: remainingUses > 0 || state.hasPremiumAccess,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      emit(state.copyWith(error: 'Failed to record analysis: $e'));
    }
  }

  Future<void> _onCheckRecipeFinderAccess(
    CheckRecipeFinderAccess event,
    Emitter<IAPState> emit,
  ) async {
    try {
      final hasAccess = await _dailyLimitService.canPerformAnalysis();
      emit(state.copyWith(canAccessRecipeFinder: hasAccess));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to check recipe finder access: $e'));
    }
  }

  Future<void> _onResetAnalysisCounter(
    ResetAnalysisCounter event,
    Emitter<IAPState> emit,
  ) async {
    try {
      // Reset the counter to 0 and update the last analysis date
      await _dailyLimitService.resetCounter();
      
      // Get the updated remaining uses (should be the daily limit)
      final remainingUses = await _dailyLimitService.getRemainingUses();
      
      // Update the state
      emit(state.copyWith(
        canPerformAnalysis: state.hasPremiumAccess || (remainingUses > 0),
        remainingDailyAnalyses: remainingUses,
      ));
    } catch (e) {
      // Log the error but don't crash
      emit(state.copyWith(error: 'Error resetting analysis counter: $e'));
      rethrow;
    }
  }

  @override
  Future<void> close() {
    _purchaseStatusSubscription?.cancel();
    _productsSubscription?.cancel();
    _purchaseStatusChangeSubscription?.cancel();
    _iapService.dispose();
    return super.close();
  }
}
