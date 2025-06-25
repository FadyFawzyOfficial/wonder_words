import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FavoriteIconButton tests: ', () {
    // Completed: add an implementation of widgetTest
    testWidgets(
      'onTap() callback is executed when tapping on button',
      (tester) async {
        //* 1. The variable that will be manipulated on the tap gesture is initialized.
        bool value = false;

        //! 2. The pumpWidget function helps build the widget. Notice that the
        //! function it tests is wrapped in a few additional widgets.
        //! This is required for multiple reasons, one being that you're using
        //! internationalization inside `FavoriteIconButton`.
        await tester.pumpWidget(MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            ComponentLibraryLocalizations.delegate
          ],
          home: Scaffold(
            body: FavoriteIconButton(
              isFavorite: false,
              //* 3. You define the action triggered on tap.
              onTap: () => value = !value,
            ),
          ),
        ));

        //! 4. In this step, the button is being pressed. Notice the parameter
        //! provided inside the tap() function. You have to tell which widget has
        //! to be tapped. You can achieve that by searching for the correct type
        //! of widget through the widget tree. The other option would be adding
        //! a key attribute to the FavoriteIconButton widget and searching by key.
        //? There are multiple different ways of searching the widget.
        await tester.tap(find.byType(FavoriteIconButton));

        //! 5. This evaluate if the test was successful by comparing the value of
        //! `value` that changed with the tap gesture with the expected value.
        expect(value, true);
      },
    );

    testWidgets(
      'FavoriteIconButton uses outlined favorite icon when is not favorite',
      (tester) async {
        await tester.pumpWidget(const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: [ComponentLibraryLocalizations.delegate],
          home: Scaffold(body: FavoriteIconButton(isFavorite: false)),
        ));

        final outlinedIconFinder = find.byIcon(Icons.favorite_border_outlined);

        expect(outlinedIconFinder, findsOneWidget);
      },
    );
  });
}
