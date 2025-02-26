import 'package:domain_models/domain_models.dart';
import 'package:flutter/material.dart';
import 'package:forgot_my_password/forgot_my_password.dart';
import 'package:monitoring/monitoring.dart';
import 'package:profile_menu/profile_menu.dart';
import 'package:quote_details/quote_details.dart';
import 'package:quote_list/quote_list.dart';
import 'package:quote_repository/quote_repository.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sign_in/sign_in.dart';
import 'package:sign_up/sign_up.dart';
import 'package:update_profile/update_profile.dart';
import 'package:user_repository/user_repository.dart';
import 'package:wonder_words/tab_container_screen.dart';

// Completed: Create the app's routing table.
//! 1. The return type is a Map<String, PageBuilder> . As you’ve seen, this maps
//! each path you want to support — the String — to the function that builds
//! the corresponding page — the PageBuilder .
Map<String, PageBuilder> buildRoutingTable({
  //* 2. Most of the dependencies you’ll need to instantiate your screens are already
  //* available on lib/main.dart, so you’re asking them to be passed onto this
  //* function so you can reuse them.
  required RoutemasterDelegate routeDelegate,
  required UserRepository userRepository,
  required QuoteRepository quoteRepository,
  required RemoteValueService remoteValueService,
  required DynamicLinkService dynamicLinkService,
}) {
  return {
    //! 3. The first path you declared is your app’s entry point: the '/'. The screen
    //! you’re assigning to this path is the TabContainerScreen you’ve created.
    //! This is the outermost screen that will hold the bottom
    //! tab along with the two nested navigation stacks.
    _PathConstants.tabContainerPath: (_) =>
        //! 4. To achieve the nested navigation layout, you wrapped your
        //! TabContainerScreen widget inside a CupertinoTabPage class. You then
        //! leveraged its paths parameter to define which two routes should be the
        //! entry point for each internal flow.
        CupertinoTabPage(
          child: const TabContainerScreen(),
          paths: [
            _PathConstants.quoteListPath,
            _PathConstants.profileMenuPath,
          ],
        ),
    // TODO: Define the two nested routes homes.
  };
}

// Completed: Define the app's paths.
class _PathConstants {
  const _PathConstants._();

  static const String tabContainerPath = '/';

  static const String quoteListPath = '${tabContainerPath}quotes';

  static String get profileMenuPath => '${tabContainerPath}user';

  static String get updateProfilePath => '$profileMenuPath/updateprofile';

  static String get signInPath => '${tabContainerPath}sign-in';

  static String get signUpPath => '${tabContainerPath}sign-up';

  static String get idPathParameter => 'id';

  static String quoteDetailsPath({int? quoteId}) =>
      '$quoteListPath/${quoteId ?? ': $idPathParameter'}';
}
