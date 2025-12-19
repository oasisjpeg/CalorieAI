import 'package:calorieai/core/utils/env.dart';

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
  
  // Developer device whitelist - Add device identifiers here to always have premium
  // To get your device ID, run the app once and check the debug logs
  static const List<String> developerDeviceWhitelist = [
    'D91C8299-9016-4D3E-9307-5DC14E39190A', // Development build
    '6971DE43-7034-4DE6-B09C-3178E7B6402F', // TestFlight build
    // Add your TestFlight device ID here after checking logs
  ];
  
}
