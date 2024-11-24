part of 'sign_in_cubit.dart';

enum SubmissionStatus {
  /// Used when the form has not been sent yet.
  idle,

  /// Used to disable all buttons and add a progress indicator to the main one.
  inProgress,

  /// Used to close the screen and navigate back to the caller screen.
  success,

  /// Used to display a generic snack bar saying that an error has occurred, e.g., no internet connection.
  genericError,

  /// Used to show a more specific error telling the user they got the email and/or password wrong.
  invalidCredentialsError,
}

class SignInState extends Equatable {
  final Email email;
  final Password password;
  final SubmissionStatus? submissionStatus;

  // 1. You need a separate property to hold the state of each field on the screen.
  // You’ll dive into these Email and Password classes in the next section.
  const SignInState({
    this.email = const Email.unvalidated(),
    this.password = const Password.unvalidated(),
    //* 2. This enum property will serve to inform your UI on the state of the latest
    //* submission try. If it’s null , it means the user hasn’t tried to submit the form
    //* just yet. The property’s type is SubmissionStatus , an enum at the top of
    //* this same file. Take a look at it.
    this.submissionStatus,
  });

  // 3. Creating a copyWith function is a simple pattern that’s used a lot in Flutter.
  // The only thing it does is instantiate a copy of the current object by changing
  // just the properties you choose to pass on to the function when calling it. For
  // example, if you call oldSignInState.copyWith(password: newPassword) ,
  // you’ll get a new SignInState object that holds the same values as
  // oldSignInState , except for the password property, which will use the
  // newPassword value instead. You can learn more about it in this article on
  // copyWith() . This function will come in handy when coding the Cubit later
  SignInState copyWith({
    Email? email,
    Password? password,
    SubmissionStatus? submissionStatus,
  }) {
    return SignInState(
      email: email ?? this.email,
      password: password ?? this.password,
      submissionStatus: submissionStatus ?? this.submissionStatus,
    );
  }

  // 4. You learned all about Equatable and this props property in the last
  // chapter. Check out this overview of Equatable if you need a refresher.
  @override
  List<Object?> get props => [email, password, submissionStatus];
}
