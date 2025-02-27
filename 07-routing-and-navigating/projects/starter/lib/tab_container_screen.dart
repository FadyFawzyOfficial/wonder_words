import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:wonder_words/l10n/app_localizations.dart';

class TabContainerScreen extends StatelessWidget {
  const TabContainerScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    //* 1. CupertinoTabPage is a class that comes from the Routemaster package.
    //? As you can see a few lines below, CupertinoTabPage gives you the two pieces
    //? you need — a controller and a tabBuilder — to set up the tabbed layout
    //? structure using Flutter’s CupertinoTabScaffold . tabBuilder is
    //? responsible for building the inner screens you want to display for each tab.
    //* Meanwhile, controller controls the state of the bottom bar — which index
    //* is selected and such.
    final tabState = CupertinoTabPage.of(context);

    // 2. The simplest way to implement bottom-tabbed screens is using this
    // CupertinoTabScaffold from the cupertino library. Notice this is the first
    // time you’re using a widget from cupertino instead of material.
    //* A nice historical background to have in mind is that bottom-tabbed layouts were
    //* first popularized by iOS apps — the opposing standard on Android used to be
    //* navigation drawers. Bottom tabs quickly became as popular on Android as
    //* they were on iOS. Even Google apps started adopting them — YouTube is a great example.
    return CupertinoTabScaffold(
      controller: tabState.controller,
      tabBuilder: tabState.tabBuilder,
      tabBar: CupertinoTabBar(items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.format_quote_rounded),
          // 3. retrieve a localized String in WonderWords.
          label: l10n.quotesBottomNavigationBarItemLabel,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_rounded),
          label: l10n.profileBottomNavigationBarItemLabel,
        ),
      ]),
    );
  }
}
