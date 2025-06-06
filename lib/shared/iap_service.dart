import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart' as iap;
import 'package:opennutritracker/core/data/repository/iap_repository_impl.dart';
import 'package:opennutritracker/core/domain/entity/iap_product.dart';
import 'package:opennutritracker/core/domain/entity/purchase_status.dart';
import 'package:opennutritracker/core/domain/repository/iap_repository.dart';
import 'package:opennutritracker/core/utils/iap_constants.dart';

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

  // Get current purchase status
  Future<PurchaseStatus> getPurchaseStatus() async {
    if (!_isInitialized) await init();
    return _repository.getDetailedPurchaseStatus();
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
