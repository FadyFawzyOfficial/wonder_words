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
  required RoutemasterDelegate routerDelegate,
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

    // Completed: Define the two nested routes homes.
    _PathConstants.quoteListPath: (route) {
      return MaterialPage(
        //! 1. Assigning a name to your page isn’t mandatory but will be helpful when
        //! you’re writing analytics code in Chapter 12, “Supporting the Development
        //! Lifecycle With Firebase”.
        name: 'quotes-list',
        child: QuoteListScreen(
          quoteRepository: quoteRepository,
          userRepository: userRepository,
          remoteValueService: remoteValueService,
          onAuthenticationError: (context) {
            //* 2. Here, you’re using the RoutemasterDelegate you created on main.dart to
            //* navigate to a new screen. You can use it in this file because you asked for it as
            //* a parameter of this buildRoutingTable function.
            routerDelegate.push(_PathConstants.signInPath);
          },
          onQuoteSelected: (id) {
            //! 3. The navigation here is a bit more complicated. The quoteDetailsPath route
            //! may return a result: the updated Quote object if the user interacted with the
            //! quote while on that screen — by favoriting it, for example. You then return
            //! that Quote object to the onQuoteSelected callback just so your
            //! QuoteListScreen can update that quote’s list item if something changed.
            final navigation = routerDelegate
                .push<Quote?>(_PathConstants.quoteDetailsPath(quoteId: id));

            return navigation.result;
          },
        ),
      );
    },

    _PathConstants.profileMenuPath: (_) {
      return MaterialPage(
        name: 'profile-menu',
        child: ProfileMenuScreen(
          userRepository: userRepository,
          quoteRepository: quoteRepository,
          onSignInTap: () => routerDelegate.push(_PathConstants.signInPath),
          onSignUpTap: () => routerDelegate.push(_PathConstants.signUpPath),
          onUpdateProfileTap: () =>
              routerDelegate.push(_PathConstants.updateProfilePath),
        ),
      );
    },

    // Completed: Define the subsequent routes.
    _PathConstants.updateProfilePath: (_) {
      return MaterialPage(
        name: 'update-profile',
        child: UpdateProfileScreen(
          userRepository: userRepository,
          onUpdateProfileSuccess: () => routerDelegate.pop(),
        ),
      );
    },

    _PathConstants.quoteDetailsPath(): (info) {
      return MaterialPage(
        name: 'quote-details',
        child: QuoteDetailsScreen(
          quoteRepository: quoteRepository,
          //! 1. This info.pathParameters[_PathConstants.idPathParameter] is how you
          //! extract a path parameter from a route. For example, when the user taps a
          //! quote on the quote list screen, you push a route with that quote’s ID
          //! embedded within the path, such as /quotes/13 . Here, you’re extracting that
          //! 13 and passing it to the QuoteDetailsScreen. The reason you had to wrap
          //! it in an int.parse() call is because all path parameters come to you as
          //! Strings.
          quoteId: int.parse(
            info.pathParameters[_PathConstants.idPathParameter] ?? '',
          ),
          onAuthenticationError: () =>
              routerDelegate.push(_PathConstants.signInPath),
          //! 2. This is just using Firebase to generate a shareable link for a quote. You’ll
          //! learn all about this in the next chapter, “Deep Linking”.
          shareableLinkGenerator: (quote) =>
              dynamicLinkService.generateDynamicLinkUrl(
            path: _PathConstants.quoteDetailsPath(quoteId: quote.id),
            socialMetaTagParameters: SocialMetaTagParameters(
              title: quote.body,
              description: quote.author,
            ),
          ),
        ),
      );
    },
    _PathConstants.signInPath: (_) {
      return MaterialPage(
        name: 'sign-in',
        fullscreenDialog: true,
        child: Builder(
          builder: (context) {
            return SignInScreen(
              userRepository: userRepository,
              onSignInSuccess: routerDelegate.pop,
              onSignUpTap: () => routerDelegate.push(_PathConstants.signUpPath),
              onForgotMyPasswordTap: () => showDialog(
                context: context,
                builder: (context) => ForgotMyPasswordDialog(
                  userRepository: userRepository,
                  onCancelTap: routerDelegate.pop,
                  onEmailRequestSuccess: routerDelegate.pop,
                ),
              ),
            );
          },
        ),
      );
    },
    _PathConstants.signUpPath: (_) {
      return MaterialPage(
        child: SignUpScreen(
          userRepository: userRepository,
          onSignUpSuccess: routerDelegate.pop,
        ),
      );
    },
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
      '$quoteListPath/${quoteId ?? ':$idPathParameter'}';
}
