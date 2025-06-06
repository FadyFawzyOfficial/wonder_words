import 'package:component_library/component_library.dart';
import 'package:component_library/src/theme/spacing.dart';
import 'package:flutter/material.dart';

const _dividerThemeData = DividerThemeData(
  space: 0,
);

// If the number of properties get too big, we can start grouping them in
// classes like Flutter does with TextTheme, ButtonTheme, etc, inside ThemeData.
abstract class WonderThemeData {
  ThemeData get materialThemeData;

  double screenMargin = Spacing.mediumLarge;

  double gridSpacing = Spacing.mediumLarge;

  Color get roundedChoiceChipBackgroundColor;

  Color get roundedChoiceChipSelectedBackgroundColor;

  Color get roundedChoiceChipLabelColor;

  Color get roundedChoiceChipSelectedLabelColor;

  Color get roundedChoiceChipAvatarColor;

  Color get roundedChoiceChipSelectedAvatarColor;

  Color get quoteSvgColor;

  Color get unvotedButtonColor;

  Color get votedButtonColor;

  TextStyle quoteTextStyle = const TextStyle(
    fontFamily: 'Fondamento',
    package: 'component_library',
  );
}

class LightWonderThemeData extends WonderThemeData {
  // Completed: Add light theme implementation for materialThemeData
  @override
  ThemeData get materialThemeData {
    return ThemeData(
      //* 1. Brightness ‘s light and dark values set the theme for all the elements in
      //* ThemeData . This assignment initializes the ThemeData elements with the
      //* default light or dark theme values. So, if you don’t specify elements like
      //* scaffoldBackgroundColor in ThemeData , then the app uses the default
      //* ones from the Flutter framework.
      brightness: Brightness.light,
      //* 2. The light theme and dark theme implementations of materialThemeData
      //* assign black and white colors as the primary swatches.
      //! Note: primarySwatch is the driving factor for all the primary colors in the
      //! app. For example, all the text in the app gets the colors from this swatch.
      //! toMaterialColor is an extension method in wonder_theme_data.dart that
      //! generates the swatch from any color. Feel free to look at the implementation of this extension.
      primarySwatch: Colors.black.toMaterialColor(),
      //! 3. This is the theme for the divider, which is the same for both light and dark
      //! themes. Therefore, you use a global variable to define it.
      dividerTheme: _dividerThemeData,
    );
  }

  @override
  Color get roundedChoiceChipBackgroundColor => Colors.white;

  @override
  Color get roundedChoiceChipLabelColor => Colors.black;

  @override
  Color get roundedChoiceChipSelectedBackgroundColor => Colors.black;

  @override
  Color get roundedChoiceChipSelectedLabelColor => Colors.white;

  @override
  Color get quoteSvgColor => Colors.black;

  @override
  Color get roundedChoiceChipAvatarColor => Colors.black;

  @override
  Color get roundedChoiceChipSelectedAvatarColor => Colors.white;

  @override
  Color get unvotedButtonColor => Colors.black54;

  @override
  Color get votedButtonColor => Colors.black;
}

class DarkWonderThemeData extends WonderThemeData {
// Completed: Add dark theme implementation for materialThemeData
  @override
  ThemeData get materialThemeData {
    return ThemeData(
      //* 1. Brightness ‘s light and dark values set the theme for all the elements in
      //* ThemeData . This assignment initializes the ThemeData elements with the
      //* default light or dark theme values. So, if you don’t specify elements like
      //* scaffoldBackgroundColor in ThemeData , then the app uses the default
      //* ones from the Flutter framework.
      brightness: Brightness.dark,
      //* 2. The light theme and dark theme implementations of materialThemeData
      //*assign black and white colors as the primary swatches.
      primarySwatch: Colors.white.toMaterialColor(),
      //! 3. This is the theme for the divider, which is the same for both light and dark
      //! themes. Therefore, you use a global variable to define it.
      dividerTheme: _dividerThemeData,
      //* 4. An additional color for active toggle is defined for the dark theme, as it
      //* doesn’t use color from primarySwatch .
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.white.toMaterialColor(),
        brightness: Brightness.dark,
      ).copyWith(secondary: Colors.white), // Replaces toggleableActiveColor,
    );
  }

  @override
  Color get roundedChoiceChipBackgroundColor => Colors.black;

  @override
  Color get roundedChoiceChipLabelColor => Colors.white;

  @override
  Color get roundedChoiceChipSelectedBackgroundColor => Colors.white;

  @override
  Color get roundedChoiceChipSelectedLabelColor => Colors.black;

  @override
  Color get quoteSvgColor => Colors.white;

  @override
  Color get roundedChoiceChipAvatarColor => Colors.white;

  @override
  Color get roundedChoiceChipSelectedAvatarColor => Colors.black;

  @override
  Color get unvotedButtonColor => Colors.white54;

  @override
  Color get votedButtonColor => Colors.white;
}

extension on Color {
  Map<int, Color> _toSwatch() => {
        50: withOpacity(0.1),
        100: withOpacity(0.2),
        200: withOpacity(0.3),
        300: withOpacity(0.4),
        400: withOpacity(0.5),
        500: withOpacity(0.6),
        600: withOpacity(0.7),
        700: withOpacity(0.8),
        800: withOpacity(0.9),
        900: this,
      };

  MaterialColor toMaterialColor() => MaterialColor(
        value,
        _toSwatch(),
      );
}
