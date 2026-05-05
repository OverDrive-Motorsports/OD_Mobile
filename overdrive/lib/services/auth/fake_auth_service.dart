/*
##
## OverDrive 2026
## All Technical rights reserved
##
## fake_auth_service.dart - In-memory authentication used while backend auth is unavailable.
##
*/

class FakeAuthService {
  FakeAuthService._();

  static final FakeAuthService instance = FakeAuthService._();

  static const String demoEmail = 'test@test.com';
  static const String demoPassword = '1234567890';

  final Map<String, _LocalUser> _users = <String, _LocalUser>{
    demoEmail: const _LocalUser(
      fullName: 'Pilote de test',
      email: demoEmail,
      password: demoPassword,
    ),
  };

  String? _currentUserEmail;

  String? get currentUserEmail => _currentUserEmail;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 550));

    final normalizedEmail = _normalizeEmail(email);
    final user = _users[normalizedEmail];

    if (user == null || user.password != password) {
      return const AuthResponse.failure(
        'Invalid credentials. Check your email and password.',
      );
    }

    _currentUserEmail = normalizedEmail;
    return AuthResponse.success(email: normalizedEmail);
  }

  Future<AuthResponse> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));

    final normalizedEmail = _normalizeEmail(email);

    if (_users.containsKey(normalizedEmail)) {
      return const AuthResponse.failure(
        'An account already exists with this email address.',
      );
    }

    _users[normalizedEmail] = _LocalUser(
      fullName: fullName.trim(),
      email: normalizedEmail,
      password: password,
    );

    return AuthResponse.success(email: normalizedEmail);
  }

  void signOut() {
    _currentUserEmail = null;
  }

  String _normalizeEmail(String value) => value.trim().toLowerCase();
}

class AuthResponse {
  const AuthResponse._({required this.isSuccess, this.email, this.message});

  const AuthResponse.success({required String email})
    : this._(isSuccess: true, email: email);

  const AuthResponse.failure(String message)
    : this._(isSuccess: false, message: message);

  final bool isSuccess;
  final String? email;
  final String? message;
}

class _LocalUser {
  const _LocalUser({
    required this.fullName,
    required this.email,
    required this.password,
  });

  final String fullName;
  final String email;
  final String password;
}
