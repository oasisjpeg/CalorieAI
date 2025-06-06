import 'dart:async';

import 'package:opennutritracker/core/domain/entity/iap_product.dart';
import 'package:opennutritracker/core/domain/entity/purchase_status.dart'
    as iap_entity;

/// Interface for handling in-app purchases and subscription management.
/// This repository provides methods to interact with the app's in-app purchase system.
abstract class IAPRepository {
  /// Initializes the IAP service and loads available products.
  /// Should be called when the app starts.
  Future<void> init();

  /// Disposes of resources used by the IAP service.
  /// Should be called when the app is shutting down.
  void dispose();

  /// Checks if the user has an active subscription.
  /// Returns `true` if the user has an active subscription, `false` otherwise.
  Future<bool> hasActiveSubscription();

  /// Retrieves a list of available IAP products.
  /// Returns a list of [IAPProduct] objects.
  Future<List<IAPProduct>> getProducts();

  /// Initiates the purchase flow for a specific product.
  ///
  /// [productId] - The ID of the product to purchase.
  /// Returns `true` if the purchase was successful, `false` otherwise.
  Future<bool> purchaseProduct(String productId);

  /// Restores previous purchases made by the user.
  /// This is typically used when the user reinstalls the app or switches devices.
  /// Returns `true` if the restoration was successful, `false` otherwise.
  Future<bool> restorePurchases();

  /// Checks if the user can perform an analysis, respecting daily limits.
  /// Returns `true` if the user can perform an analysis, `false` otherwise.
  Future<bool> canPerformAnalysis();

  /// Records that an analysis was performed.
  /// Updates the daily analysis count and last analysis date.
  Future<void> recordAnalysisPerformed();

  /// Gets the current purchase status, including subscription state and usage limits.
  /// Returns a [AppPurchaseState] object containing the current status.
  Future<iap_entity.AppPurchaseState> getPurchaseStatus();

  /// Saves a purchase token for a specific product.
  ///
  /// [productId] - The ID of the product.
  /// [token] - The purchase token to save.
  Future<void> savePurchaseToken(String productId, String token);

  /// Gets the purchase token for a specific product.
  ///
  /// [productId] - The ID of the product.
  /// Returns the purchase token, or `null` if not found.
  Future<String?> getPurchaseToken(String productId);

  /// Gets the remaining number of analyses the user can perform today.
  /// Returns the number of remaining analyses.
  Future<int> getRemainingDailyAnalyses();

  /// Resets the daily analysis count.
  /// Typically called at midnight or when the day changes.
  Future<void> resetDailyAnalysisCount();

  Future<iap_entity.PurchaseStatus> getDetailedPurchaseStatus();
}
