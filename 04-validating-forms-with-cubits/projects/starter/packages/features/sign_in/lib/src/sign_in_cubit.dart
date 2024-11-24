import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_fields/form_fields.dart';
import 'package:user_repository/user_repository.dart';

part 'sign_in_state.dart';

// 1. Created a new Cubit by creating a class that extends Cubit and has
// SignInState specified as the state type.
class SignInCubit extends Cubit<SignInState> {
  final UserRepository userRepository;

  SignInCubit({
    // 2. Requested a UserRepository to be passed through your constructor.
    // UserRepository is the class you’ll use to ultimately send the sign-in request
    // to the server. Don’t worry about the internals of UserRepository yet
    // that’s for Chapter 6, “Authenticating Users”.
    required this.userRepository,
  }) : super(
          // 3. Instantiated a SignInState using all the default values as your Cubit’s initial state.
          const SignInState(),
        );

  void onEmailChanged(String newValue) {
    final previousScreenState = state;
    final previousEmailState = previousScreenState.email;
    final shouldValidate = previousEmailState.invalid;
    final newEmailState = shouldValidate
        ? Email.validated(newValue)
        : Email.unvalidated(newValue);

    final newScreenState = state.copyWith(email: newEmailState);

    emit(newScreenState);
  }

  void onEmailUnfocused() {
    final perviousScreenState = state;
    final previousEmailState = perviousScreenState.email;
    final previousEmailValue = previousEmailState.value;

    final newEmailState = Email.validated(previousEmailValue);
    final newScreenState = perviousScreenState.copyWith(email: newEmailState);
    emit(newScreenState);
  }

  void onPasswordChanged(String newValue) {
    // TODO: Handle the user changing the value of the password field.
  }

  void onPasswordUnfocuesed() {
    // TODO: Handle the user taking the focus out of the password field.
  }

  void onSubmit() async {
    // TODO: Handle the submit button's tap.
  }
}
