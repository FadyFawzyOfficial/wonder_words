import 'package:flutter_test/flutter_test.dart';

//! 1. This is the entry point of your test program. Your code for preforming
//! tests will live inside the `main()` function.
void main() {
  //! 2. With a group. you can join multiple tests together. It takes 2 required
  //! parameters: description, which will be included in descriptions of the tests
  //! inside the group, and function parameters, inside which you'll define your tests.
  group('Group description', () {
    //! 3. setUp() is used as a part of code, which will always run before the tests.
    setUp(() {});

    //! 4. This is a top-level test function in which you'll write an
    //! implementation of a specific test.
    test('Test 1 description', () {
      //! 5. This function compares your test result with your expected value
      //! and checks if the test was successful.
      expect(1, 1);
    });
    test('Test 2 description', () {
      expect(1, 1);
    });
    //! 6. tearDown() works very similarly to the setUp() function, but this
    //! function executes code after tests.
    tearDown(() {});
  });

  //! 7. This is the same function as test() after comment // 4 but is outside
  //! the group, which shoes that test() can run outside the group
  test('Test 3 description', () {
    expect(1, 1);
  });
}
