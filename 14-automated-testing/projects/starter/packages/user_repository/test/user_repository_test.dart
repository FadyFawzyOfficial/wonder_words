// TODO: add missing packages and an annotation to generate the mock
import 'package:test/test.dart';

void main() {
  // Completed: add an implementation for UserRepository.getUserToken() test
  test(
    'When calling getUserToken after successful authentication, return authentication token',
    () async {
      // ToDo: add initialization of _userRepository

      expect(await _userRepository.getUserToken(), 'token');
    },
  );

  // Challenge
}
