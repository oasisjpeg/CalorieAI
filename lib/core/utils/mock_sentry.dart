// This is a mock implementation of Sentry to allow the app to run on iOS simulator
// without the actual Sentry dependency

class Sentry {
  static void captureException(dynamic exception, {StackTrace? stackTrace}) {
    // Do nothing, just a mock implementation
    print('MOCK SENTRY: Exception captured: $exception');
  }

  static Future<void> close() async {
    // Do nothing, just a mock implementation
    print('MOCK SENTRY: Closed');
  }
}
