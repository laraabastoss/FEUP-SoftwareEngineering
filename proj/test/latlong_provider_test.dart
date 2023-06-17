import 'package:brain_box/providers/latlong_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:location/location.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'latlong_provider_test.mocks.dart';

@GenerateNiceMocks([MockSpec<Location>()])
void main() {
  group('LatLong provider', () {
    late MockLocation _mockLocation;

    setUp(() {
      _mockLocation = MockLocation();
      when(_mockLocation.getLocation()).thenAnswer((realInvocation) =>
          Future.value(
              LocationData.fromMap({'latitude': 42.0, 'longitude': -9.0})));
    });

    test('Has all permissions', () async {
      when(_mockLocation.serviceEnabled()).thenAnswer((realInvocation) => Future.value(true));
      when(_mockLocation.hasPermission()).thenAnswer((realInvocation) => Future.value(PermissionStatus.granted));

      await LatLongProvider.getLocation(_mockLocation);

      verifyInOrder([
        _mockLocation.serviceEnabled(),
        _mockLocation.hasPermission(),
        _mockLocation.getLocation()
      ]);
    });

    test('Asks for service', () async {
      when(_mockLocation.serviceEnabled()).thenAnswer((realInvocation) => Future.value(false));
      when(_mockLocation.requestService()).thenAnswer((realInvocation) => Future.value(true));
      when(_mockLocation.hasPermission()).thenAnswer((realInvocation) => Future.value(PermissionStatus.granted));

      await LatLongProvider.getLocation(_mockLocation);

      verifyInOrder([
        _mockLocation.serviceEnabled(),
        _mockLocation.requestService(),
        _mockLocation.hasPermission(),
        _mockLocation.getLocation()
      ]);
    });

    test('Asks for service and permission', () async {
      when(_mockLocation.serviceEnabled()).thenAnswer((realInvocation) => Future.value(false));
      when(_mockLocation.requestService()).thenAnswer((realInvocation) => Future.value(true));
      when(_mockLocation.hasPermission()).thenAnswer((realInvocation) => Future.value(PermissionStatus.denied));
      when(_mockLocation.requestPermission()).thenAnswer((realInvocation) => Future.value(PermissionStatus.granted));

      await LatLongProvider.getLocation(_mockLocation);

      verifyInOrder([
        _mockLocation.serviceEnabled(),
        _mockLocation.requestService(),
        _mockLocation.hasPermission(),
        _mockLocation.requestPermission(),
        _mockLocation.getLocation()
      ]);
    });

    test('Gets no service', () async {
      when(_mockLocation.serviceEnabled()).thenAnswer((realInvocation) => Future.value(false));
      when(_mockLocation.requestService()).thenAnswer((realInvocation) => Future.value(false));

      LocationData? ret = await LatLongProvider.getLocation(_mockLocation);

      verifyInOrder([
        _mockLocation.serviceEnabled(),
        _mockLocation.requestService(),
      ]);

      expect(ret?.latitude, 41.0);
      expect(ret?.longitude, -8.0);
    });

    test('Gets no permission', () async {
      when(_mockLocation.serviceEnabled()).thenAnswer((realInvocation) => Future.value(true));
      when(_mockLocation.hasPermission()).thenAnswer((realInvocation) => Future.value(PermissionStatus.denied));
      when(_mockLocation.requestPermission()).thenAnswer((realInvocation) => Future.value(PermissionStatus.denied));

      LocationData? ret = await LatLongProvider.getLocation(_mockLocation);

      verifyInOrder([
        _mockLocation.serviceEnabled(),
        _mockLocation.hasPermission(),
        _mockLocation.requestPermission()
      ]);

      expect(ret?.latitude, 41.0);
      expect(ret?.longitude, -8.0);
    });
  });
}
