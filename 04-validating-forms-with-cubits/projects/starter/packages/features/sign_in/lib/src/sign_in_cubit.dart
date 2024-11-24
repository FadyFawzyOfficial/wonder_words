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
    // 1. Grab your Cubit’s state property and assign it a more meaningful name
    // within this function.
    final previousScreenState = state;

    // 2. Use the previousScreenState variable to retrieve the previous state of the
    // password field.
    final previousPasswordState = previousScreenState.password;

    final shouldValidate = previousPasswordState.invalid;

    // 3. Recreate the state of the password field using the newValue received in the
    // function parameter.
    //! You use the validated constructor to force the validation to kick in while
    //! the user is still typing only if you were already showing a validation error for that field.
    final newPasswordState = shouldValidate
        ? Password.validated(newValue)
        //! Otherwise, if the previous value in that field hasn’t been validated yet
        //! or if it has been validated and considered valid
        //! you’ll wait until the user takes the focus out of that field to validate it.
        : Password.unvalidated(newValue);

    // 1. Used the copyWith function from the beginning of the chapter to create a
    // copy of the screen state, changing only the password property.
    final newScreenState = state.copyWith(password: newPasswordState);

    // 2. Emitted the new screen’s state.
    emit(newScreenState);
  }

  void onPasswordUnfocused() {
    final previousScreenState = state;
    final previousPasswordState = previousScreenState.password;

    // 1. Grabbed the latest value of the password field.
    final previousPasswordValue = previousPasswordState.value;

    // 2. Recreated the state of the password field by using the validated
    // constructor to force validation of the latest value.
    final newPasswordState = Password.validated(previousPasswordValue);

    // 3. Re-emitted the screen’s state with the new/validated password state.
    final newScreenState =
        previousScreenState.copyWith(password: newPasswordState);
    emit(newScreenState);
  }

  void onSubmit() async {
    // TODO: Handle the submit button's tap.
  }
}
