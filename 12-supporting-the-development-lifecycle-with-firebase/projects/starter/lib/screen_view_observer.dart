import 'package:flutter/material.dart';
import 'package:monitoring/monitoring.dart';
import 'package:routemaster/routemaster.dart';

class ScreenViewObserver extends RoutemasterObserver {
  final AnalyticsService analyticsService;

  ScreenViewObserver({required this.analyticsService});

  // Completed: add _sendScreenView() helper method
  void _sendScreenView(PageRoute<dynamic> route) {
    //* 1. Extracts the name of the screen form route settings
    final screenName = route.settings.name;

    //! 2. Once verified that the screen name is non-null, you record the screen
    //! view event by invoking the predefined setCurrentScreen method.
    if (screenName != null) {
      analyticsService.setCurrentScreen(screenName);
    }
  }

  // Completed: override didPush and didPop method
  //! When navigating to a new screen, the didPush method passes its route to your _sendScreenView method.
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) _sendScreenView(route);
  }

  //! When navigating back to the previous screen, the current screen disappears,
  //! and the previous screen reappears. That’s when the didPop method passes
  //! the previous route to the _sendScreenView method instead of the current route.
  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is PageRoute && route is PageRoute) {
      _sendScreenView(previousRoute);
    }
  }
}
