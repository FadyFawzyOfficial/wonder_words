import 'package:domain_models/domain_models.dart';
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
    // 1. When the user taps the Sign In button, you want to validate the two fields no
    // matter what — even if the user hasn’t touched the fields at all and tapping the
    // button is their first action after opening the screen.
    final email = Email.validated(state.email.value);
    final password = Password.validated(state.password.value);

    // 2. This is an alternative way of checking if all fields are valid. You could’ve used
    // email.valid && password.valid instead, but the way you did it here scales
    // better — it’s easier to add and remove fields.
    final isFormValid = Formz.validate([email, password]).isValid;

    // 3. You then create a new state for the screen using the updated fields. Emitting
    // this new state in step five is what will cause any errors to show up in the TextField s.
    final newState = state.copyWith(
      email: email,
      password: password,
      // 4. If the form is valid, you’ll change the submissionStatus to
      // SubmissionStatus.inProgress so you can use that information in your
      // widgets to display a loading indicator.
      submissionStatus: isFormValid ? SubmissionStatus.inProgress : null,
    );

    // 5. You’re emitting a new state even though you still have work left to do in this
    // function. You’re doing this so your screen updates the fields and puts the
    // loading indicator before you send the actual request to the server.
    emit(newState);

    // 1. Notice this if has no corresponding else statement. If the fields aren’t
    // valid, you don’t need to do anything else. You’ve already emitted the new
    // state from the code in the previous snippet, and at this point, the screen will
    // already show the errors on the fields.
    if (isFormValid) {
      try {
        // 2. Finally, if the values inserted by the user are valid, send them to the server.
        await userRepository.signIn(email.value, password.value);

        // 3. If your code gets to this line, it means the server returned a successful
        // response. UserRepository will take care of storing the user information
        // locally and refreshing the other screens for you — details in Chapter 6,
        // “Authenticating Users”. All you have to do here is set your
        // submissionStatus to SubmissionStatus.success so you can use that
        // information in your widget shortly to close the screen.
        final newState = state.copyWith(
          submissionStatus: SubmissionStatus.success,
        );

        emit(newState);
      } catch (error) {
        final newState = state.copyWith(
          // 4. On the other hand, if you get an error from the server, you change your
          // submissionStatus to SubmissionStatus.invalidCredentialsError if the
          // cause is missing their credentials or SubmissionStatus.genericError if the
          // cause is anything else — lack of internet connectivity, for example.
          submissionStatus: error is InvalidCredentialsException
              ? SubmissionStatus.invalidCredentialsError
              : SubmissionStatus.genericError,
        );

        emit(newState);
      }
    }
  }
}
