import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

// Completed: add implementation of explicit crash
class ExplicitCrash {
  //! 1. Define the instance of Firebase Crashlytics.
  final FirebaseCrashlytics _crashlytics;

  ExplicitCrash({@visibleForTesting FirebaseCrashlytics? crashlytics})
      : _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  //! 2. Add an implementation of an explicit crash.
  crashTheApp() => _crashlytics.crash();
}
