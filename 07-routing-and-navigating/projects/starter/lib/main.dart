import 'dart:async';
import 'dart:isolate';

import 'package:component_library/component_library.dart';
import 'package:domain_models/domain_models.dart';
import 'package:fav_qs_api/fav_qs_api.dart';
import 'package:flutter/material.dart';
import 'package:forgot_my_password/forgot_my_password.dart';
import 'package:key_value_storage/key_value_storage.dart';
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
import 'package:wonder_words/l10n/app_localizations.dart';
import 'package:wonder_words/routing_table.dart';

void main() async {
  // Has to be late so it doesn't instantiate before the
  // `initializeMonitoringPackage()` call.
  late final errorReportingService = ErrorReportingService();

  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await initializeMonitoringPackage();

      final remoteValueService = RemoteValueService();
      await remoteValueService.load();

      FlutterError.onError = errorReportingService.recordFlutterError;

      Isolate.current.addErrorListener(
        RawReceivePort((pair) async {
          final List<dynamic> errorAndStacktrace = pair;
          await errorReportingService.recordError(
            errorAndStacktrace.first,
            errorAndStacktrace.last,
          );
        }).sendPort,
      );

      runApp(
        WonderWords(
          remoteValueService: remoteValueService,
        ),
      );
    },
    (error, stack) => errorReportingService.recordError(
      error,
      stack,
      fatal: true,
    ),
  );
}

class WonderWords extends StatefulWidget {
  const WonderWords({
    required this.remoteValueService,
    Key? key,
  }) : super(key: key);

  final RemoteValueService remoteValueService;

  @override
  _WonderWordsState createState() => _WonderWordsState();
}

class _WonderWordsState extends State<WonderWords> {
  final _keyValueStorage = KeyValueStorage();
  final _dynamicLinkService = DynamicLinkService();
  late final FavQsApi _favQsApi = FavQsApi(
    userTokenSupplier: () => _userRepository.getUserToken(),
  );
  late final _quoteRepository = QuoteRepository(
    remoteApi: _favQsApi,
    keyValueStorage: _keyValueStorage,
  );
  late final UserRepository _userRepository = UserRepository(
    remoteApi: _favQsApi,
    noSqlStorage: _keyValueStorage,
  );

  // Completed: Instantiate the RouterDelegate.
  //? 1. You’re creating a late property to hold a RoutemasterDelegate object —
  //? you’ll understand why the late later on.
  //! RoutemasterDelegate isRoutemaster’s implementation of the Nav 2’s RouterDelegate class
  //* You’re able to import this class because the Routemaster package is already
  //* listed as a dependency in your pubspec.yaml.
  late final _routeDelegate = RoutemasterDelegate(
    //! 2. To instantiate a RoutemasterDelegate , you have to supply the
    //! routesBuilder parameter. routesBuilder takes in a function that receives
    //! a BuildContext and returns a RouteMap object.
    routesBuilder: (context) => RouteMap(routes: {
      //* 3. To instantiate a RouteMap , you have to supply the routes parameter.
      //* Here’s where Routemaster’s approach gets close to simple named routes.
      //! The routes parameter receives a Map<String, PageBuilder>, which links
      //! every path you want to support in your app to a function that builds the
      //! corresponding Page object.
      '/': (_) => const MaterialPage(child: Placeholder()),
    }),
  );
  final _lightTheme = LightWonderThemeData();
  final _darkTheme = DarkWonderThemeData();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DarkModePreference>(
      stream: _userRepository.getDarkModePreference(),
      builder: (context, snapshot) {
        final darkModePreference = snapshot.data;

        return WonderTheme(
          lightTheme: _lightTheme,
          darkTheme: _darkTheme,
          child: MaterialApp.router(
            theme: _lightTheme.materialThemeData,
            darkTheme: _darkTheme.materialThemeData,
            themeMode: darkModePreference?.toThemeMode(),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ComponentLibraryLocalizations.delegate,
              ProfileMenuLocalizations.delegate,
              QuoteListLocalizations.delegate,
              QuoteDetailsLocalizations.delegate,
              SignInLocalizations.delegate,
              ForgotMyPasswordLocalizations.delegate,
              SignUpLocalizations.delegate,
              UpdateProfileLocalizations.delegate,
            ],
            routeInformationParser: const RoutemasterParser(),
            routerDelegate: _routeDelegate,
          ),
        );
      },
    );
  }
}

extension on DarkModePreference {
  ThemeMode toThemeMode() {
    switch (this) {
      case DarkModePreference.useSystemSettings:
        return ThemeMode.system;
      case DarkModePreference.alwaysLight:
        return ThemeMode.light;
      case DarkModePreference.alwaysDark:
        return ThemeMode.dark;
    }
  }
}
