// Completed: add missing packages and an annotation to generate the mock
import 'package:fav_qs_api/fav_qs_api.dart';
import 'package:key_value_storage/key_value_storage.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:user_repository/src/user_secure_storage.dart';
import 'package:user_repository/user_repository.dart';

import 'user_repository_test.mocks.dart';

//! You can generate a mock class for UserSecureStorage with this following annotation.
@GenerateMocks([UserSecureStorage])
void main() {
  // Completed: add an implementation for UserRepository.getUserToken() test
  test(
    'When calling getUserToken after successful authentication, return authentication token',
    () async {
      // Completed: add initialization of _userSecureStorage
      final _userSecureStorage = MockUserSecureStorage();

      // Completed: add initialization of _userRepository
      //* UserRepository's constructor requires two parameters — noSqlStorage and remoteApi.
      //! These don’t play any role when executing getUserToken(). But if you go
      //! to the implementation of this class, you’ll see that you can also provide
      //! the secureStorage attribute when testing this repository. This one, on the
      //! other hand, plays a huge role when executing getUserToken().
      //* As mentioned before, it’s crucial when performing unit tests to prevent
      //* any unexpected behavior of other units with which the testing component interacts.
      //! To take control over the behavior of this object, you’ll make a mock for UserSecureStorage.
      final _userRepository = UserRepository(
        secureStorage: _userSecureStorage,
        noSqlStorage: KeyValueStorage(),
        remoteApi: FavQsApi(userTokenSupplier: () => Future.value()),
      );

      // Completed: add stubbing for fetching token from secure storage
      //! This function is quite intuitive. When you call getUserToken() inside
      //! your mock object, it returns the token you hardcoded to token.
      //* Run the test again, and it'll work like a charm.
      when(_userSecureStorage.getUserToken()).thenAnswer((_) async => 'token');
      //! Note: _userRepository.getUserToken() calls its secureStorage.getUserToken()
      //! and as _userSecureStorage is a mock object, I have to stub this behavior
      //! and return the token as hard coded, and that what I did in above snippet.

      expect(await _userRepository.getUserToken(), 'token');
    },
  );

  // Challenge
  //! Write a unit test for UserRepository ‘s getUserToken() function — for instance,
  //! when the user isn’t authenticated yet.
  test(
    'When calling getUserToken before successful authentication, return authentication as empty String',
    () async {
      final _userRepository = UserRepository(
        noSqlStorage: KeyValueStorage(),
        remoteApi: FavQsApi(userTokenSupplier: () => Future.value()),
      );

      expect(await _userRepository.getUserToken(), '');
    },
  );
}
