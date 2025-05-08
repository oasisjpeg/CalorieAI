import 'dart:io' show Platform;
import 'package:package_info_plus/package_info_plus.dart';

class AppConst {
  static const userAgentAppName = "CalorieAI";
  static const platformNameAndroid = "Android";
  static const platformNameIOS = "iOS";
  static const reportErrorEmail = "marc.reutz@pm.me";
  static const sourceCodeUrl =
      "https://github.com/oasisjpeg/CalorieAI";

  static Future<String> getVersionNumber() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  static String getPlatformName() {
    if (Platform.isAndroid) {
      return platformNameAndroid;
    } else if (Platform.isIOS) {
      return platformNameIOS;
    } else {
      return "";
    }
  }

  static Future<String> getUserAgentString() async {
    final versionNumber = await getVersionNumber();
    final platformVersion = getPlatformName();
    return '$userAgentAppName - $platformVersion - Version $versionNumber - $sourceCodeUrl';
  }
}
