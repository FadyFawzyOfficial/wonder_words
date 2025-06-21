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
    // Completed: add default values for your parameters
    //! This sets the default values of the parameters defined on your Firebase Remote Config console.
    //! In your case, this is the bool parameter `grid_quotes_view_enabled`.
    //! By default, you want to keep your quote’s list screen layout as the grid.
    //! Therefore, you set the grid_quotes_view_enabled parameter to true.
    //! Remember, you’ve set the value of this same parameter to false in the
    //! Remote Config console, which means this will be overridden when you publish the changes.
    await _remoteConfig.setDefaults({_gridQuotesViewEnabledKey: true});
    await _remoteConfig.fetchAndActivate();
  }

  //* 3. Returns the value of the feature flag you defined.
  bool get isGridQuotesViewEnabled =>
      _remoteConfig.getBool(_gridQuotesViewEnabledKey);
}
