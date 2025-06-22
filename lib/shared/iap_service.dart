import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart' as iap;
import 'package:calorieai/core/data/repository/iap_repository_impl.dart';
import 'package:calorieai/core/domain/entity/iap_product.dart';
import 'dart:developer' as developer;

import 'package:calorieai/core/domain/entity/purchase_status.dart';
import 'package:calorieai/core/domain/repository/iap_repository.dart';
import 'package:calorieai/core/utils/iap_constants.dart';
import 'package:calorieai/core/utils/logger.dart';

class IAPService {
  static final IAPService _instance = IAPService._internal();
  late final IAPRepository _repository;
  bool _isInitialized = false;

  // Stream controllers
  final _purchaseStatusController =
      StreamController<PurchaseStatus>.broadcast();
  final _productsController = StreamController<List<IAPProduct>>.broadcast();

  // Getters
  Stream<PurchaseStatus> get purchaseStatusStream =>
      _purchaseStatusController.stream;
  Stream<List<IAPProduct>> get productsStream => _productsController.stream;

  factory IAPService() {
    return _instance;
  }

  IAPService._internal() {
    _repository = IAPRepositoryImpl();
  }

  // Initialize the IAP service
  Future<void> init() async {
    if (_isInitialized) return;

    await _repository.init();

    // Get the full status object
    final status = await _repository.getDetailedPurchaseStatus();
    _purchaseStatusController.add(status);

    _loadProducts();
    _isInitialized = true;
  }

  // Dispose resources
  void dispose() {
    _repository.dispose();
    _purchaseStatusController.close();
    _productsController.close();
    _isInitialized = false;
  }

  // Check if user can perform analysis
  Future<bool> canPerformAnalysis() async {
    if (!_isInitialized) await init();
    return _repository.canPerformAnalysis();
  }

  // Record that an analysis was performed
  Future<void> recordAnalysisPerformed() async {
    if (!_isInitialized) await init();
    await _repository.recordAnalysisPerformed();

    // Update status stream
    final status = await _repository.getDetailedPurchaseStatus();
    _purchaseStatusController.add(status);
  }

  // Get available products
  Future<List<IAPProduct>> getProducts() async {
    if (!_isInitialized) await init();
    return _repository.getProducts();
  }

  // Purchase a product
  Future<bool> purchaseProduct(String productId) async {
    if (!_isInitialized) await init();
    return _repository.purchaseProduct(productId);
  }

  // Restore purchases
  Future<bool> restorePurchases() async {
    if (!_isInitialized) await init();
    return _repository.restorePurchases();
  }

  // Check if recipe finder is available
  Future<bool> isRecipeFinderAvailable() async {
    if (!_isInitialized) await init();
    return _repository.hasActiveSubscription();
  }

  /// Check if the user has an active subscription
  Future<bool> hasActiveSubscription() async {
    if (!_isInitialized) await init();
    return _repository.hasActiveSubscription();
  }

  // Open the platform-specific subscription management page
  Future<bool> openSubscriptionManagement() async {
    try {
      // On iOS, this will open the App Store subscription management page
      // On Android, this will open the Play Store subscription management page
      return await _repository.openSubscriptionManagement();
    } catch (e) {
      Logger.e('Error opening subscription management', error: e);
      return false;
    }
  }

  // Get current purchase status
  Future<PurchaseStatus> getPurchaseStatus() async {
    if (!_isInitialized) await init();
    final status = await _repository.getDetailedPurchaseStatus();
    
    // Log detailed status for debugging
    _logDebugInfo(status);
    
    return status;
  }
  
  // Debug method to print current subscription status
  Future<void> logSubscriptionStatus() async {
    try {
      if (!_isInitialized) await init();
      final status = await _repository.getDetailedPurchaseStatus();
      _logDebugInfo(status);
    } catch (e, stackTrace) {
      Logger.e('Error getting subscription status', error: e, stackTrace: stackTrace);
      developer.log('❌ Error getting subscription status: $e', 
          name: 'IAPService', 
          error: e,
          stackTrace: stackTrace);
    }
  }
  
  void _logDebugInfo(PurchaseStatus status) {
    final buffer = StringBuffer();
    buffer.writeln('=== IAP Service Debug Info ===');
    buffer.writeln('• Is Subscribed: ${status.isSubscribed}');
    buffer.writeln('• Purchase State: ${status.state}');
    buffer.writeln('• Remaining Daily Analyses: ${status.remainingDailyAnalyses}');
    buffer.writeln('• Last Analysis Date: ${status.lastAnalysisDate}');
    buffer.writeln('• Can Perform Analysis: ${status.canPerformAnalysis}');
    if (status.error != null) {
      buffer.writeln('• Error: ${status.error}');
    }
    buffer.writeln('==============================');
    
    // Log to debug console
    developer.log(buffer.toString(), name: 'IAPService');
    
    // Also print to console for easier debugging
    print(buffer);
  }

  // Load products and update stream
  Future<void> _loadProducts() async {
    try {
      final products = await _repository.getProducts();
      _productsController.add(products);
    } catch (e) {
      _productsController.addError(e);
    }
  }

  // Check if IAP is available
  static Future<bool> isAvailable() async {
    return await iap.InAppPurchase.instance.isAvailable();
  }
}
