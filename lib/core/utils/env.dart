import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'FDC_API_KEY', obfuscate: true)
  static final String fdcApiKey = _Env.fdcApiKey;
  @EnviedField(varName: 'SENTRY_DNS', obfuscate: true)
  static final String sentryDns = _Env.sentryDns;
  @EnviedField(varName: 'GEMINI_API_KEY', obfuscate: true)
  static final String geminiApiKey = _Env.geminiApiKey;
  @EnviedField(varName: 'IMGBB_API_KEY', obfuscate: true)
  static final String imgbbApiKey = _Env.imgbbApiKey;
  @EnviedField(varName: 'PREMIUM_SUBSCRIPTION_ID', obfuscate: true)
  static final String premiumSubscriptionId = _Env.premiumSubscriptionId;
}
