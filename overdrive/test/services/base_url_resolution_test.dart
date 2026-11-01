import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/services/auth/auth_service.dart';

void main() {
  group('AuthService API base URL resolution', () {
    test('rewrites auth localhost to Android emulator host when running on Android', () {
      expect(
        AuthService.resolveAuthBaseUrlForPlatform(
          'http://localhost:3001',
          platform: TargetPlatform.android,
        ),
        'http://10.0.2.2:3001',
      );
    });

    test('keeps custom hosts unchanged for auth requests', () {
      expect(
        AuthService.resolveAuthBaseUrlForPlatform(
          'http://192.168.0.25:3001',
          platform: TargetPlatform.iOS,
        ),
        'http://192.168.0.25:3001',
      );
    });

    test('gateway URL still resolves to the gateway service', () {
      expect(
        AuthService.resolveApiBaseUrlForPlatform(
          'http://localhost:3000',
          platform: TargetPlatform.android,
        ),
        'http://10.0.2.2:3000',
      );
    });
  });
}
