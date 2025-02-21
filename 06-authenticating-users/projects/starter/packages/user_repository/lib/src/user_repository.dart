import 'package:domain_models/domain_models.dart';
import 'package:fav_qs_api/fav_qs_api.dart';
import 'package:key_value_storage/key_value_storage.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:user_repository/src/mappers/mappers.dart';
import 'package:user_repository/src/user_local_storage.dart';
import 'package:user_repository/src/user_secure_storage.dart';

class UserRepository {
  UserRepository({
    required KeyValueStorage noSqlStorage,
    required this.remoteApi,
    @visibleForTesting UserLocalStorage? localStorage,
    @visibleForTesting UserSecureStorage? secureStorage,
  })  : _localStorage = localStorage ??
            UserLocalStorage(
              noSqlStorage: noSqlStorage,
            ),
        _secureStorage = secureStorage ?? const UserSecureStorage();

  final FavQsApi remoteApi;
  final UserLocalStorage _localStorage;
  final UserSecureStorage _secureStorage;
  final BehaviorSubject<DarkModePreference> _darkModePreferenceSubject =
      BehaviorSubject();

  // Completed: Create a listenable property.
  //! BehaviorSubject is a class that:
  //!   1. Holds a value — from the type you specify within the angle brackets <> .
  //!   2. Provides a stream property that you can use to listen for any changes to
  //!   that value. When a piece of code starts listening to a BehaviorSubject ’s
  //!   stream , it immediately gets the latest value on that property — assuming
  //!   one has already been added — followed by all the subsequent changes to that value.
  final BehaviorSubject<User?> _userSubject = BehaviorSubject();

  Future<void> upsertDarkModePreference(DarkModePreference preference) async {
    await _localStorage.upsertDarkModePreference(
      preference.toCacheModel(),
    );
    _darkModePreferenceSubject.add(preference);
  }

  Stream<DarkModePreference> getDarkModePreference() async* {
    if (!_darkModePreferenceSubject.hasValue) {
      final storedPreference = await _localStorage.getDarkModePreference();
      _darkModePreferenceSubject.add(
        storedPreference?.toDomainModel() ??
            DarkModePreference.useSystemSettings,
      );
    }

    yield* _darkModePreferenceSubject.stream;
  }

  Future<void> signIn(String email, String password) async {
    // Completed: Sign in the user by coordinating the Data Sources.
    try {
      // 1. Called the “sign-in” endpoint on the server using the remoteApi property,
      // which is of type FavQsApi . If the request succeeds, you get a UserRM object
      // back from the server and assign it to the apiUser property. The UserRM
      // class holds the recently signed-in user’s token, email and username.
      final apiUser = await remoteApi.signIn(email, password);

      //! 2. Used the upsertUserInfo() function you just created in the UserSecureStorage class.
      await _secureStorage.upsertUserInfo(
          username: apiUser.username,
          email: apiUser.email,
          token: apiUser.token);

      // Completed: Propagate changes to the signed in user.
      //* 1. Use a mapper function, toDomainModel(), to convert the apiUser object
      //* from the UserRM type to the User type. UserRM is the type your network
      //* layer uses - fav_qs_api internal package - while User is the neutral model
      //* known by the rest of the codebase.
      final domainUser = apiUser.toDomainModel();

      //! 2. Replaced — or added, if this is the first sign-in — a new value to your BehaviorSubject .
      _userSubject.add(domainUser);
    } on InvalidCredentialsFavQsException catch (_) {
      //! 3. Captured any InvalidCredentialsFavQsException s and converted them to
      //! InvalidCredentialsException s. Doing so is important because
      //! InvalidCredentialsFavQsException is only known by packages importing
      //! the fav_qs_api internal package, which won’t be the case for users of this
      //! UserRepository class. InvalidCredentialsException, on the other hand,
      //! is part of the domain_models package and, therefore, is known to all
      //! features, making it possible for them to handle the exception properly.
      throw InvalidCredentialsException();
    }
  }

  Stream<User?> getUser() async* {
    // TODO: Expose the BehaviorSubject.
  }

  Future<String?> getUserToken() async {
    return null;

    // TODO: Provide the user token.
  }

  Future<void> signUp(
    String username,
    String email,
    String password,
  ) async {
    try {
      final userToken = await remoteApi.signUp(
        username,
        email,
        password,
      );

      await _secureStorage.upsertUserInfo(
        username: username,
        email: email,
        token: userToken,
      );

      _userSubject.add(
        User(
          username: username,
          email: email,
        ),
      );
    } catch (error) {
      if (error is UsernameAlreadyTakenFavQsException) {
        throw UsernameAlreadyTakenException();
      } else if (error is EmailAlreadyRegisteredFavQsException) {
        throw EmailAlreadyRegisteredException();
      }
      rethrow;
    }
  }

  Future<void> updateProfile(
    String username,
    String email,
    String? newPassword,
  ) async {
    try {
      await remoteApi.updateProfile(
        username,
        email,
        newPassword,
      );

      await _secureStorage.upsertUserInfo(
        username: username,
        email: email,
      );

      _userSubject.add(
        User(
          username: username,
          email: email,
        ),
      );
    } on UsernameAlreadyTakenFavQsException catch (_) {
      throw UsernameAlreadyTakenException();
    }
  }

  Future<void> signOut() async {
    await remoteApi.signOut();
    await _secureStorage.deleteUserInfo();
    _userSubject.add(null);
  }

  Future<void> requestPasswordResetEmail(String email) async {
    await remoteApi.requestPasswordResetEmail(email);
  }
}
