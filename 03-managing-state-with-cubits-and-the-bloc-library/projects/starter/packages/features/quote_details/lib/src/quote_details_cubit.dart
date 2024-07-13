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
    // TODO: Add a body to upvoteQuote().
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
