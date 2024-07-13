part of 'quote_details_cubit.dart';

//! Using Inheritance to Solve the Logical Dependency Issue

//* 1. You defined a base QuoteDetailsState, which is abstract, meaning you can't
//* instantiate it. It just servers as a common ancestor to the subsequent classes.
abstract class QuoteDetailsState extends Equatable {
  const QuoteDetailsState();
}

//* 2. You then created 3 concrete children for QuoteDetailsState from the previous
//* step: QuoteDetailsInProgress, QuoteDetailsSuccess and QuoteDetailsFailure.
class QuoteDetailsInProgress extends QuoteDetailsState {
  const QuoteDetailsInProgress();

  //? 3. you had to override props in all the children classes because the parent
  //? QuoteDetailsState extends Equatable.
  @override
  List<Object?> get props => [];
}

class QuoteDetailsSuccess extends QuoteDetailsState {
  //! 4. QuoteDetailsSuccess is the only class where having a quote property makes sense.
  final Quote quote;
  // TODO: Add new property.

  const QuoteDetailsSuccess({
    required this.quote,
    // TODO: Receive new property.
  });

  @override
  List<Object?> get props => [
        quote,
        // TODO: List new property.
      ];
}

class QuoteDetailsFailure extends QuoteDetailsState {
  const QuoteDetailsFailure();

  @override
  List<Object?> get props => [];
}
