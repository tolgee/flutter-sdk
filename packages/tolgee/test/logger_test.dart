import 'package:flutter_test/flutter_test.dart';
import 'package:tolgee/tolgee.dart';

void main() {
  test('logs warnings by default and keeps debug messages quiet', () {
    final logged = <String>[];
    TolgeeLogger.setLog(logged.add);

    TolgeeLogger.debug('debug');
    TolgeeLogger.warning('warning');

    expect(logged, ['warning']);
  });

  test('LogLevel is exported for apps', () {
    TolgeeLogger.setLogLevel(LogLevel.warning);
  });
}
