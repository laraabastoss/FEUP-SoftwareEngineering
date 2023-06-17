import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:gherkin/gherkin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:gherkin/gherkin.dart';

StepDefinitionGeneric GivenIamOnTheMapScreen() {
  return given<FlutterWorld>(
    'I am on the map screen',
        (context) async {
      await FlutterDriverUtils.tap(context.world.driver, find.byValueKey('map_icon'));
    },
  );
}

