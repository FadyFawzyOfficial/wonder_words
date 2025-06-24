// Completed: add missing imports and a mock class for UserRepository
import 'package:bloc_test/bloc_test.dart';
import 'package:form_fields/form_fields.dart';
import 'package:mockito/mockito.dart';
import 'package:sign_in/src/sign_in_cubit.dart';
import 'package:user_repository/user_repository.dart';

//! This creates a mock for UserRepository.
class MockUserRepository extends Mock implements UserRepository {}

void main() {
  // Completed: add an implementation of BloC test
  blocTest<SignInCubit, SignInState>(
    'Emits SignInState with unvalidated email when email is changed for the first time',
    //* 1. initialize the SignInCubit object.
    build: () => SignInCubit(userRepository: MockUserRepository()),
    //! 2. Act on the cubit. This is what happens when the user enters the email
    //! address in the text field.
    act: (cubit) => cubit.onEmailChanged('email@gmail.com'),
    //! 3. Evaluate the new state and compare it with your expected result.
    expect: () => <SignInState>[
      const SignInState(email: Email.unvalidated('email@gmail.com'))
    ],
  );
}
