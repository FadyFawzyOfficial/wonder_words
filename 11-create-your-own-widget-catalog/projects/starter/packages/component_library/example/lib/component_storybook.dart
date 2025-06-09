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
    final theme = WonderTheme.of(context);
    return Storybook(
      //! 1. The children attribute gets a List<Story>. It’s better to keep the
      //! stories in a separate file to avoid duplicating them when you decide
      //! to add a CustomStorybook in addition to the default storybook.
      children: [
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
