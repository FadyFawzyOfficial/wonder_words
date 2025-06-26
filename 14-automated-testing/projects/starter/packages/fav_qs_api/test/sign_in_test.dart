import 'package:dio/dio.dart';
import 'package:fav_qs_api/fav_qs_api.dart';
import 'package:fav_qs_api/src/fav_qs_api.dart';
import 'package:fav_qs_api/src/models/models.dart';
import 'package:fav_qs_api/src/url_builder.dart';
// Completed: add missing import
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:test/test.dart';

void main() {
  group('Test Sign In:', () {
    //* 1. Initializes an instance of the Dio object, which is required to preform
    //* HTTP requests.
    final dio = Dio(BaseOptions());

    // Completed: add dioAdapter which will stub the expected response of remote API
    //! This initializes the DioAdapter object, which will be used later to stub
    //! the behavior of successful response.
    final dioAdapter = DioAdapter(dio: dio);

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

    test(
        'When sign in call completes successfully, returns an instance of UserRM',
        () async {
      // Completed: add an implementation of request stubbing
      //! The implementation of this code is again quite intuitive. When performing
      //! the POST request using presanctified parameters, after a 1 second delay,
      //! dioAdapter will stub - imitate the successful response.
      //! Check the FavQs API `https://favqs.com/api` under the “Create session” section,
      //! and you may see that the response body of the stubbed response perfectly
      //! matches the response body of the API definition.
      //! The only thing left is to run the test.
      dioAdapter.onPost(
        url,
        (server) => server.reply(
          200,
          {
            'User-Token': 'token',
            'login': 'login',
            'email': 'email',
          },
          delay: const Duration(seconds: 1),
        ),
        data: requestJsonBody,
      );

      //! 4. Evaluates if the tested function returns the correct output.
      expect(await remoteApi.signIn(email, password), isA<UserRM>());
    });

    test(
        'When user enters wrong credentials, throws InvalidCredentialsFavQsException',
        () async {
      dioAdapter.onPost(
        url,
        (server) => server.reply(
          200,
          {
            'error_code': 21,
            'message': 'Invalid login or password.',
          },
          delay: const Duration(seconds: 1),
        ),
        data: requestJsonBody,
      );

      expect(() async => await remoteApi.signIn(email, password),
          throwsA(isA<InvalidCredentialsFavQsException>()));
    });
  });
}
