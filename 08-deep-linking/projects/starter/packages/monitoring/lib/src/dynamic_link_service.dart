import 'dart:async';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';

export 'package:firebase_dynamic_links/firebase_dynamic_links.dart'
    show SocialMetaTagParameters;

typedef OnNewDynamicLinkPath = void Function(String newDynamicLinkPath);

/// Wrapper around [FirebaseDynamicLinks].
class DynamicLinkService {
  // Completed: Create a constant to hold your dynamic link prefix.
  static const _domainUriPrefix = 'https://wonderwords.page.link';

  static const _iOSBundleId = 'com.raywenderlich.wonderWords';
  static const _androidPackageName = 'com.raywenderlich.wonder_words';

  DynamicLinkService({
    @visibleForTesting FirebaseDynamicLinks? dynamicLinks,
  }) : _dynamicLinks = dynamicLinks ?? FirebaseDynamicLinks.instance;

  final FirebaseDynamicLinks _dynamicLinks;

  // Completed: Create a function that generates dynamic links
  // 1. You're creating a function that receives 2 parameters:
  // - The path of the screen you want your link to open.
  // - An optional [SocialMetaTagParameters] object that contains the
  // information you want to appear when your link is shared in a social post,
  // such as a short description and an image.
  Future<String> generateDynamicLinkUrl({
    required String path,
    SocialMetaTagParameters? socialMetaTagParameters,
  }) async {
    // 2. You then combine the parameters you received with some of the information
    // you already had to build a DynamicLinkParameters object.
    final parameters = DynamicLinkParameters(
      link: Uri.parse('$_domainUriPrefix$path'),
      uriPrefix: _domainUriPrefix,
      androidParameters:
          const AndroidParameters(packageName: _androidPackageName),
      iosParameters: const IOSParameters(bundleId: _iOSBundleId),
      socialMetaTagParameters: socialMetaTagParameters,
    );

    // 3. Finally, you delegate the link's construction to the buildShortLink()
    // function form the FirebaseDynamicLinks class.
    final shortLink = await _dynamicLinks.buildShortLink(parameters);
    return shortLink.shortUrl.toString();
  }

  // TODO: Create a function that returns the link that launched the app.

  // TODO: Expose a way to listen to new links.
}
