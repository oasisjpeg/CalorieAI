import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:opennutritracker/core/utils/iap_constants.dart';
import 'package:opennutritracker/core/utils/secure_app_storage_provider.dart';
import 'package:opennutritracker/core/utils/logger.dart';

class IAPLocalDataSource {
  final FlutterSecureStorage _secureStorage;
  final SecureAppStorageProvider _secureAppStorageProvider;

  IAPLocalDataSource({
    FlutterSecureStorage? secureStorage,
    SecureAppStorageProvider? secureAppStorageProvider,
  })  : _secureStorage = secureStorage ?? FlutterSecureStorage(
          aOptions: SecureAppStorageProvider.androidOptions,
          iOptions: SecureAppStorageProvider.iOSOptions,
        ),
        _secureAppStorageProvider = secureAppStorageProvider ?? SecureAppStorageProvider();

  // Save purchase status
  Future<void> savePurchaseStatus(bool isSubscribed) async {
    await _secureStorage.write(
      key: IAPConstants.iapStatusKey,
      value: isSubscribed.toString(),
    );
  }

  // Get purchase status
  Future<bool> getPurchaseStatus() async {
    final status = await _secureStorage.read(key: IAPConstants.iapStatusKey);
    return status?.toLowerCase() == 'true';
  }

  // Save last analysis date
  Future<void> saveLastAnalysisDate(DateTime date) async {
    await _secureStorage.write(
      key: IAPConstants.lastAnalysisDateKey,
      value: date.toIso8601String(),
    );
  }

  // Get last analysis date
  Future<DateTime?> getLastAnalysisDate() async {
    final dateString = await _secureStorage.read(key: IAPConstants.lastAnalysisDateKey);
    if (dateString == null) return null;
    return DateTime.tryParse(dateString);
  }

  // Save daily analysis count
  Future<void> saveDailyAnalysisCount(int count) async {
    await _secureStorage.write(
      key: IAPConstants.dailyAnalysisCountKey,
      value: count.toString(),
    );
  }

  // Get daily analysis count
  Future<int> getDailyAnalysisCount() async {
    final countString = await _secureStorage.read(key: IAPConstants.dailyAnalysisCountKey);
    return int.tryParse(countString ?? '0') ?? 0;
  }

  // Reset daily analysis count
  Future<void> resetDailyAnalysisCount() async {
    await _secureStorage.write(
      key: IAPConstants.dailyAnalysisCountKey,
      value: '0',
    );
  }

  // Save purchase token for verification
  Future<void> savePurchaseToken(String productId, String token) async {
    final tokens = await _getPurchaseTokens();
    tokens[productId] = token;
    await _secureStorage.write(
      key: IAPConstants.purchaseTokensKey,
      value: jsonEncode(tokens),
    );
  }

  // Get purchase token for a product
  Future<String?> getPurchaseToken(String productId) async {
    final tokens = await _getPurchaseTokens();
    return tokens[productId];
  }

  // Get all purchase tokens
  Future<Map<String, String>> _getPurchaseTokens() async {
    try {
      final tokensJson = await _secureStorage.read(key: IAPConstants.purchaseTokensKey);
      if (tokensJson == null) return {};
      
      final Map<String, dynamic> decoded = jsonDecode(tokensJson);
      return decoded.map((key, dynamic value) => MapEntry(key, value.toString()));
    } catch (e, stackTrace) {
      Logger.e('Error reading purchase tokens', error: e, stackTrace: stackTrace);
      return {};
    }
  }

  // Clear all IAP data (for testing or logout)
  Future<void> clearAllData() async {
    await _secureStorage.deleteAll();
  }
}
