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

Map<String, PageBuilder> buildRoutingTable({
  required RoutemasterDelegate routerDelegate,
  required UserRepository userRepository,
  required QuoteRepository quoteRepository,
  required RemoteValueService remoteValueService,
  required DynamicLinkService dynamicLinkService,
}) {
  return {
    _PathConstants.tabContainerPath: (_) => CupertinoTabPage(
          child: const TabContainerScreen(),
          paths: [
            _PathConstants.quoteListPath,
            _PathConstants.profileMenuPath,
          ],
        ),
    _PathConstants.quoteListPath: (route) {
      return MaterialPage(
        name: 'quotes-list',
        child: QuoteListScreen(
          quoteRepository: quoteRepository,
          userRepository: userRepository,
          onAuthenticationError: (context) {
            routerDelegate.push(_PathConstants.signInPath);
          },
          onQuoteSelected: (id) {
            final navigation = routerDelegate.push<Quote?>(
              _PathConstants.quoteDetailsPath(
                quoteId: id,
              ),
            );
            return navigation.result;
          },
          remoteValueService: remoteValueService,
        ),
      );
    },
    _PathConstants.profileMenuPath: (_) {
      return MaterialPage(
        name: 'profile-menu',
        child: ProfileMenuScreen(
          quoteRepository: quoteRepository,
          userRepository: userRepository,
          onSignInTap: () {
            routerDelegate.push(
              _PathConstants.signInPath,
            );
          },
          onSignUpTap: () {
            routerDelegate.push(
              _PathConstants.signUpPath,
            );
          },
          onUpdateProfileTap: () {
            routerDelegate.push(
              _PathConstants.updateProfilePath,
            );
          },
        ),
      );
    },
    _PathConstants.updateProfilePath: (_) => MaterialPage(
          name: 'update-profile',
          child: UpdateProfileScreen(
            userRepository: userRepository,
            onUpdateProfileSuccess: () {
              routerDelegate.pop();
            },
          ),
        ),
    _PathConstants.quoteDetailsPath(): (info) => MaterialPage(
          name: 'quote-details',
          child: QuoteDetailsScreen(
            quoteRepository: quoteRepository,
            quoteId: int.parse(
              info.pathParameters[_PathConstants.idPathParameter] ?? '',
            ),
            onAuthenticationError: () {
              routerDelegate.push(_PathConstants.signInPath);
            },
            //! First of all, observe where you’re inserting this code. You dove into this
            //! routing_table.dart file in the last chapter.
            //! This is where you define all your routes and connect all your features
            // Completed: Specify the shareableLinkGenerator parameter.
            //* 1. Specified the shareableLinkGenerator parameter of the
            //* QuoteDetailsScreen class. This parameter expects a function that
            //* the quote details screen can use to generate a dynamic link.
            //* That function receives a quote and must return a Future<String>
            //* containing the shareable link of the quote.
            shareableLinkGenerator: (quote) {
              //* 2. Then, to actually generate the link, you're calling the
              //* generateDynamicLinkUrl() function you created inside the
              //* DynamicLinkService class and provide it:
              //! 1. The path of the quote details screen containing the ID for
              //!    that specific quote the user wants to share.
              //! 2. The socialMetaTagParameters containing some information
              //!    about the quote, so the link looks good on social media.
              return dynamicLinkService.generateDynamicLinkUrl(
                path: _PathConstants.quoteDetailsPath(quoteId: quote.id),
                socialMetaTagParameters: SocialMetaTagParameters(
                  title: quote.body,
                  description: quote.author,
                ),
              );
            },
          ),
        ),
    _PathConstants.signInPath: (_) => MaterialPage(
          name: 'sign-in',
          fullscreenDialog: true,
          child: Builder(
            builder: (context) {
              return SignInScreen(
                userRepository: userRepository,
                onSignInSuccess: () {
                  routerDelegate.pop();
                },
                onSignUpTap: () {
                  routerDelegate.push(_PathConstants.signUpPath);
                },
                onForgotMyPasswordTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return ForgotMyPasswordDialog(
                        userRepository: userRepository,
                        onCancelTap: () {
                          routerDelegate.pop();
                        },
                        onEmailRequestSuccess: () {
                          routerDelegate.pop();
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
    _PathConstants.signUpPath: (_) => MaterialPage(
          name: 'sign-up',
          child: SignUpScreen(
            userRepository: userRepository,
            onSignUpSuccess: () {
              routerDelegate.pop();
            },
          ),
        ),
  };
}

class _PathConstants {
  const _PathConstants._();

  static String get tabContainerPath => '/';

  static String get quoteListPath => '${tabContainerPath}quotes';

  static String get profileMenuPath => '${tabContainerPath}user';

  static String get updateProfilePath => '$profileMenuPath/update-profile';

  static String get signInPath => '${tabContainerPath}sign-in';

  static String get signUpPath => '${tabContainerPath}sign-up';

  static String get idPathParameter => 'id';

  static String quoteDetailsPath({
    int? quoteId,
  }) =>
      '$quoteListPath/${quoteId ?? ':$idPathParameter'}';
}
