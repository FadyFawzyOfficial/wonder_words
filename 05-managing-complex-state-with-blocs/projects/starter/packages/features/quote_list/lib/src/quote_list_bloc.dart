import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:domain_models/domain_models.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quote_repository/quote_repository.dart';
import 'package:rxdart/rxdart.dart';
import 'package:user_repository/user_repository.dart';

part 'quote_list_event.dart';

part 'quote_list_state.dart';

// 1. This QuoteListBloc class extends Bloc and specifies two generic types:
// the event class, QuoteListEvent , and the state class, QuoteListState.
class QuoteListBloc extends Bloc<QuoteListEvent, QuoteListState> {
  QuoteListBloc({
    required QuoteRepository quoteRepository,
    required UserRepository userRepository,
  })  :
        // 2. QuoteListBloc ‘s constructor then receives two repositories and assigns
        // one of them to the _quoteRepository property.
        //* You didn’t have to assign userRepository to a property of the
        //* QuoteListBloc class — as you did for quoteRepository —
        //! because you’ll only use it inside the constructor’s code.
        _quoteRepository = quoteRepository,
        // 3. You then call the super constructor and pass it to your initial state, which is
        // just a QuoteListState instantiated with all the default values.
        super(const QuoteListState()) {
    // 4. Here, you’re calling a function you’ll implement later to handle all your events.
    _registerEventHandler();

    // Completed: Watch the user's authentication status.

    _authChangesSubscription = userRepository
        //* 1. UserRepository has a getUser() function that returns a Stream<User?> .
        //* That Stream is useful for monitoring changes in the user’s authentication
        //* status. When the user signs in, a new User object comes down that
        //* Stream . When they sign out, you get a null value instead.
        .getUser()
        //* 2. You then subscribe to that Stream using the listen() function. The
        //* listen() function returns an object, called the subscription.
        //! You store the  subscription object in the _authChangesSubscription
        //! property, so you can dispose of it later.
        .listen(
      (user) {
        // 3. Every time you get a new value from that Stream , you store the new
        // username inside the _authenticatedUsername property. This allows you to
        // read that value from other parts of your Bloc’s code.
        _authenticatedUsername = user?.username;

        // 4. This is a bit different from what you did before… Here, you’re adding an event
        // to the Bloc from inside the Bloc itself — so far, you’ve only used this add()
        // function from the widgets’ side.
        add(const QuoteListUsernameObtained());
      },
    );
  }

  // 5. You’ll learn all about these _authChangesSubscription and
  // _authenticatedUsername properties in a moment.
  late final StreamSubscription _authChangesSubscription;
  String? _authenticatedUsername;

  final QuoteRepository _quoteRepository;

  void _registerEventHandler() {
    // Completed: Take in the events.
    //* 1. Call the on() function and use the angle brackets to specify the type
    //* of the events you want to register the handler for. In this case, it's
    //* QuoteListEvent, which encompasses all the event types you created at the beginning.
    on<QuoteListEvent>(
      //* 2. Pass in a callback to the on() function. That callback takes in the
      //* actual event object sent by the UI and emitter object you have to use
      //* to send new states back to the UI.
      (event, emitter) async {
        //! 3. Create if blocks for each type of event you can receive and then
        //! call the corresponding functions that handle each one of them.
        if (event is QuoteListUsernameObtained) {
          await _handleQuoteListUsernameObtained(emitter);
        } else if (event is QuoteListFailedFetchRetried) {
          await _handleQuoteListFailedFetchRetried(emitter);
        } else if (event is QuoteListItemUpdated) {
          _handleQuoteListItemUpdated(emitter, event);
        } else if (event is QuoteListTagChanged) {
          await _handleQuoteListTagChanged(emitter, event);
        } else if (event is QuoteListSearchTermChanged) {
          await _handleQuoteListSearchTermChanged(emitter, event);
        } else if (event is QuoteListRefreshed) {
          await _handleQuoteListRefreshed(emitter, event);
        } else if (event is QuoteListNextPageRequested) {
          await _handleQuoteListNextPageRequested(emitter, event);
        } else if (event is QuoteListItemFavoriteToggled) {
          await _handleQuoteListItemFavoriteToggled(emitter, event);
        } else if (event is QuoteListFilterByFavoritesToggled) {
          await _handleQuoteListFilterByFavoritesToggled(emitter);
        }
      },

      // ToDo: Customize how events are processed.
    );
  }

  Future<void> _handleQuoteListUsernameObtained(Emitter emitter) async {
    // TODO: Handle QuoteListUsernameObtained.
  }

  Future<void> _handleQuoteListFailedFetchRetried(Emitter emitter) {
    // Clears out the error and puts the loading indicator back on the screen.
    emitter(
      state.copyWithNewError(null),
    );

    final firstPageFetchStream = _fetchQuotePage(
      1,
      fetchPolicy: QuoteListPageFetchPolicy.cacheAndNetwork,
    );

    return emitter.onEach<QuoteListState>(
      firstPageFetchStream,
      onData: emitter,
    );
  }

  void _handleQuoteListItemUpdated(
    Emitter emitter,
    QuoteListItemUpdated event,
  ) {
    // Replaces the updated quote in the current state and re-emits it.
    emitter(
      state.copyWithUpdatedQuote(
        event.updatedQuote,
      ),
    );
  }

  Future<void> _handleQuoteListTagChanged(
    Emitter emitter,
    QuoteListTagChanged event,
  ) {
    emitter(
      QuoteListState.loadingNewTag(tag: event.tag),
    );

    final firstPageFetchStream = _fetchQuotePage(
      1,
      // If the user is *deselecting* a tag, the `cachePreferably` fetch policy
      // will return you the cached quotes. If the user is selecting a new tag
      // instead, the `cachePreferably` fetch policy won't find any cached
      // quotes and will instead use the network.
      fetchPolicy: QuoteListPageFetchPolicy.cachePreferably,
    );

    return emitter.onEach<QuoteListState>(
      firstPageFetchStream,
      onData: emitter,
    );
  }

  Future<void> _handleQuoteListSearchTermChanged(
    Emitter emitter,
    QuoteListSearchTermChanged event,
  ) {
    emitter(
      QuoteListState.loadingNewSearchTerm(
        searchTerm: event.searchTerm,
      ),
    );

    final firstPageFetchStream = _fetchQuotePage(
      1,
      // If the user is *clearing out* the search bar, the `cachePreferably`
      // fetch policy will return you the cached quotes. If the user is
      // entering a new search instead, the `cachePreferably` fetch policy
      // won't find any cached quotes and will instead use the network.
      fetchPolicy: QuoteListPageFetchPolicy.cachePreferably,
    );

    return emitter.onEach<QuoteListState>(
      firstPageFetchStream,
      onData: emitter,
    );
  }

  Future<void> _handleQuoteListRefreshed(
    Emitter emitter,
    QuoteListRefreshed event,
  ) {
    final firstPageFetchStream = _fetchQuotePage(
      1,
      // Since the user is asking for a refresh, you don't want to get cached
      // quotes, thus the `networkOnly` fetch policy makes the most sense.
      fetchPolicy: QuoteListPageFetchPolicy.networkOnly,
      isRefresh: true,
    );

    return emitter.onEach<QuoteListState>(
      firstPageFetchStream,
      onData: emitter,
    );
  }

  Future<void> _handleQuoteListNextPageRequested(
    Emitter emitter,
    QuoteListNextPageRequested event,
  ) {
    emitter(
      state.copyWithNewError(null),
    );

    final nextPageFetchStream = _fetchQuotePage(
      event.pageNumber,
      // The `networkPreferably` fetch policy prioritizes fetching the new page
      // from the server, and, if it fails, try grabbing it from the cache.
      fetchPolicy: QuoteListPageFetchPolicy.networkPreferably,
    );

    return emitter.onEach<QuoteListState>(
      nextPageFetchStream,
      onData: emitter,
    );
  }

  Future<void> _handleQuoteListItemFavoriteToggled(
    Emitter emitter,
    QuoteListItemFavoriteToggled event,
  ) async {
    try {
      // The `favoriteQuote()` and `unfavoriteQuote()` functions return you the
      // updated quote object.
      final updatedQuote = await (event is QuoteListItemFavorited
          ? _quoteRepository.favoriteQuote(
              event.id,
            )
          : _quoteRepository.unfavoriteQuote(
              event.id,
            ));
      final isFilteringByFavorites = state.filter is QuoteListFilterByFavorites;

      // If the user isn't filtering by favorites, you just replace the changed
      // quote on-screen.
      if (!isFilteringByFavorites) {
        emitter(
          state.copyWithUpdatedQuote(
            updatedQuote,
          ),
        );
      } else {
        // If the user *is* filtering by favorites, that means the user is
        // actually *removing* a quote from the list, so you refresh the entire
        // list to make sure you won't break the pagination.
        emitter(
          QuoteListState(
            filter: state.filter,
          ),
        );

        final firstPageFetchStream = _fetchQuotePage(
          1,
          fetchPolicy: QuoteListPageFetchPolicy.networkOnly,
        );

        await emitter.onEach<QuoteListState>(
          firstPageFetchStream,
          onData: emitter,
        );
      }
    } catch (error) {
      // If an error happens trying to (un)favorite a quote you attach an error
      // to the current state which will result on the screen showing a snackbar
      // to the user and possibly taking him to the Sign In screen in case the
      // cause is the user being signed out.
      emitter(
        state.copyWithFavoriteToggleError(
          error,
        ),
      );
    }
  }

  Future<void> _handleQuoteListFilterByFavoritesToggled(
    Emitter emitter,
  ) {
    final isFilteringByFavorites = state.filter is! QuoteListFilterByFavorites;

    emitter(
      QuoteListState.loadingToggledFavoritesFilter(
        isFilteringByFavorites: isFilteringByFavorites,
      ),
    );

    final firstPageFetchStream = _fetchQuotePage(
      1,
      // If the user is *adding* the favorites filter, you use the *cacheAndNetwork*
      // fetch policy to show the cached data first followed by the updated list
      // from the server.
      // If the user is *removing* the favorites filter, you simply show the
      // cached data they were seeing before applying the filter.
      fetchPolicy: isFilteringByFavorites
          ? QuoteListPageFetchPolicy.cacheAndNetwork
          : QuoteListPageFetchPolicy.cachePreferably,
    );

    return emitter.onEach<QuoteListState>(
      firstPageFetchStream,
      onData: emitter,
    );
  }

  // Completed: Create a utility function that fetches a given page.
  Stream<QuoteListState> _fetchQuotePage(
    int page, {
    required QuoteListPageFetchPolicy fetchPolicy,
    bool isRefresh = false,
  }) async* {
    //* 1. Retrieve the currently applied filter, which can be either a search filter,
    //* favorites filter or tag filter.
    final currentlyAppliedFilter = state.filter;

    // 2. Check if the user is currently filtering by favorites.
    final isFilteringByFavorites =
        currentlyAppliedFilter is QuoteListFilterByFavorites;

    // Check if the user is signed in.
    final isUserSignedIn = _authenticatedUsername != null;

    if (isFilteringByFavorites && !isUserSignedIn) {
      //* 4. Use the yield keyword to emit a new state to the new Stream you’re
      //* generating within this function.
      yield QuoteListState.noItemsFound(filter: currentlyAppliedFilter);
    } else {
      // Completed: Fetch the Page.
      final pageStream = _quoteRepository.getQuoteListPage(
        page,
        fetchPolicy: fetchPolicy,
        tag: currentlyAppliedFilter is QuoteListFilterByTag
            ? currentlyAppliedFilter.tag
            : null,
        searchTerm: currentlyAppliedFilter is QuoteListFilterBySearchTerm
            ? currentlyAppliedFilter.searchTerm
            : '',
        favoritedByUsername:
            currentlyAppliedFilter is QuoteListFilterByFavorites
                ? _authenticatedUsername
                : null,
      );

      try {
        // 1. Listen to the Stream you got from the repository by using this await for syntax.
        //? What it does is run the code inside the for block every time your
        //? pageStream emits a new item.
        //! The only time it actually emits more than one item, though,
        //! is when you build the Stream using the QuoteListPageFetchPolicy.cacheAndNetwork
        //! fetch policy, which you’ll do when the user first opens the screen.
        await for (final newPage in pageStream) {
          final newItemList = newPage.quoteList;
          final oldItemList = state.itemList ?? [];

          //* 2. Then, for every new page you get, you append the new items to the old ones
          //* you already have on the screen. This is assuming the user isn’t trying to
          //* refresh the data, in which case you’ll instead replace the previous items.
          final completedItemList = isRefresh || page == 1
              ? newItemList
              : (oldItemList + newItemList);

          final nextPage = newPage.isLastPage ? null : page + 1;

          // 3. yield a new QuoteListState containing all the new data you got from the repository.
          yield QuoteListState.success(
            nextPage: nextPage,
            itemList: completedItemList,
            filter: currentlyAppliedFilter,
            isRefresh: isRefresh,
          );
        }
      } catch (error) {
        //! You also have to be prepared for the case in which you can’t get that new page
        //! for some reason. For example, the user might not have an internet connection.
        // Completed: Handle errors.
        if (error is EmptySearchResultException) {
          //! 1. If the error is an EmptySearchResultException , you’ll treat it differently.
          //! Instead of emitting an “error” state, which would cause the UI to show a Try
          //! Again button, you’ll emit an `empty state`, which will show the user a more
          //! descriptive message saying you couldn’t find any items for the current filters.
          //! It’s the same state you use when a signed out user tries to filter by favorites.
          yield QuoteListState.noItemsFound(filter: currentlyAppliedFilter);
        }

        if (isRefresh) {
          //* 2. You’ll also emit a different state if this error occurred during a refresh request.
          //! When the user intentionally asks for a refresh, it means they already
          //! have some items on the screen, so there’s no reason for you to hide those
          //! items and show a full-screen error widget. In that case, the best thing to do is
          //! notify them of the error with a snackbar.
          yield state.copyWithNewRefreshError(error);
        } else {
          //! 3. Finally, if this is an unexpected error, just re-emit the current state with an
          //! error added to it. The UI will take care of showing a full-screen error widget if
          //! the user is trying to fetch the first page. Otherwise, it will append an error
          //! item to the grid if this is a subsequent page request.
          yield state.copyWithNewError(error);
        }
      }
    }
  }

  // Completed: Dispose the auth changes subscription.
  //? Here, you’re just overriding your Bloc’s close() function to insert the code
  //? that cancels your subscription. This ensures your subscription won’t remain
  //? active after the user closes the screen.
  @override
  Future<void> close() {
    _authChangesSubscription.cancel();
    return super.close();
  }
}
