// 1. Added an import to the Formz package, which is already listed as a
// dependency in this package’s pubspec.yaml. Formz helps you create classes
// to represent your fields’ states in a way that’s generic enough for you to
// reuse them for different screens. Although Formz isn’t part of the bloc
// library, both are from the same creator and work exceptionally well together.
import 'package:formz/formz.dart';

enum PasswordValidationError {
  empty,
  invalid,
}

// 2. This is how you create a class to encapsulate both the state and the validation
// rules of a form field in Formz. You just had to declare a class and extend
// FormzInput from it. You’ll use Password for all password fields in
// WonderWords.
class Password extends FormzInput<String, PasswordValidationError> {
  const Password.unvalidated([String value = '']) : super.pure(value);
  const Password.validated([String value = '']) : super.dirty(value);

  @override
  PasswordValidationError? validator(String value) {
    if (value.isEmpty) {
      return PasswordValidationError.empty;
    } else if (value.length < 5 || value.length > 120) {
      return PasswordValidationError.invalid;
    } else {
      return null;
    }
  }
}
