import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// Completed: add missing package
import 'package:integration_test/integration_test.dart';

import 'package:wonder_words/main.dart' as app;

void main() {
  // Completed: add an implementation of integration test

  //! 1. Enables executing tests on a physical device.
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'search for life quotes',
    (tester) async {
      //! 2. Runs the app.
      app.main();

      //! 3. Rebuilds the frames every second as long as their frames are scheduled.
      await tester.pumpAndSettle(const Duration(seconds: 1));

      //! 4. Search for the SearBar with the help of searching by type.
      final searchBarFinder = find.byType(AppSearchBar);

      //! 5. Evaluates that exactly 1 SearchBar widget is present on the screen.
      //* Look at the UI design of the app - this is what the app should look like.
      expect(searchBarFinder, findsOneWidget);

      //! 6. Enters the search key 'life' into the text field of the searchBar widget.
      await tester.enterText(searchBarFinder, 'life');

      //! 7. Again, rebuilds the frames until the new quote list is loaded.
      await tester.pumpAndSettle();

      //! 8. Check that your request was successful by making sure that the UI returns
      //! widget QuoteCard. If that request fails, no QuoteCard widgets will be
      //! available on the screen
      expect(find.byType(QuoteCard), findsWidgets);
    },
  );
}
