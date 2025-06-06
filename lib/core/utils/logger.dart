import 'package:flutter/foundation.dart';

class Logger {
  static void d(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('DEBUG: $message');
      if (error != null) {
        // ignore: avoid_print
        print('ERROR: $error');
      }
      if (stackTrace != null) {
        // ignore: avoid_print
        print('STACKTRACE: $stackTrace');
      }
    }
  }

  static void e(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('ERROR: $message');
      if (error != null) {
        // ignore: avoid_print
        print('ERROR DETAILS: $error');
      }
      if (stackTrace != null) {
        // ignore: avoid_print
        print('STACKTRACE: $stackTrace');
      }
    }
    // In production, you might want to send errors to a crash reporting service
    // like Firebase Crashlytics or Sentry
  }

  static void i(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('INFO: $message');
    }
  }

  static void w(String message, {Object? error}) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('WARNING: $message');
      if (error != null) {
        // ignore: avoid_print
        print('WARNING DETAILS: $error');
      }
    }
  }
}
