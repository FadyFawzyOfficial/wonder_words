// Completed: add missing imports

import 'package:domain_models/domain_models.dart';
import 'package:key_value_storage/key_value_storage.dart';
import 'package:test/test.dart';
import 'package:user_repository/src/mappers/mappers.dart';

void main() {
  // Completed: add unit test for DarkModePreferenceCM to domain mapper

  //* 1. This is the top-level function that will execute when you run the test.
  //* As the first required parameter, it takes the description of the test,
  //* and the second required attribute takes an implementation of the test.
  test(
      'When mapping DarkModePreferenceCM.alwaysDart to domain, return DarkModePreference.alwaysDark',
      () {
    //! 2. Here, you store the instance of DarkModePreferenceCM in a variable.
    final preference = DarkModePreferenceCM.alwaysDark;

    //! 3. Here, you compare the output of the testing mapper with your expected result.
    expect(
      preference.toDomainModel(),
      DarkModePreference.alwaysDark,
    );
  });

  // Challenge
}
