import 'dart:async';

import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:gherkin/gherkin.dart';
import 'package:glob/glob.dart';

import 'steps/screens_step.dart';
import 'steps/tap_button_n_times_step.dart';
import 'steps/waiting_step.dart';

Future<void> main() {
  var config = FlutterTestConfiguration()
    ..features = [
      Glob(r"test_driver/features/login.feature"),
      Glob(r"test_driver/features/register_screen.feature"),
      Glob(r"test_driver/features/forgot_password_screen.feature"),
      Glob(r"test_driver/features/search_screen.feature"),
      Glob(r"test_driver/features/anonymous_signin.feature"),
      Glob(r"test_driver/features/check_filters.feature")
      ]
    ..reporters = [
      ProgressReporter(),
      TestRunSummaryReporter(),
      JsonReporter(path: './report.json')
    ] // you can include the "StdoutReporter()" without the message level parameter for verbose log information
    ..hooks = []
    ..stepDefinitions = [TapButtonNTimesStep(), LoginPage(), waiting(),
      MainPage(), ProfilePage(), MapScreen(), GivenIAmLoggedIn(), GivenIAmLoggedIn(),
      SearchScreen()]
    ..customStepParameterDefinitions = []
    ..restartAppBetweenScenarios = true
    ..targetAppPath = "test_driver/app.dart";
  // ..tagExpression = "@smoke" // uncomment to see an example of running scenarios based on tag expressions
  return GherkinRunner().execute(config);
}