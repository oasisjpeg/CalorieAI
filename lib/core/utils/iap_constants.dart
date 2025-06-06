class IAPConstants {
  // Product IDs - These should match your products in App Store Connect and Google Play Console
  static const String premiumSubscriptionId = 'com.calorieai.subscription.premium';
  
  // Shared Preferences Keys
  static const String iapStatusKey = 'iap_status';
  static const String lastAnalysisDateKey = 'last_analysis_date';
  static const String dailyAnalysisCountKey = 'daily_analysis_count';
  static const String purchaseTokensKey = 'purchase_tokens';
  
  // Limits
  static const int dailyFreeAnalysisLimit = 3;
  
  // Messages
  static String getDailyLimitMessage(int remaining) => 
      'You have $remaining free analyses left today. Upgrade to premium for unlimited access.';
  
  static const String premiumRequiredMessage = 'This feature requires a premium subscription.';
  static const String upgradeToPremium = 'Upgrade to Premium';
  
  // Error Messages
  static const String purchaseError = 'Error processing purchase. Please try again.';
  static const String restorePurchases = 'Restore Purchases';
  static const String purchaseSuccessful = 'Thank you for upgrading to Premium!';
}
