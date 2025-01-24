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
    // TODO: Take in the events.
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

  // TODO: Create a utility function that fetches a given page.

  // TODO: Dispose the auth changes subscription.
}
