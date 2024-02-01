import 'package:flutter/foundation.dart';

/// Logger for Tolgee SDK
class TolgeeLogger {
  /// Log function
  ValueSetter<String>? _log;

  /// Private constructor
  TolgeeLogger._();

  /// Singleton instance
  static final TolgeeLogger instance = TolgeeLogger._();

  /// Sets log function
  void setLog(ValueSetter<String> log) {
    _log = log;
  }

  /// Logs message
  void log(String message) {
    _log?.call(message);
  }
}
