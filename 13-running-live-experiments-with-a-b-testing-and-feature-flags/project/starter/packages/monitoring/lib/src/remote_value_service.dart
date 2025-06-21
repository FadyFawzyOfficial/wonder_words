// Completed: import firebase_remote_config package
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// Wrapper around [FirebaseRemoteConfig].
class RemoteValueService {
  // Completed: add an implementation of RemoteValueService class
  static const _gridQuotesViewEnabledKey = 'grid_quotes_view_enabled';

  final FirebaseRemoteConfig _remoteConfig;

  //* 1. Initializes the instance of FirebaseRemoteConfig.
  RemoteValueService({@visibleForTesting FirebaseRemoteConfig? remoteConfig})
      : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  //! 2. Fetches and activates the configuration that you’ll set up on the
  //! Firebase Remote Config console.
  Future<void> load() async {
    // TODO: add default values for your parameters
    await _remoteConfig.fetchAndActivate();
  }

  //* 3. Returns the value of the feature flag you defined.
  bool get isGridQuotesViewEnabled =>
      _remoteConfig.getBool(_gridQuotesViewEnabledKey);
}
