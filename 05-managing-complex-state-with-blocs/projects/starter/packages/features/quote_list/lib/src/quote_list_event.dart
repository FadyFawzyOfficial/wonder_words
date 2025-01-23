part of 'quote_list_bloc.dart';

// 1. Defined an abstract QuoteListEvent class to use as a common ancestral for
// all subsequent classes in this file. In quote_list_bloc.dart, you specify this
// class as your Bloc’s event type when declaring it.
abstract class QuoteListEvent extends Equatable {
  const QuoteListEvent();

  @override
  List<Object?> get props => [];
}

// 2. Created a QuoteListFilterByFavoritesToggled subclass to send to the Bloc
// when the user turns the favorites filter on or off.
class QuoteListFilterByFavoritesToggled extends QuoteListEvent {
  const QuoteListFilterByFavoritesToggled();
}

// 3. Created QuoteListTagChanged for when the user selects a new tag. The
// tag property is optional because the event can also be the user clearing a
// previously selected tag, in which case you’ll use null for the value.
class QuoteListTagChanged extends QuoteListEvent {
  final Tag? tag;

  const QuoteListTagChanged({this.tag});

  @override
  List<Object?> get props => [tag];
}

//4. Created QuoteListSearchTermChanged for when the user changes the
// content in the search bar.
class QuoteListSearchTermChanged extends QuoteListEvent {
  final String searchTerm;

  const QuoteListSearchTermChanged(this.searchTerm);

  @override
  List<Object?> get props => [searchTerm];
}

// 5. Created QuoteListRefreshed for when the user pulls the list down to force
// it to refresh.
class QuoteListRefreshed extends QuoteListEvent {
  const QuoteListRefreshed();
}

//! You’ll use this QuoteListNextPageRequested class on two occasions:
//! 1. When the user is scrolling down and nears the bottom of the page.
//! 2. If fetching a new page fails and the user taps the “try again” widget.
class QuoteListNextPageRequested extends QuoteListEvent {
  final int pageNumber;

  const QuoteListNextPageRequested({required this.pageNumber});
}

//! This one is a bit different. Notice that you added one more level to your class
//! hierarchy by creating a new abstract class, QuoteListItemFavoriteToggled .
//! This extends the previous class, QuoteListEvent .
//* Having this base QuoteListItemFavoriteToggled class allows you to share
//* some logic between QuoteListItemFavorited and
//* QuoteListItemUnfavorited when coding the Bloc later. You’ll use these two
//* concrete classes to represent the taps on the favorite button of a quote card:
abstract class QuoteListItemFavoriteToggled extends QuoteListEvent {
  final int id;

  const QuoteListItemFavoriteToggled(this.id);
}

class QuoteListItemFavorited extends QuoteListItemFavoriteToggled {
  const QuoteListItemFavorited(int id) : super(id);
}

class QuoteListItemUnfavorited extends QuoteListItemFavoriteToggled {
  const QuoteListItemUnfavorited(int id) : super(id);
}

//! 1. QuoteListFailedFetchRetried: Used when the user taps the main Try Again
//! button, which appears when an error occurs while trying to fetch the first page.
class QuoteListFailedFetchRetried extends QuoteListEvent {
  const QuoteListFailedFetchRetried();
}

//* 2. QuoteListUsernameObtained: Used to trigger the data fetching when the
//* screen first opens and you’ve obtained the signed-in user’s username. It’ll
//* also be used to refresh the list when the user signs in or out of the app at a
//* later time. It’s vital to refresh the list when the user’s authentication status
//* changes, so you reflect that user’s favorites accordingly.
class QuoteListUsernameObtained extends QuoteListEvent {
  const QuoteListUsernameObtained();
}

//! 3. QuoteListItemUpdated: Used when the user taps a quote and modifies it on
//! that quote’s details screen — favoriting it, unfavoriting, upvoting, etc. You
//! need this event so you can reflect that change on the home screen as well.
class QuoteListItemUpdated extends QuoteListEvent {
  final Quote updatedQuote;

  const QuoteListItemUpdated(this.updatedQuote);
}
