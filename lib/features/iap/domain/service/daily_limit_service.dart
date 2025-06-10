// lib/features/iap/domain/service/daily_limit_service.dart
import 'package:calorieai/core/data/datasource/local/iap_local_data_source.dart';
import 'package:calorieai/core/utils/iap_constants.dart';

class DailyLimitService {
  final IAPLocalDataSource _localDataSource;
  final int _dailyLimit;

  DailyLimitService({
    required IAPLocalDataSource localDataSource,
    int dailyLimit = IAPConstants.dailyFreeAnalysisLimit,
  })  : _localDataSource = localDataSource,
        _dailyLimit = dailyLimit;

  Future<bool> canPerformAnalysis() async {
    final isPremium = await _localDataSource.getPurchaseStatus();
    if (isPremium) return true;

    final lastDate = await _localDataSource.getLastAnalysisDate();
    final today = DateTime.now();
    final isNewDay = lastDate == null || 
        lastDate.year != today.year ||
        lastDate.month != today.month ||
        lastDate.day != today.day;

    if (isNewDay) {
      await _localDataSource.saveDailyAnalysisCount(0);
      await _localDataSource.saveLastAnalysisDate(today);
      return true;
    }

    final count = await _localDataSource.getDailyAnalysisCount();
    return count < _dailyLimit;
  }

  Future<int> getRemainingUses() async {
    final isPremium = await _localDataSource.getPurchaseStatus();
    if (isPremium) return -1; // Unlimited

    final lastDate = await _localDataSource.getLastAnalysisDate();
    final today = DateTime.now();
    final isNewDay = lastDate == null || 
        lastDate.year != today.year ||
        lastDate.month != today.month ||
        lastDate.day != today.day;

    if (isNewDay) {
      return _dailyLimit;
    }

    final count = await _localDataSource.getDailyAnalysisCount();
    return _dailyLimit - count;
  }

  Future<void> recordAnalysis() async {
    final count = await _localDataSource.getDailyAnalysisCount();
    await _localDataSource.saveDailyAnalysisCount(count + 1);
    await _localDataSource.saveLastAnalysisDate(DateTime.now());
  }

  /// Resets the daily analysis counter to 0 and updates the last analysis date to now.
  /// This is typically used for testing and debugging purposes.
  Future<void> resetCounter() async {
    await _localDataSource.saveDailyAnalysisCount(0);
    await _localDataSource.saveLastAnalysisDate(DateTime.now());
  }
}