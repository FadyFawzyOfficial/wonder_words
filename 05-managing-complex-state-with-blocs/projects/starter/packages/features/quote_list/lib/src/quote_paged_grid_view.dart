import 'package:component_library/component_library.dart';
import 'package:domain_models/domain_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:quote_list/quote_list.dart';
import 'package:quote_list/src/quote_list_bloc.dart';

class QuotePagedGridView extends StatelessWidget {
  static const _gridColumnCount = 2;

  const QuotePagedGridView({
    required this.pagingController,
    this.onQuoteSelected,
    Key? key,
  }) : super(key: key);

  final PagingController<int, Quote> pagingController;
  final QuoteSelected? onQuoteSelected;

  @override
  Widget build(BuildContext context) {
    final theme = WonderTheme.of(context);
    final onQuoteSelected = this.onQuoteSelected;
    final bloc = context.read<QuoteListBloc>();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: theme.screenMargin,
      ),
      // For a deep dive on how the pagination works, refer to: https://www.raywenderlich.com/14214369-infinite-scrolling-pagination-in-flutter
      child: PagedMasonryGridView.count(
        pagingController: pagingController,
        builderDelegate: PagedChildBuilderDelegate<Quote>(
          itemBuilder: (context, quote, index) {
            final isFavorite = quote.isFavorite ?? false;
            return QuoteCard(
              statement: quote.body,
              author: quote.author,
              isFavorite: isFavorite,
              top: const OpeningQuoteSvgAsset(),
              bottom: const ClosingQuoteSvgAsset(),
              // Completed: Forward taps on the favorite button.
              onFavorite: () => bloc.add(isFavorite
                  ? QuoteListItemUnfavorited(quote.id)
                  : QuoteListItemFavorited(quote.id)),
              onTap: onQuoteSelected != null
                  ? () async {
                      // Completed: Open the details screen and notify the Bloc if the user modified the quote in there.
                      //* 1.Call the onQuoteSelected callback this widget received on its constructor. If
                      //* you trace back that callback’s origin, you’ll find its declaration in the main
                      //* application package. What it does is simply open the quote details screen and
                      //* then return the updated quote object to you when the user closes that screen.
                      final updatedQuote = await onQuoteSelected(quote.id);
                      // 2. Check if the user has favorited or unfavorited the quote while in the details screen.
                      if (updatedQuote != null &&
                          updatedQuote.isFavorite != quote.isFavorite) {
                        //! 3. If the user did change the quote’s favorite status, send the updated quote
                        //! object to the Bloc so it can replace the old one currently on screen.
                        bloc.add(QuoteListItemUpdated(updatedQuote));
                      }
                    }
                  : null,
            );
          },
          firstPageErrorIndicatorBuilder: (context) {
            return ExceptionIndicator(
              // Completed: Request the first page again.
              onTryAgain: () => bloc.add(const QuoteListFailedFetchRetried()),
            );
          },
        ),
        crossAxisCount: _gridColumnCount,
        crossAxisSpacing: theme.gridSpacing,
        mainAxisSpacing: theme.gridSpacing,
      ),
    );
  }
}
