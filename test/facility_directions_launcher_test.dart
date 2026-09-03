import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wellnessconnect/services/facility_directions_launcher.dart';

void main() {
  test('opens a valid directions URL externally first', () async {
    final attempts = <LaunchMode>[];
    final launcher = FacilityDirectionsLauncher(
      launch: (_, {required mode}) async {
        attempts.add(mode);
        return true;
      },
    );

    final result = await launcher.open(
      'https://www.google.com/maps/dir/?api=1&destination=12.9716%2C77.6412',
    );

    expect(result, DirectionsLaunchResult.openedExternally);
    expect(attempts, [LaunchMode.externalApplication]);
  });

  test(
    'falls back to an in-app browser when external Maps is declined',
    () async {
      final attempts = <LaunchMode>[];
      final launcher = FacilityDirectionsLauncher(
        launch: (_, {required mode}) async {
          attempts.add(mode);
          return mode == LaunchMode.inAppBrowserView;
        },
      );

      final result = await launcher.open(
        'https://www.google.com/maps/dir/?api=1&destination=Indiranagar',
      );

      expect(result, DirectionsLaunchResult.openedInAppBrowser);
      expect(attempts, [
        LaunchMode.externalApplication,
        LaunchMode.inAppBrowserView,
      ]);
    },
  );

  test(
    'uses the browser fallback after an external-launch exception',
    () async {
      final attempts = <LaunchMode>[];
      final launcher = FacilityDirectionsLauncher(
        launch: (_, {required mode}) async {
          attempts.add(mode);
          if (mode == LaunchMode.externalApplication) {
            throw StateError('No external handler');
          }
          return true;
        },
      );

      final result = await launcher.open(
        'https://www.google.com/maps/dir/?api=1&destination=Mumbai',
      );

      expect(result, DirectionsLaunchResult.openedInAppBrowser);
      expect(attempts, [
        LaunchMode.externalApplication,
        LaunchMode.inAppBrowserView,
      ]);
    },
  );

  test('does not try to launch a missing or non-HTTPS URL', () async {
    var attempts = 0;
    final launcher = FacilityDirectionsLauncher(
      launch: (_, {required mode}) async {
        attempts++;
        return true;
      },
    );

    expect(await launcher.open(null), DirectionsLaunchResult.unavailable);
    expect(
      await launcher.open('comgooglemaps://?daddr=Indiranagar'),
      DirectionsLaunchResult.unavailable,
    );
    expect(attempts, 0);
  });
}
