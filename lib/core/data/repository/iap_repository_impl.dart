import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart' as iap;
import 'package:url_launcher/url_launcher.dart';
import 'package:calorieai/core/data/datasource/local/iap_local_data_source.dart';
import 'package:calorieai/core/domain/entity/iap_product.dart';
import 'package:calorieai/core/domain/entity/purchase_status.dart';
import 'package:calorieai/core/domain/entity/purchase_status.dart'
    as iap_entity;
import 'package:calorieai/core/domain/repository/iap_repository.dart';
import 'package:calorieai/core/utils/iap_constants.dart';

class IAPRepositoryImpl implements IAPRepository {
  final IAPLocalDataSource _localDataSource;
  final iap.InAppPurchase _inAppPurchase;

  StreamSubscription<List<iap.PurchaseDetails>>? _subscription;
  final List<String> _productIds = [IAPConstants.premiumSubscriptionId];
  final Map<String, iap.ProductDetails> _products = {};
  final StreamController<PurchaseStatus> _purchaseStatusController =
      StreamController<PurchaseStatus>.broadcast();

  IAPRepositoryImpl({
    IAPLocalDataSource? localDataSource,
    iap.InAppPurchase? inAppPurchase,
  })  : _localDataSource = localDataSource ?? IAPLocalDataSource(),
        _inAppPurchase = inAppPurchase ?? iap.InAppPurchase.instance;

  @override
  Future<void> init() async {
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      return;
    }

    await _inAppPurchase.restorePurchases().timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw TimeoutException('Restoring purchases timed out');
      },
    );

    _subscription = _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (error) {
        _purchaseStatusController.addError(error);
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _purchaseStatusController.close();
  }

  @override
  Future<bool> hasActiveSubscription() async {
    return await _localDataSource.getPurchaseStatus();
  }

  @override
  Future<List<IAPProduct>> getProducts() async {
    if (_products.isEmpty) {
      final iap.ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(Set.from(_productIds));

      if (response.notFoundIDs.isNotEmpty) {
        print('Missing product IDs: ${response.notFoundIDs}');
      }

      for (var product in response.productDetails) {
        _products[product.id] = product;
      }
    }

    return _products.values
        .map((product) => IAPProduct(
              id: product.id,
              title: product.title,
              description: product.description,
              price: product.price,
              currencyCode: product.currencyCode,
              rawPrice: product.rawPrice,
            ))
        .toList();
  }

  @override
  Future<bool> purchaseProduct(String productId) async {
    if (!_products.containsKey(productId)) {
      await getProducts();
      if (!_products.containsKey(productId)) {
        throw Exception('Product not found');
      }
    }

    final iap.ProductDetails productDetails = _products[productId]!;
    final iap.PurchaseParam purchaseParam =
        iap.PurchaseParam(productDetails: productDetails);

    try {
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      return true;
    } catch (e) {
      print('Purchase error: $e');
      return false;
    }
  }

  @override
  Future<bool> restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
      return true;
    } catch (e) {
      print('Restore purchases error: $e');
      return false;
    }
  }

  @override
  Future<bool> canPerformAnalysis() async {
    final isSubscribed = await hasActiveSubscription();
    if (isSubscribed) return true;

    final lastDate = await _localDataSource.getLastAnalysisDate();
    if (lastDate == null) return true;

    final now = DateTime.now();
    if (now.year != lastDate.year ||
        now.month != lastDate.month ||
        now.day != lastDate.day) {
      await _localDataSource.saveDailyAnalysisCount(0);
      return true;
    }

    final count = await _localDataSource.getDailyAnalysisCount();
    return count < IAPConstants.dailyFreeAnalysisLimit;
  }

  @override
  Future<void> recordAnalysisPerformed() async {
    final now = DateTime.now();
    final lastDate = await _localDataSource.getLastAnalysisDate();

    int newCount;
    if (lastDate == null ||
        now.year != lastDate.year ||
        now.month != lastDate.month ||
        now.day != lastDate.day) {
      newCount = 1;
    } else {
      final currentCount = await _localDataSource.getDailyAnalysisCount();
      newCount = currentCount + 1;
    }

    await _localDataSource.saveLastAnalysisDate(now);
    await _localDataSource.saveDailyAnalysisCount(newCount);
  }

  @override
  Future<iap_entity.AppPurchaseState> getPurchaseStatus() async {
    final isSubscribed = await hasActiveSubscription();

    if (isSubscribed) {
      return iap_entity.AppPurchaseState.purchased;
    }

    // You can add more logic here to determine other states
    // For example, check if there are pending purchases, errors, etc.
    return iap_entity.AppPurchaseState.notPurchased;
  }

  void _handlePurchaseUpdate(List<iap.PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == iap.PurchaseStatus.pending) {
        _purchaseStatusController.add(
            const PurchaseStatus(state: iap_entity.AppPurchaseState.pending));
      } else {
        if (purchaseDetails.status == iap.PurchaseStatus.error) {
          _purchaseStatusController.add(PurchaseStatus(
            state: iap_entity.AppPurchaseState.error,
            error: purchaseDetails.error?.message ?? 'Purchase error',
          ));
        } else if (purchaseDetails.status == iap.PurchaseStatus.purchased ||
            purchaseDetails.status == iap.PurchaseStatus.restored) {
          _localDataSource.savePurchaseStatus(true);
          _purchaseStatusController.add(const PurchaseStatus(
            state: iap_entity.AppPurchaseState.purchased,
            isSubscribed: true,
          ));
        }

        if (purchaseDetails.pendingCompletePurchase) {
          _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  @override
  Future<String?> getPurchaseToken(String productId) async {
    return await _localDataSource.getPurchaseToken(productId);
  }

  @override
  Future<bool> openSubscriptionManagement() async {
    try {
      // On iOS, try to open the subscription management in the App Store
      if (Platform.isIOS) {
        // Try to open the App Store subscription management directly
        const url = 'https://apps.apple.com/account/subscriptions';
        if (await canLaunchUrl(Uri.parse(url))) {
          return await launchUrl(
            Uri.parse(url),
            mode: LaunchMode.externalApplication,
          );
        }
      }
      // On Android, try to open the Play Store subscription management
      else if (Platform.isAndroid) {
        // Try to open the Play Store subscription management
        const url = 'https://play.google.com/store/account/subscriptions';
        if (await canLaunchUrl(Uri.parse(url))) {
          return await launchUrl(
            Uri.parse(url),
            mode: LaunchMode.externalApplication,
          );
        }
      }
      
      // Fallback: Open the app store page where user can manage subscriptions
      if (_products.isNotEmpty) {
        // Use the product ID to create a store URL
        final storeUrl = Platform.isIOS
            ? 'https://apps.apple.com/account/subscriptions'
            : 'https://play.google.com/store/account/subscriptions';
            
        if (await canLaunchUrl(Uri.parse(storeUrl))) {
          return await launchUrl(
            Uri.parse(storeUrl),
            mode: LaunchMode.externalApplication,
          );
        }
      }
      
      return false;
    } catch (e) {
      debugPrint('Error opening subscription management: $e');
      return false;
    }
  }

  @override
  Future<int> getRemainingDailyAnalyses() async {
    final isSubscribed = await hasActiveSubscription();
    if (isSubscribed) return -1; // Unlimited for subscribers

    final lastDate = await _localDataSource.getLastAnalysisDate();
    if (lastDate == null) return IAPConstants.dailyFreeAnalysisLimit;

    final now = DateTime.now();
    if (now.year != lastDate.year ||
        now.month != lastDate.month ||
        now.day != lastDate.day) {
      return IAPConstants.dailyFreeAnalysisLimit; // New day, full limit
    }

    final count = await _localDataSource.getDailyAnalysisCount();
    return (IAPConstants.dailyFreeAnalysisLimit - count)
        .clamp(0, IAPConstants.dailyFreeAnalysisLimit);
  }

  @override
  Future<void> resetDailyAnalysisCount() async {
    await _localDataSource.resetDailyAnalysisCount();
  }

  @override
  Future<void> savePurchaseToken(String productId, String token) async {
    await _localDataSource.savePurchaseToken(productId, token);
  }

  @override
  Future<PurchaseStatus> getDetailedPurchaseStatus() async {
    final isSubscribed = await hasActiveSubscription();
    final lastDate = await _localDataSource.getLastAnalysisDate();
    final count = await _localDataSource.getDailyAnalysisCount();

    // Determine the purchase state based on subscription status
    iap_entity.AppPurchaseState state;
    if (isSubscribed) {
      state = iap_entity.AppPurchaseState.purchased;
    } else {
      state = iap_entity.AppPurchaseState.notPurchased;
    }

    return PurchaseStatus(
      state: state,
      isSubscribed: isSubscribed,
      lastAnalysisDate: lastDate,
      remainingDailyAnalyses: (IAPConstants.dailyFreeAnalysisLimit - count)
          .clamp(0, IAPConstants.dailyFreeAnalysisLimit),
    );
  }
}
