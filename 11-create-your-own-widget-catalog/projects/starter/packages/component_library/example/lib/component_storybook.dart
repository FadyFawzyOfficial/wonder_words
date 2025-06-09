import 'package:component_library/component_library.dart';
import 'package:component_library_storybook/stories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

class ComponentStorybook extends StatelessWidget {
  final ThemeData lightThemeData, darkThemeData;

  const ComponentStorybook({
    Key? key,
    required this.lightThemeData,
    required this.darkThemeData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //! 3. Fetches the WonderTheme instance from ancestors. You’ll provide
    //! WonderTheme from main.dart later.
    final theme = WonderTheme.of(context);
    return Storybook(
      //* 4. Provides light and dark themes to the storybook. The storybook’s widget also
      //* allows you to specify themeMode , which is set to ThemeMode.system by default.
      theme: lightThemeData,
      darkTheme: darkThemeData,
      //! 1. The children attribute gets a List<Story>. It’s better to keep the
      //! stories in a separate file to avoid duplicating them when you decide
      //! to add a CustomStorybook in addition to the default storybook.
      // Completed: add localization delegates
      //* Recall what you learned in Chapter 9, “Internationalizing & Localizing”.
      //* Since this is a component storybook, you only need
      //* ComponentLibraryLocalizations.delegate along with the default ones.
      localizationDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        ComponentLibraryLocalizations.delegate,
      ],
      children: [
        //! 5. Provides the stories with 'theme'. Using the WonderTheme instance
        //! from ancestors in the storybook ensures that theme is unified across
        //! your main app and the storybook app.
        ...getStories(theme),
      ],

      //* 2. The flutter_storybook library converts the Story's name to hyphen-separated
      //* lowercases words. For example, if you specify the Story's name as
      //* Rounded Choice Chip, its route becomes rounded-choice-chip. By giving
      //* initialRoute, you ensure a specific story is the current story.
      //* If you don't set initialRoute, you see a Select story message.
      initialRoute: 'rounded-choice-chip',
    );
  }
}
