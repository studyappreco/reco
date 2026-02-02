import 'package:logger/logger.dart';

// https://pub.dev/packages/logger#-readme-tab-

class Log {
  // Logger configuration (I took it from the readme, we can adjust it if desired)
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    // Disable logging in Release Mode
    // https://api.flutter.dev/flutter/foundation/kReleaseMode-constant.html
    // https://codehubjournal.com/mastering-logging-in-flutter-from-print-to-logger/
    level: bool.fromEnvironment('dart.vm.product') ? Level.off : Level.all,
  );

  static void trace(dynamic message) {
    _logger.t(message);
  }

  // use during development to diagnose issues
  static void debug(dynamic message) {
    _logger.d(message);
  }

  static void info(dynamic message) {
    _logger.i(message);
  }

  // use for unexpected situations where the app can still continue
  static void warning(dynamic message) {
    _logger.w(message);
  }

  // use for exceptions and logic failures (Try-Catch blocks)
  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  // use for critical system failures
  static void fatal(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }
}
