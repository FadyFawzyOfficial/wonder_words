import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Wrapper around [FirebaseCrashlytics].
class ErrorReportingService {
  // 1. Declares an instance of Firebase Crashlytics.
  final FirebaseCrashlytics _crashlytics;

  ErrorReportingService({@visibleForTesting FirebaseCrashlytics? crashlytics})
      : _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  //? 2. Defines the method used for recording Flutter framework errors, a type of
  //? error you'll learn about in the next section.
  Future<void> recordFlutterError(FlutterErrorDetails flutterErrorDetails) =>
      _crashlytics.recordFlutterError(flutterErrorDetails);

  // 3. Defines the method for recording other errors.
  Future<void> recordError({
    dynamic exception,
    StackTrace? stack,
    bool fatal = false,
  }) {
    return _crashlytics.recordError(
      exception,
      stack,
      fatal: fatal,
    );
  }
}
