import 'package:flutter/foundation.dart';
import 'package:tolgee/src/logger/log_level.dart';

/// Logger for Tolgee SDK
class TolgeeLogger {
  LogLevel _logLevel = LogLevel.none;

  /// Log function
  ///
  /// Default is [print] in debug mode, null in release mode.
  ValueSetter<String>? _logFunction = kDebugMode ? print : null;

  /// Private constructor
  TolgeeLogger._();

  /// Singleton instance
  static final TolgeeLogger _instance = TolgeeLogger._();

  /// Sets logging function
  ///
  /// Default is [print] in debug mode, null in release mode.
  static void setLog(ValueSetter<String> log) {
    TolgeeLogger._instance._logFunction = log;
  }

  /// Sets log level
  ///
  /// Default is [LogLevel.none]
  static void setLogLevel(LogLevel logLevel) {
    TolgeeLogger._instance._logLevel = logLevel;
  }

  /// Logs message
  static void _log(String message, LogLevel minLevel) {
    final logFunction = TolgeeLogger._instance._logFunction;
    final logLevel = TolgeeLogger._instance._logLevel;

    if (logFunction != null && minLevel.index >= logLevel.index) {
      logFunction(message);
    }
  }

  /// Logs debug message
  static void debug(String message) {
    _log(message, LogLevel.debug);
  }

  /// Logs info message
  static void info(String message) {
    _log(message, LogLevel.info);
  }

  /// Logs warning message
  static void warning(String message) {
    _log(message, LogLevel.warning);
  }

  /// Logs error message
  static void error(String message) {
    _log(message, LogLevel.error);
  }

  /// Logs critical message
  static void critical(String message) {
    _log(message, LogLevel.critical);
  }
}
