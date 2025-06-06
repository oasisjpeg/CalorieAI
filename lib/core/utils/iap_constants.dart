import 'package:opennutritracker/core/utils/env.dart';

class IAPConstants {
  // Product IDs - These should match your products in App Store Connect and Google Play Console
  static String premiumSubscriptionId = Env.premiumSubscriptionId;
  
  // Shared Preferences Keys
  static const String iapStatusKey = 'iap_status';
  static const String lastAnalysisDateKey = 'last_analysis_date';
  static const String dailyAnalysisCountKey = 'daily_analysis_count';
  static const String purchaseTokensKey = 'purchase_tokens';
  
  // Limits
  static const int dailyFreeAnalysisLimit = 3;
  
}
