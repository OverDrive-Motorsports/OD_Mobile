import 'package:flutter_test/flutter_test.dart';
import 'package:overdrive/services/auth/auth_service.dart';

void main() {
  group('AuthService token parsing', () {
    test('accepts both token and accessToken response shapes', () {
      final tokensFromLegacy = AuthService.parseSessionPayload({
        'token': 'legacy-token',
        'refreshToken': 'legacy-refresh',
        'sessionId': 'legacy-session',
      });

      final tokensFromModern = AuthService.parseSessionPayload({
        'accessToken': 'modern-token',
        'refreshToken': 'modern-refresh',
        'sessionId': 'modern-session',
        'expiresAt': '2026-10-16T12:00:00Z',
      });

      expect(tokensFromLegacy, isNotNull);
      expect(tokensFromLegacy!.accessToken, 'legacy-token');
      expect(tokensFromLegacy.refreshToken, 'legacy-refresh');
      expect(tokensFromLegacy.sessionId, 'legacy-session');

      expect(tokensFromModern, isNotNull);
      expect(tokensFromModern!.accessToken, 'modern-token');
      expect(tokensFromModern.refreshToken, 'modern-refresh');
      expect(tokensFromModern.sessionId, 'modern-session');
    });
  });
}
