import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_fields/form_fields.dart';
import 'package:sign_in/src/l10n/sign_in_localizations.dart';
import 'package:sign_in/src/sign_in_cubit.dart';
import 'package:user_repository/user_repository.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({
    required this.userRepository,
    required this.onSignInSuccess,
    this.onForgotMyPasswordTap,
    this.onSignUpTap,
    Key? key,
  }) : super(key: key);

  final VoidCallback? onSignUpTap;
  final VoidCallback? onForgotMyPasswordTap;
  final VoidCallback onSignInSuccess;
  final UserRepository userRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SignInCubit>(
      create: (_) => SignInCubit(
        userRepository: userRepository,
      ),
      child: SignInView(
        onSignUpTap: onSignUpTap,
        onSignInSuccess: onSignInSuccess,
        onForgotMyPasswordTap: onForgotMyPasswordTap,
      ),
    );
  }
}

@visibleForTesting
class SignInView extends StatelessWidget {
  const SignInView({
    required this.onSignInSuccess,
    this.onSignUpTap,
    this.onForgotMyPasswordTap,
    Key? key,
  }) : super(key: key);

  final VoidCallback? onSignUpTap;
  final VoidCallback? onForgotMyPasswordTap;
  final VoidCallback onSignInSuccess;

  @override
  Widget build(BuildContext context) {
    final l10n = SignInLocalizations.of(context);
    return GestureDetector(
      onTap: () => _releaseFocus(context),
      child: Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          title: Text(
            l10n.appBarTitle,
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.mediumLarge,
            ),
            child: _SignInForm(
              onSignUpTap: onSignUpTap,
              onForgotMyPasswordTap: onForgotMyPasswordTap,
              onSignInSuccess: onSignInSuccess,
            ),
          ),
        ),
      ),
    );
  }

  void _releaseFocus(BuildContext context) => FocusScope.of(context).unfocus();
}

class _SignInForm extends StatefulWidget {
  const _SignInForm({
    required this.onSignInSuccess,
    this.onSignUpTap,
    this.onForgotMyPasswordTap,
    Key? key,
  }) : super(key: key);

  final VoidCallback? onSignUpTap;
  final VoidCallback? onForgotMyPasswordTap;
  final VoidCallback onSignInSuccess;

  @override
  State<_SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<_SignInForm> {
  // 1. You created two FocusNode s: One for the email field and one for the
  // password field. FocusNode s are objects you can attach to your TextField s
  // to listen to and control a field’s focus.
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // 2. This is how you get an instance of a Cubit to call functions on it.
    // This context.read() call only works because the topmost widget in this file has
    // a BlocProvider . Revisit the previous chapter if you need a refresher on all that.
    final cubit = context.read<SignInCubit>();
    _emailFocusNode.addListener(() {
      // 3. You then added listeners to your FocusNode s. These listeners run every
      // time the respective field gains or loses focus. Since you’re only interested in
      // knowing when the focus is lost, you added this if statement to distinguish
      // between the two events.
      if (!_emailFocusNode.hasFocus) {
        // 4. Within each listener’s code, you call the corresponding function you
        // just implemented in your Cubit.
        cubit.onEmailUnfocused();
      }
    });
    _passwordFocusNode.addListener(() {
      if (!_passwordFocusNode.hasFocus) {
        cubit.onPasswordUnfocused();
      }
    });
  }

  @override
  void dispose() {
    // 5. You have to dispose of FocusNode s.
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = SignInLocalizations.of(context);
    return BlocConsumer<SignInCubit, SignInState>(
      listenWhen: (oldState, newState) =>
          oldState.submissionStatus != newState.submissionStatus,
      listener: (context, state) {
        if (state.submissionStatus == SubmissionStatus.success) {
          // 1. If the submission is a success, you call the onSignInSuccess callback you
          // received in the screen’s constructor. Ultimately, that will lead to the main
          // app package closing this screen and getting back to whatever screen opened
          // it. The sign-in screen can open on a few different occasions, such as when a
          // signed-out user tries to favorite a quote.
          widget.onSignInSuccess();
          return;
        }

        final hasSubmissionError = state.submissionStatus ==
                SubmissionStatus.genericError ||
            state.submissionStatus == SubmissionStatus.invalidCredentialsError;

        // 2. Check if the current submissionStatus contains an error.
        if (hasSubmissionError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              // 3. If yes, display a different snackbar with a more descriptive message,
              //  depending on what that error is.
              state.submissionStatus == SubmissionStatus.invalidCredentialsError
                  ? SnackBar(content: Text(l10n.invalidCredentialsErrorMessage))
                  : const GenericErrorSnackBar(),
            );
        }
      },
      builder: (context, state) {
        final emailError = state.email.invalid ? state.email.error : null;
        final passwordError =
            state.password.invalid ? state.password.error : null;
        final isSubmissionInProgress =
            state.submissionStatus == SubmissionStatus.inProgress;

        final cubit = context.read<SignInCubit>();
        return Column(
          children: <Widget>[
            TextField(
              focusNode: _emailFocusNode,
              onChanged: cubit.onEmailChanged,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              decoration: InputDecoration(
                suffixIcon: const Icon(
                  Icons.alternate_email,
                ),
                enabled: !isSubmissionInProgress,
                labelText: l10n.emailTextFieldLabel,
                errorText: emailError == null
                    ? null
                    : (emailError == EmailValidationError.empty
                        ? l10n.emailTextFieldEmptyErrorMessage
                        : l10n.emailTextFieldInvalidErrorMessage),
              ),
            ),
            const SizedBox(
              height: Spacing.large,
            ),
            TextField(
              focusNode: _passwordFocusNode,
              onChanged: cubit.onPasswordChanged,
              obscureText: true,
              onEditingComplete: cubit.onSubmit,
              decoration: InputDecoration(
                suffixIcon: const Icon(
                  Icons.password,
                ),
                enabled: !isSubmissionInProgress,
                labelText: l10n.passwordTextFieldLabel,
                // 1. You’re using the errorText property of the TextField class
                // to display a validation error.
                errorText: passwordError == null
                    // 2. If passwordError is null , you set errorText to null , which
                    // will cause your field to display as valid. passwordError is
                    // the property you created in the last step.
                    ? null
                    // 3. Otherwise, if passwordError isn’t null , you return a different String
                    // depending on whether the error is PasswordValidationError.empty or
                    // PasswordValidationError.invalid.
                    : (passwordError == PasswordValidationError.empty
                        // 4. This l10n.whatever syntax is how you retrieve custom
                        // internationalized messages in WonderWords.
                        // You’ll learn all about this in Chapter 9, “Internationalizing & Localizing”.
                        ? l10n.passwordTextFieldEmptyErrorMessage
                        : l10n.passwordTextFieldInvalidErrorMessage),
              ),
            ),
            TextButton(
              child: Text(
                l10n.forgotMyPasswordButtonLabel,
              ),
              onPressed:
                  isSubmissionInProgress ? null : widget.onForgotMyPasswordTap,
            ),
            const SizedBox(
              height: Spacing.small,
            ),
            isSubmissionInProgress
                ? ExpandedElevatedButton.inProgress(
                    label: l10n.signInButtonLabel,
                  )
                : ExpandedElevatedButton(
                    onTap: cubit.onSubmit,
                    label: l10n.signInButtonLabel,
                    icon: const Icon(
                      Icons.login,
                    ),
                  ),
            const SizedBox(
              height: Spacing.xxLarge,
            ),
            Text(
              l10n.signUpOpeningText,
            ),
            TextButton(
              child: Text(
                l10n.signUpButtonLabel,
              ),
              onPressed: isSubmissionInProgress ? null : widget.onSignUpTap,
            ),
          ],
        );
      },
    );
  }
}
