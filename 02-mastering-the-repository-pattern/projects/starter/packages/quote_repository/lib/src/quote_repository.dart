import 'package:domain_models/domain_models.dart';
import 'package:fav_qs_api/fav_qs_api.dart';
import 'package:key_value_storage/key_value_storage.dart';
import 'package:meta/meta.dart';
import 'package:quote_repository/src/mappers/mappers.dart';
import 'package:quote_repository/src/quote_local_storage.dart';

class QuoteRepository {
  // 1. Add constructor and data sources properties.

  //* There are a couple of things to note in there:
  //* First, take a look at the two final properties. As mentioned, repositories
  //* orchestrate multiple data sources. In this case, you have two:
  //* 1. FavQsApi: Retrieves and sends data to your remote API. FavQsApi comes
  //* from another internal package of this project: fav_qs_api.
  //* 2. QuoteLocalStorage: Retrieves and stores quotes in the device’s local storage.
  //* QuoteLocalStorage does not come from a separate package. It’s defined
  //* inside this same folder you’re working on.

  //? The first question you might have is: Why does FavQsApi have its own package
  //? while QuoteLocalStorage doesn’t?
  //! QuoteLocalStorage is more specialized because it only deals with quotes.
  //! Therefore, it has no utility outside the quote_repository package.

  //! FavQsApi , on the other hand, is more generic because it handles both quotes
  //! and authentication calls. That makes it suitable for the user_repository
  //! package as well, which you’ll cover in Chapter 6, “Authenticating Users”. As you
  //! know, when you need to share code between two packages — in this case, two
  //! repositories — you have to create a third one. In this case, that’s fav_qs_api.

  //* Although QuoteLocalStorage doesn’t come from a separate package, it
  //* depends on KeyValueStorage, which does come from the separate
  //* key_value_storage package.
  //* Think of KeyValueStorage as WonderWords’ local database. It’s a wrapper
  //* around the popular Hive package. It had to become an internal package of its
  //* own to concentrate all of the Hive configuration in a single place.
  final FavQsApi remoteApi;
  final QuoteLocalStorage _localStorage;

  QuoteRepository({
    required KeyValueStorage keyValueStorage,
    required this.remoteApi,
    @visibleForTesting QuoteLocalStorage? localStorage,
  }) : _localStorage =
            localStorage ?? QuoteLocalStorage(keyValueStorage: keyValueStorage);

  Stream<QuoteListPage> getQuoteListPage(
    int pageNumber, {
    Tag? tag,
    String searchTerm = '',
    String? favoritedByUsername,
    required QuoteListPageFetchPolicy fetchPolicy,
  }) async* {
    throw UnimplementedError();
  }

  Future<Quote> getQuoteDetails(int id) async {
    final cachedQuote = await _localStorage.getQuote(id);
    if (cachedQuote != null) {
      return cachedQuote.toDomainModel();
    } else {
      final apiQuote = await remoteApi.getQuote(id);
      final domainQuote = apiQuote.toDomainModel();
      return domainQuote;
    }
  }

  Future<Quote> favoriteQuote(int id) async {
    final updatedCacheQuote =
        await remoteApi.favoriteQuote(id).toCacheUpdateFuture(
              _localStorage,
              shouldInvalidateFavoritesCache: true,
            );
    return updatedCacheQuote.toDomainModel();
  }

  Future<Quote> unfavoriteQuote(int id) async {
    final updatedCacheQuote =
        await remoteApi.unfavoriteQuote(id).toCacheUpdateFuture(
              _localStorage,
              shouldInvalidateFavoritesCache: true,
            );
    return updatedCacheQuote.toDomainModel();
  }

  Future<Quote> upvoteQuote(int id) async {
    final updatedCacheQuote =
        await remoteApi.upvoteQuote(id).toCacheUpdateFuture(
              _localStorage,
            );
    return updatedCacheQuote.toDomainModel();
  }

  Future<Quote> downvoteQuote(int id) async {
    final updatedCacheQuote =
        await remoteApi.downvoteQuote(id).toCacheUpdateFuture(
              _localStorage,
            );
    return updatedCacheQuote.toDomainModel();
  }

  Future<Quote> unvoteQuote(int id) async {
    final updatedCacheQuote =
        await remoteApi.unvoteQuote(id).toCacheUpdateFuture(
              _localStorage,
            );
    return updatedCacheQuote.toDomainModel();
  }

  Future<void> clearCache() async {
    await _localStorage.clear();
  }
}

extension on Future<QuoteRM> {
  Future<QuoteCM> toCacheUpdateFuture(
    QuoteLocalStorage localStorage, {
    bool shouldInvalidateFavoritesCache = false,
  }) async {
    try {
      final updatedApiQuote = await this;
      final updatedCacheQuote = updatedApiQuote.toCacheModel();
      await Future.wait(
        [
          localStorage.updateQuote(
            updatedCacheQuote,
            !shouldInvalidateFavoritesCache,
          ),
          if (shouldInvalidateFavoritesCache)
            localStorage.clearQuoteListPageList(true),
        ],
      );
      return updatedCacheQuote;
    } catch (error) {
      if (error is UserAuthRequiredFavQsException) {
        throw UserAuthenticationRequiredException();
      }
      rethrow;
    }
  }
}

enum QuoteListPageFetchPolicy {
  cacheAndNetwork,
  networkOnly,
  networkPreferably,
  cachePreferably,
}
