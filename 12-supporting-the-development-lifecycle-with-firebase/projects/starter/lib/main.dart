import 'dart:async';
import 'dart:isolate';

import 'package:component_library/component_library.dart';
import 'package:domain_models/domain_models.dart';
import 'package:fav_qs_api/fav_qs_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:forgot_my_password/forgot_my_password.dart';
import 'package:key_value_storage/key_value_storage.dart';
import 'package:monitoring/monitoring.dart';
import 'package:profile_menu/profile_menu.dart';
import 'package:quote_list/quote_list.dart';
import 'package:quote_repository/quote_repository.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sign_in/sign_in.dart';
import 'package:sign_up/sign_up.dart';
import 'package:update_profile/update_profile.dart';
import 'package:user_repository/user_repository.dart';
import 'package:wonder_words/l10n/app_localizations.dart';
import 'package:wonder_words/routing_table.dart';
import 'package:wonder_words/screen_view_observer.dart';

// Completed: replace the implementation of main() function
void main() async {
  //* 1. Initialize an instance of `ErrorReportingService`, which you defined in
  //* the previous section.
  //! Has to be late so it doesn't instantiate before the
  //! `initializeMonitoringPackage()` call.
  late final errorReportingService = ErrorReportingService();

  //! 2. The whole content of the main() function is wrapped with the
  //! `runZonedGuarded()` function, which enables you to report zoned errors.
  runZonedGuarded<Future<void>>(
    () async {
      //* 3. You have to ensure the binding of the widgets with the native layers
      //* and initialize Firebase Core services.
      WidgetsFlutterBinding.ensureInitialized();
      await initializeMonitoringPackage();
      final remoteValueService = RemoteValueService();
      await remoteValueService.load();

      //! 4. This is a lambda expression that invokes the `recordFlutterError`
      //! method with the `FlutterErrorDetails` that holds the stack trace,
      //! exception details, etc. It records the Flutter framework errors.
      FlutterError.onError = errorReportingService.recordFlutterError;

      //! 5. This handles the error outside of Flutter context.
      Isolate.current.addErrorListener(
        RawReceivePort((pair) async {
          final List<dynamic> errorAndStacktrace = pair;
          await errorReportingService.recordError(
            errorAndStacktrace.first,
            errorAndStacktrace.last,
          );
        }).sendPort,
      );

      runApp(WonderWords(remoteValueService: remoteValueService));
    },

    //! 6. This catches and reports the error that happen asynchronously - zoned errors.
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
  final _analyticsService = AnalyticsService();
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

  late final RoutemasterDelegate _routerDelegate = RoutemasterDelegate(
    observers: [
      // Completed: add observers to RoutemasterDelegate
      //! With that, you’ve added an observer to RoutemasterDelegate , which tracks
      //! navigation from one screen to another. You can see that the observers
      //! attribute is a type of List , which means that you could add multiple observers
      //! to observe users navigating from screen to screen.
      ScreenViewObserver(analyticsService: _analyticsService)
    ],
    routesBuilder: (context) {
      return RouteMap(
        routes: buildRoutingTable(
          routerDelegate: _routerDelegate,
          userRepository: _userRepository,
          quoteRepository: _quoteRepository,
          remoteValueService: widget.remoteValueService,
          dynamicLinkService: _dynamicLinkService,
        ),
      );
    },
  );
  final _lightTheme = LightWonderThemeData();
  final _darkTheme = DarkWonderThemeData();
  late StreamSubscription _incomingDynamicLinksSubscription;

  @override
  void initState() {
    super.initState();

    _openInitialDynamicLinkIfAny();

    _incomingDynamicLinksSubscription =
        _dynamicLinkService.onNewDynamicLinkPath().listen(
              _routerDelegate.push,
            );
  }

  Future<void> _openInitialDynamicLinkIfAny() async {
    final path = await _dynamicLinkService.getInitialDynamicLinkPath();
    if (path != null) {
      _routerDelegate.push(path);
    }
  }

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
            supportedLocales: const [
              Locale('en', ''),
              Locale('pt', 'BR'),
            ],
            localizationsDelegates: const [
              GlobalCupertinoLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              AppLocalizations.delegate,
              ComponentLibraryLocalizations.delegate,
              ProfileMenuLocalizations.delegate,
              QuoteListLocalizations.delegate,
              SignInLocalizations.delegate,
              ForgotMyPasswordLocalizations.delegate,
              SignUpLocalizations.delegate,
              UpdateProfileLocalizations.delegate,
            ],
            routerDelegate: _routerDelegate,
            routeInformationParser: const RoutemasterParser(),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _incomingDynamicLinksSubscription.cancel();
    super.dispose();
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
