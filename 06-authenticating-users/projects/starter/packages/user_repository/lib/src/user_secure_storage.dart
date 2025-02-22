import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Completed: Create a secure Data Source.

// 1. If you recall from Chapter 2, “Mastering the Repository Pattern”, data
// sources are classes your repositories use to interact with external sources,
// like databases and the network. This UserSecureStorage class you’re
// creating here will act as one of the data sources of your UserRepository
// class. Its role is to expose UserRepository to functions that help maintain
// the authenticated user’s information.
class UserSecureStorage {
  static const _tokenKey = 'wonder-words-token';
  static const _usernameKey = 'wonder-words-username';
  static const _emailKey = 'wonder-words-email';

  final FlutterSecureStorage _secureStorage;

  const UserSecureStorage({
    //* 2. The FlutterSecureStorage class comes from this flutter_secure_storage
    //* package you were reading about. Look at the functions’ implementation in
    //* this file to see how easy it is to work with the package.
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  //! 3. If you haven’t seen this word before, upsert is a common neologism in
  //! software development that combines update and insert. In other words, it
  //! stands for: Update the registry if one already exists or insert if it doesn’t.
  Future<void> upsertUserInfo({
    required String username,
    required String email,
    String? token,
  }) =>
      //* 4. This Future.wait function combines multiple Future s into one, allowing
      //* you to execute them simultaneously.
      //! This is useful when the Future calls aren’t dependent on each other,
      //! that is, when you don’t have to wait for one Future to complete to execute the next.
      Future.wait([
        _secureStorage.write(key: _emailKey, value: email),
        _secureStorage.write(key: _usernameKey, value: username),
        if (token != null) _secureStorage.write(key: _tokenKey, value: token)
      ]);

  Future<void> deleteUserInfo() => Future.wait([
        _secureStorage.delete(key: _tokenKey),
        _secureStorage.delete(key: _usernameKey),
        _secureStorage.delete(key: _emailKey)
      ]);

  Future<String?> getUserToken() => _secureStorage.read(key: _tokenKey);

  Future<String?> getUserEmail() => _secureStorage.read(key: _emailKey);

  Future<String?> getUsername() => _secureStorage.read(key: _usernameKey);
}
