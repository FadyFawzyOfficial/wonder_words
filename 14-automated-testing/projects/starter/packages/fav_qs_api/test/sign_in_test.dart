import 'package:dio/dio.dart';
import 'package:fav_qs_api/src/fav_qs_api.dart';
import 'package:fav_qs_api/src/models/models.dart';
import 'package:fav_qs_api/src/url_builder.dart';
// TODO: add missing import
import 'package:test/test.dart';

void main() {
  test(
      'When sign in call completes successfully, returns an instance of UserRM',
      () async {
    //* 1. Initializes an instance of the Dio object, which is required to preform
    //* HTTP requests.
    final dio = Dio(BaseOptions());

    // TODO: add dioAdapter which will stub the expected response of remote API

    //* 2. Initialize the remote API and provides the required testing attributes.
    final remoteApi =
        FavQsApi(userTokenSupplier: () => Future.value(), dio: dio);

    //* 3. Initializes all the required variables, which are used when performing
    //* the sign-in request.
    const email = 'email';
    const password = 'password';

    final url = const UrlBuilder().buildSignInUrl();

    final requestJsonBody = const SignInRequestRM(
      credentials: UserCredentialsRM(
        email: email,
        password: password,
      ),
    ).toJson();

    // TODO: add an implementation of request stubbing

    //! 4. Evaluates if the tested function returns the correct output.
    expect(await remoteApi.signIn(email, password), isA<UserRM>());
  });
}
