import 'package:flutter/material.dart';
import 'package:monitoring/monitoring.dart';
import 'package:routemaster/routemaster.dart';

class ScreenViewObserver extends RoutemasterObserver {
  ScreenViewObserver({
    required this.analyticsService,
  });

  final AnalyticsService analyticsService;

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

  // TODO: override didPush and didPop method
}
