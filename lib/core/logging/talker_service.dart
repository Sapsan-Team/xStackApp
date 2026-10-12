import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:talker_flutter/talker_flutter.dart';

final talker = TalkerFlutter.init(
  settings: TalkerSettings(
    maxHistoryItems: 1000,
    useConsoleLogs: kDebugMode,
  ),
);

final talkerProvider = Provider<Talker>((ref) => talker);

void setupTalkerErrorHandling() {
  FlutterError.onError = (details) {
    talker.handle(
      details.exception,
      details.stack,
      details.exceptionAsString(),
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    talker.handle(error, stack, 'Uncaught platform error');
    return true;
  };
}
