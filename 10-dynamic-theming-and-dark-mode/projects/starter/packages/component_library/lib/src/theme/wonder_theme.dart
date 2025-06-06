import 'package:component_library/src/theme/wonder_theme_data.dart';
import 'package:flutter/material.dart';

class WonderTheme extends InheritedWidget {
  const WonderTheme({
    required Widget child,
    required this.lightTheme,
    required this.darkTheme,
    Key? key,
  }) : super(
          key: key,
          child: child,
        );

  final WonderThemeData lightTheme;
  final WonderThemeData darkTheme;

  // Completed: replace with correct implementation of updateShouldNotify
  //! updateShouldNotify() notifies all the widgets that inherit WonderTheme so
  //! they can be rebuilt, and therefore, they’ll reflect the change. It notifies them
  //! exclusively when the dark or light theme of an old widget is different from the
  //! current widget. This prevents unnecessary rebuilds.
  @override
  bool updateShouldNotify(WonderTheme oldWidget) =>
      oldWidget.lightTheme != lightTheme || oldWidget.darkTheme != darkTheme;

  // Completed: replace with correct implementation of service locator function
  static WonderThemeData of(BuildContext context) {
    //* 1. Obtains the nearest widget in the widget tree of the WonderTheme type and
    //* stores it in the variable.
    final WonderTheme? inheritedTheme =
        context.dependOnInheritedWidgetOfExactType<WonderTheme>();

    //! 2. If no widget of the WonderTheme type is in the widget tree, it interrupts the
    //! normal execution of the code. This is important during the development
    //! process, so you don’t forget to add your InheritedWidget in the widget tree.
    //! In just a moment, you’ll see what happens if you forget to add WonderTheme
    //! at the top of your widget tree.
    assert(inheritedTheme != null, 'No WonderTheme found in context.');

    //* 3. Stores the current brightness in the variable.
    final currentBrightness = Theme.of(context).brightness;

    //* 4. Based on current brightness, returns either a light or dark theme.
    return currentBrightness == Brightness.dark
        ? inheritedTheme!.darkTheme
        : inheritedTheme!.lightTheme;
  }
}
