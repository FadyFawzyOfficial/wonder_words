import 'package:domain_models/domain_models.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quote_repository/quote_repository.dart';

part 'quote_details_state.dart';

//! Creating a Cubit

// 1. To create a Cubit, you have to extend Cubit and specify your base state class
// as the generic type. The only reason you're able to import the Cubit class in
// this file is because this quote_details packages's pubspec.yaml lists flutter_bloc
// as a dependency.
class QuoteDetailsCubit extends Cubit<QuoteDetailsState> {
  final int quoteId;
  //? 3. You'll use the QuoteRepository you crated in the previous.
  final QuoteRepository quoteRepository;

  QuoteDetailsCubit({
    required this.quoteId,
    required this.quoteRepository,
  }) : super(
          //* 2. When extending Cubit, you have to call the super constructor and
          //* pass an instance olf your initial state to it. This value is what
          //* the Cubit will provide to the UI when the screen first opens.
          const QuoteDetailsInProgress(),
        ) {
    //! Notice you’re calling this _fetchQuoteDetails() from your constructor.
    //! That will cause your Cubit to fetch this data as soon as you open the screen.
    _fetchQuoteDetails();
  }

  void _fetchQuoteDetails() async {
    //! Note: You didn’t have to emit() a QuoteDetailsInProgress at the beginning
    //! of the function because you already defined it as your initial state
    //! using the super constructor.
    //* Fetch data from QuoteRepository.
    try {
      //* 1. Used the quoteId received in the constructor to fetch the entire Quote
      //* object form QuoteRepository.
      final quote = await quoteRepository.getQuoteDetails(quoteId);
      //! 2. Called emit() form within a Cubit, which is how you send new state
      //! objects to your widget layer. You'll learn how to react to those from
      //! the UI side.
      emit(QuoteDetailsSuccess(quote: quote));
    } catch (error) {
      emit(const QuoteDetailsFailure());
    }
  }

  void refetch() async {
    //! 1. Reset your Cubit to its initial state, QuoteDetailsInProgress, so the
    //! UI shows the progress indicator again.
    emit(const QuoteDetailsInProgress());

    //* 2. Recall the function you created in the previous to fetch the quote
    //* form QuoteRepository
    _fetchQuoteDetails();
  }

  void upvoteQuote() async {
    try {
      final updatedQuote = await quoteRepository.upvoteQuote(quoteId);
      emit(QuoteDetailsSuccess(quote: updatedQuote));
    } catch (error) {
      //* 1. The state property of a Cubit contains the last state you emitted. Here,
      //* you’re assigning state to a local variable, so you’re able to leverage Dart’s
      //* type promotion inside the if block below.
      //! Type promotion just means Dart will automatically convert lastState ’s
      //! type from QuoteDetailsState to QuoteDetailsSuccess if it passes that if condition.
      //! You can learn more about why this only works with local variables in Dart’s documentation.
      final lastState = state;
      //! 2. You know for sure state will be a QuoteDetailsSuccess since the upvote
      //! button doesn’t even appear in the other states.
      if (lastState is QuoteDetailsSuccess) {
        //! 3. You’re basically re-emitting the previous state, but now with an
        //! error in the quoteUpdateError property.
        emit(
          QuoteDetailsSuccess(
            quote: lastState.quote,
            quoteUpdateError: error,
          ),
        );
      }
    }
  }

  void downvoteQuote() async {
    // TODO: Challenge.
  }

  void unvoteQuote() async {
    // TODO: Challenge.
  }

  void favoriteQuote() async {
    // TODO: Challenge.
  }
  void unfavoriteQuote() async {
    // TODO: Challenge.
  }
}
