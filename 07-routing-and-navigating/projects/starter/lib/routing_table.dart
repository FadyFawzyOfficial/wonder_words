import 'package:domain_models/domain_models.dart';
import 'package:flutter/material.dart';
import 'package:forgot_my_password/forgot_my_password.dart';
import 'package:monitoring/monitoring.dart';
import 'package:profile_menu/profile_menu.dart';
import 'package:quote_details/quote_details.dart';
import 'package:quote_list/quote_list.dart';
import 'package:quote_repository/quote_repository.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sign_in/sign_in.dart';
import 'package:sign_up/sign_up.dart';
import 'package:update_profile/update_profile.dart';
import 'package:user_repository/user_repository.dart';
import 'package:wonder_words/tab_container_screen.dart';

// TODO: Create the app's routing table.

// Completed: Define the app's paths.
class _PathConstants {
  const _PathConstants._();

  static const String tabContainerPath = '/';

  static const String quoteListPath = '${tabContainerPath}quotes';

  static String get profileMenuPath => '${tabContainerPath}user';

  static String get updateProfilePath => '$profileMenuPath/updateprofile';

  static String get signInPath => '${tabContainerPath}sign-in';

  static String get signUpPath => '${tabContainerPath}sign-up';

  static String get idPathParameter => 'id';

  static String quoteDetailsPath({int? quoteId}) =>
      '$quoteListPath/${quoteId ?? ': $idPathParameter'}';
}
