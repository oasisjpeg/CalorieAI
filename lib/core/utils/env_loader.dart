import 'package:flutter/services.dart' show rootBundle;
import 'package:logging/logging.dart';

class EnvLoader {
  static final _log = Logger('EnvLoader');
  static Map<String, String>? _envMap;

  static Future<Map<String, String>> _loadEnv() async {
    if (_envMap != null) return _envMap!;
    try {
      final envString = await rootBundle.loadString('.env');
      final map = <String, String>{};
      for (final line in envString.split('\n')) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
        final eq = trimmed.indexOf('=');
        if (eq == -1) continue;
        final key = trimmed.substring(0, eq).trim();
        var value = trimmed.substring(eq + 1).trim();
        // Remove surrounding quotes
        if (value.length >= 2 &&
            ((value.startsWith('"') && value.endsWith('"')) ||
                (value.startsWith("'") && value.endsWith("'")))) {
          value = value.substring(1, value.length - 1);
        }
        map[key] = value;
      }
      _envMap = map;
      return map;
    } catch (e) {
      _log.warning('Failed to load .env from assets: $e');
      return {};
    }
  }

  static Future<String?> get(String key) async {
    final env = await _loadEnv();
    return env[key];
  }

  static void clearCache() => _envMap = null;
}
