import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:gherkin/gherkin.dart';

StepDefinitionGeneric LoginPage() {

  return given<FlutterWorld> (
    'I am on the login page',
        (context) async {
      final locator = find.byValueKey('loginpage');
      await FlutterDriverUtils.isPresent(context.world.driver, locator);
    },
  );
}

StepDefinitionGeneric MainPage() {

  return given<FlutterWorld> (
    'I am on the main page',
        (context) async {
      final locator = find.byValueKey('main_page');
      await FlutterDriverUtils.isPresent(context.world.driver, locator);
    },
  );
}

StepDefinitionGeneric ProfilePage() {
  return given<FlutterWorld> (
    'I am on the profile page',
    (context) async {
    final locator = find.byValueKey('profile_page');
    await FlutterDriverUtils.isPresent(context.world.driver, locator);
  },
);
}

StepDefinitionGeneric MapScreen() {
  return given<FlutterWorld>(
    'I am on the map screen',
        (context) async {
        final locator = find.byValueKey('map_screen');
        await FlutterDriverUtils.isPresent(context.world.driver, locator);
    },
  );
}

StepDefinitionGeneric SearchScreen() {
  return given<FlutterWorld>(
    'I am on the search screen',
        (context) async {
      final locator = find.byValueKey('search_screen');
      await FlutterDriverUtils.isPresent(context.world.driver, locator);
    },
  );
}

class GivenIAmLoggedIn extends AndWithWorld<FlutterWorld> {
  GivenIAmLoggedIn() : super(StepDefinitionConfiguration());

  @override
  Future<void> executeStep() async {
    final loginPageLocator = find.byValueKey('loginpage');
    await FlutterDriverUtils.isPresent(world.driver, loginPageLocator);

    // Fill the "email" field with "teste123456@gmail.com"
    final emailFieldFinder = find.byValueKey('email');
    await world.driver!.scrollIntoView(emailFieldFinder);
    await FlutterDriverUtils.enterText(
      world.driver!,
      emailFieldFinder,
      'teste123456@gmail.com',
    );

    // Fill the "password" field with "teste123"
    final passwordFieldFinder = find.byValueKey('password');
    await world.driver!.scrollIntoView(passwordFieldFinder);
    await FlutterDriverUtils.enterText(
      world.driver!,
      passwordFieldFinder,
      'teste123',
    );

    // Tap the "login" button
    final loginButtonFinder = find.byValueKey('login');
    await world.driver!.scrollIntoView(loginButtonFinder);
    await FlutterDriverUtils.tap(world.driver, loginButtonFinder);
  }

  @override
  RegExp get pattern => RegExp(r'I am logged in');
}


