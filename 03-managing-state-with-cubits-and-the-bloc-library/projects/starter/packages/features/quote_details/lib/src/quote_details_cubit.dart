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
        );

  void _fetchQuoteDetails() async {
    // TODO: Featch data from QuoteRepository.
  }

  void refetch() async {
    // TODO: Add a body to refetch().
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
