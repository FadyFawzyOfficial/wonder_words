import 'package:component_library/component_library.dart';
import 'package:domain_models/domain_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quote_details/src/quote_details_cubit.dart';
import 'package:quote_repository/quote_repository.dart';
import 'package:share_plus/share_plus.dart';

typedef QuoteDetailsShareableLinkGenerator = Future<String> Function(
  Quote quote,
);

class QuoteDetailsScreen extends StatelessWidget {
  const QuoteDetailsScreen({
    required this.quoteId,
    required this.onAuthenticationError,
    required this.quoteRepository,
    this.shareableLinkGenerator,
    Key? key,
  }) : super(key: key);

  final int quoteId;
  final VoidCallback onAuthenticationError;
  final QuoteRepository quoteRepository;
  final QuoteDetailsShareableLinkGenerator? shareableLinkGenerator;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuoteDetailsCubit(
        quoteId: quoteId,
        quoteRepository: quoteRepository,
      ),
      child: QuoteDetailsView(
        onAuthenticationError: onAuthenticationError,
        shareableLinkGenerator: shareableLinkGenerator,
      ),
    );
  }
}

@visibleForTesting
class QuoteDetailsView extends StatelessWidget {
  const QuoteDetailsView({
    required this.onAuthenticationError,
    this.shareableLinkGenerator,
    Key? key,
  }) : super(key: key);

  final VoidCallback onAuthenticationError;
  final QuoteDetailsShareableLinkGenerator? shareableLinkGenerator;

  @override
  Widget build(BuildContext context) {
    return StyledStatusBar.dark(
      child: BlocConsumer<QuoteDetailsCubit, QuoteDetailsState>(
        listener: (context, state) {
          final quoteUpdateError =
              state is QuoteDetailsSuccess ? state.quoteUpdateError : null;
          if (quoteUpdateError != null) {
            //? The biggest driver here is the fact that the user has to be signed in to vote or
            //? favorite a quote in WonderWords. So, if the cause of the error is the user not
            //? being signed in, you’re:
            //! 1. Showing them a more specific snackbar.
            final snackBar =
                quoteUpdateError is UserAuthenticationRequiredException
                    ? const AuthenticationRequiredErrorSnackBar()
                    : const GenericErrorSnackBar();

            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(snackBar);

            //* 2. Sending them over to the sign-in screen. Actually, you’re just calling the
            //* onAuthenticationError callback you received in the constructor; the main
            //* application package will handle the actual navigation for you.
            //* The purpose of that is to prevent feature packages from depending on one another.
            if (quoteUpdateError is UserAuthenticationRequiredException) {
              onAuthenticationError();
            }
          }
        },
        builder: (context, state) => WillPopScope(
          onWillPop: () async {
            //* 1. The WillPopScope widget allows you to intercept when the user
            //* tries to navigate bake form the screen. You're using that to send
            //* the current quote back to the home screen if the current state is
            //* a QuoteDetailsSuccess.
            //! That's necessary so the previous screen can check whether the user
            //! has favorited or unfavorited the quote and use that to also
            //! reflect that accordingly. None of that has to do with BLoC
            //! specifically; it's just how the app inter-screen communications
            //! works. More on this in Chapter 7, "Routing & Navigating".
            final displayedQuote =
                state is QuoteDetailsSuccess ? state.quote : null;
            Navigator.of(context).pop(displayedQuote);
            return false;
          },
          child: Scaffold(
            //! 2. Here, you're inspecting the state object to update the UI accordingly.
            //! If the state is anything other than a success, you don't show the app bar.
            appBar: state is QuoteDetailsSuccess
                ? _QuoteActionsAppBar(
                    quote: state.quote,
                    shareableLinkGenerator: shareableLinkGenerator,
                  )
                : null,
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(WonderTheme.of(context).screenMargin),
                //! 3. You're doing the same thing you did in the previous step,
                //! but now for the bulk of the screen's content.
                child: state is QuoteDetailsSuccess
                    ? _Quote(quote: state.quote)
                    : state is QuoteDetailsFailure
                        ? ExceptionIndicator(
                            onTryAgain: () {
                              //! 4. BlocBuilder gives you that state object inside the builder , but it
                              //! doesn’t give you the actual Cubit in case you want to call a function — send an
                              //! event — on it. Using this context.read<YourCubitType>() is how you get the
                              //! instance of your Cubit to call functions on it.
                              final cubit = context.read<QuoteDetailsCubit>();
                              cubit.refetch();
                            },
                          )
                        //! 5. If the state is neither a QuoteDetailsSuccess nor a QuoteDetailsFailure ,
                        //! you know for sure it’s a QuoteDetailsInProgress .
                        : const CenteredCircularProgressIndicator(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuoteActionsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _QuoteActionsAppBar({
    required this.quote,
    this.shareableLinkGenerator,
    Key? key,
  }) : super(key: key);

  final Quote quote;
  final QuoteDetailsShareableLinkGenerator? shareableLinkGenerator;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<QuoteDetailsCubit>();
    final shareableLinkGenerator = this.shareableLinkGenerator;
    return RowAppBar(
      children: [
        FavoriteIconButton(
          isFavorite: quote.isFavorite ?? false,
          onTap: () {
            if (quote.isFavorite == true) {
              cubit.unfavoriteQuote();
            } else {
              cubit.favoriteQuote();
            }
          },
        ),
        UpvoteIconButton(
          count: quote.upvotesCount,
          isUpvoted: quote.isUpvoted ?? false,
          onTap: () {
            if (quote.isUpvoted == true) {
              cubit.unvoteQuote();
            } else {
              cubit.upvoteQuote();
            }
          },
        ),
        DownvoteIconButton(
          count: quote.downvotesCount,
          isDownvoted: quote.isDownvoted ?? false,
          onTap: () {
            if (quote.isDownvoted == true) {
              cubit.unvoteQuote();
            } else {
              cubit.downvoteQuote();
            }
          },
        ),
        if (shareableLinkGenerator != null)
          ShareIconButton(
            onTap: () async {
              final url = await shareableLinkGenerator(quote);
              Share.share(
                url,
              );
            },
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _Quote extends StatelessWidget {
  static const double _quoteIconWidth = 46;

  const _Quote({
    required this.quote,
    Key? key,
  }) : super(key: key);

  final Quote quote;

  @override
  Widget build(BuildContext context) {
    final theme = WonderTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: OpeningQuoteSvgAsset(
            width: _quoteIconWidth,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.xxLarge,
            ),
            child: Center(
              child: ShrinkableText(
                quote.body,
                style: theme.quoteTextStyle.copyWith(
                  fontSize: FontSize.xxLarge,
                ),
              ),
            ),
          ),
        ),
        const ClosingQuoteSvgAsset(
          width: _quoteIconWidth,
        ),
        const SizedBox(
          height: Spacing.medium,
        ),
        Text(
          quote.author ?? '',
          style: const TextStyle(
            fontSize: FontSize.large,
          ),
        ),
      ],
    );
  }
}
