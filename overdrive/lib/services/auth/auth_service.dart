/**
##
## OverDrive 2026
## All Technical rights reserved
##
## auth_service.dart - Authentication service and secure session storage.
##
*/

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stores authentication credentials received from backend.
/// Needed to keep user session active and manage token expiration.
class AuthTokens {
  AuthTokens({
    required this.accessToken,
    required this.sessionId,
    required this.refreshToken,
    this.expiresAt,
  });

  final String accessToken;
  final String sessionId;
  final String refreshToken;
  final DateTime? expiresAt;

  bool get isExpired {
    if (expiresAt == null) {
      return false;
    }

    return DateTime.now().isAfter(expiresAt!);
  }
}

/// Custom authentication exception.
/// Needed to provide user-friendly errors instead of raw network errors.
class AuthServiceException implements Exception {
  const AuthServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Main authentication manager.
/// Handles login, registration, token storage, session validation and logout.
class AuthService extends ChangeNotifier {
  AuthService._privateConstructor()
    : _storage = const FlutterSecureStorage(),
      _baseUrl = _resolveBaseUrl(null),
      _dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 60),
          validateStatus: (status) => status != null && status < 500,
        ),
      ) {
    if (_isValidUrl(_baseUrl)) {
      _dio.options.baseUrl = _baseUrl;
    }
  }

  static final AuthService instance = AuthService._privateConstructor();

  /// Secure storage keys.
  /// Needed to persist authentication data between application launches.
  static const _tokenKey = "od_access_token";
  static const _sessionIdKey = "od_session_id";
  static const _refreshTokenKey = "od_refresh_token";
  static const _expiresAtKey = "od_expires_at";

  final Dio _dio;
  final FlutterSecureStorage _storage;
  final String _baseUrl;

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  /// Restores previous user session when application starts.
  /// Needed to keep the user logged in after restarting the app.
  Future<void> initialize() async {
    _isAuthenticated = await hasValidSession();
    notifyListeners();
  }

  /// Authenticates user credentials and creates a session.
  /// Needed to obtain JWT and refresh token for protected API requests.
  Future<AuthTokens> login(String email, String password) async {
    final tokens = await _authenticate("/login", {
      "email": email.trim(),
      "password": password.trim(),
    });
    _isAuthenticated = true;
    notifyListeners();

    return tokens;
  }

  /// Registers a new user account.
  /// Needed to create user identity before authentication.
  Future<void> signup(String email, String password, String username) async {
    try {
      final response = await _dio.post(
        "/register",
        data: {
          "email": email.trim(),
          "password": password.trim(),
          "username": username.trim(),
        },
      );

      if (response.statusCode == null || response.statusCode! >= 400) {
        throw AuthServiceException(_extractError(response.data));
      }

      debugPrint("Registration successful");
    } on DioException catch (e) {
      throw AuthServiceException(_resolveError(e));
    }
  }

  /// Executes authentication request and saves returned session tokens.
  /// Needed to centralize token validation, parsing and secure storage for login flows.
  Future<AuthTokens> _authenticate(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.post(path, data: body);

      debugPrint("AUTH STATUS: ${response.statusCode}");

      // Validate backend response before processing authentication data.
      // Needed to prevent invalid responses from creating broken sessions.
      if (response.statusCode == null || response.statusCode! >= 400) {
        throw AuthServiceException(_extractError(response.data));
      }

      final data = response.data as Map<String, dynamic>;

      final token = data["token"];
      final refreshToken = data["refreshToken"];
      final sessionId = data["sessionId"];

      // Ensure all required session credentials are provided by backend.
      // Needed because missing tokens make future authenticated requests impossible.
      if (token == null) {
        throw const AuthServiceException("JWT token missing");
      }

      if (refreshToken == null) {
        throw const AuthServiceException("Refresh token missing");
      }

      if (sessionId == null) {
        throw const AuthServiceException("Session ID missing");
      }

      final expires = data["expiresAt"];

      // Converts backend response into application authentication model.
      // Needed to keep token management independent from API response format.
      final tokens = AuthTokens(
        accessToken: token,
        sessionId: sessionId,
        refreshToken: refreshToken,
        expiresAt: expires != null ? DateTime.tryParse(expires) : null,
      );

      // Persist credentials securely on device.
      // Needed to restore user session after application restart.
      await _saveToken(tokens);

      return tokens;
    } on DioException catch (e) {
      throw AuthServiceException(_resolveError(e));
    }
  }

  /// Saves authentication credentials securely on device.
  /// Needed to restore user session after application restart.
  Future<void> _saveToken(AuthTokens tokens) async {
    await _storage.write(key: _tokenKey, value: tokens.accessToken);

    await _storage.write(key: _sessionIdKey, value: tokens.sessionId);

    await _storage.write(key: _refreshTokenKey, value: tokens.refreshToken);

    await _storage.write(
      key: _expiresAtKey,
      value: tokens.expiresAt?.toIso8601String(),
    );
  }

  /// Retrieves stored JWT access token.
  /// Needed to authenticate protected API requests.
  Future<String?> get accessToken async {
    return await _storage.read(key: _tokenKey);
  }

  /// Retrieves stored session identifier.
  /// Needed to validate and refresh the current user session.
  Future<String?> get sessionId async {
    return await _storage.read(key: _sessionIdKey);
  }

  /// Retrieves stored refresh token.
  /// Needed to generate a new access token after expiration.
  Future<String?> get refreshToken async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Refreshes expired authentication tokens using stored session credentials.
  /// Needed to keep the user session active without requiring a new login.
  Future<AuthTokens> refreshTokens() async {
    final refresh = await refreshToken;

    // Validate refresh token availability before contacting backend.
    // Needed because token refresh is impossible without existing session credentials.
    if (refresh == null) {
      throw const AuthServiceException("No refresh token");
    }

    final session = await sessionId;

    // Validate session identifier before refresh request.
    // Needed to correctly identify the active user session.
    if (session == null) {
      throw const AuthServiceException("No session id");
    }

    final response = await _dio.post(
      "/refresh",
      data: {"sessionId": session, "refreshToken": refresh},
    );

    debugPrint("REFRESH STATUS: ${response.statusCode}");

    // Validate backend refresh response.
    // Needed to prevent storing invalid authentication data.
    if (response.statusCode == null || response.statusCode! >= 400) {
      throw AuthServiceException(_extractError(response.data));
    }

    final data = response.data as Map<String, dynamic>;

    final token = data["token"];
    final newRefreshToken = data["refreshToken"];

    // Ensure backend returned new valid credentials.
    // Needed to avoid replacing working session with incomplete data.
    if (token == null || newRefreshToken == null) {
      throw const AuthServiceException("Invalid refresh response");
    }

    // Creates updated authentication model with refreshed credentials.
    // Needed to update stored session information.
    final tokens = AuthTokens(
      accessToken: token,
      sessionId: session,
      refreshToken: newRefreshToken,
      expiresAt: data["expiresAt"] != null
          ? DateTime.tryParse(data["expiresAt"])
          : null,
    );

    // Stores refreshed tokens securely for future authenticated requests.
    // Needed to persist the renewed session after application restart.
    await _saveToken(tokens);

    return tokens;
  }

  /// Checks whether the current authentication session is still valid.
  /// Needed to restore user authentication state and refresh expired sessions on app startup.
  Future<bool> hasValidSession() async {
    final token = await accessToken;

    // Verify that stored credentials exist before validating expiration.
    // Needed to avoid treating empty storage as an active session.
    if (token == null || token.isEmpty) {
      _isAuthenticated = false;
      notifyListeners();
      return false;
    }

    final expires = await _storage.read(key: _expiresAtKey);

    // Accept session when expiration information is unavailable.
    // Needed to support backend responses without expiration metadata.
    if (expires == null) {
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }

    final expiration = DateTime.tryParse(expires);

    // Accept session when expiration format is invalid.
    // Needed to avoid forcing logout due to corrupted metadata.
    if (expiration == null) {
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }

    // Check if current access token is still usable.
    // Needed to avoid unnecessary refresh requests.
    if (DateTime.now().isBefore(expiration)) {
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }

    // Try recovering expired session with refresh token.
    // Needed to keep users logged in after access token expiration.
    try {
      await refreshTokens();

      _isAuthenticated = true;
      notifyListeners();

      return true;
    } catch (_) {
      await logout();

      _isAuthenticated = false;
      notifyListeners();

      return false;
    }
  }

  /// Removes all stored authentication credentials and resets user state.
  /// Needed to securely terminate the current user session.
  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);

    await _storage.delete(key: _sessionIdKey);

    await _storage.delete(key: _refreshTokenKey);

    await _storage.delete(key: _expiresAtKey);

    _isAuthenticated = false;

    notifyListeners();
  }

  /// Extracts readable error message from backend response.
  /// Needed to display meaningful authentication errors to the user.
  String _extractError(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data["error"] ?? data["message"] ?? "Authentication failed";
    }

    return "Authentication failed";
  }

  /// Converts network exceptions into application-level errors.
  /// Needed to hide HTTP client details from authentication screens.
  String _resolveError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      return "Backend timeout";
    }

    return e.message ?? "Network error";
  }

  /// Resolves backend URL from configuration and platform defaults.
  /// Needed to connect application with correct API environment.
  static String _resolveBaseUrl(String? value) {
    if (value != null && _isValidUrl(value)) {
      return value;
    }

    final env = dotenv.isInitialized ? dotenv.env["API_BASE_URL"] : null;

    if (env != null && _isValidUrl(env)) {
      return env;
    }

    // Android emulator requires special localhost mapping.
    // Needed because emulator localhost points to the virtual device itself.
    if (kIsWeb) {
      return "http://localhost:3001";
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return "http://10.0.2.2:3001";
    }

    return "http://localhost:3001";
  }

  /// Validates whether provided string is a usable URL.
  /// Needed to prevent invalid API configuration from breaking network requests.
  static bool _isValidUrl(String value) {
    final uri = Uri.tryParse(value);

    return uri != null && uri.hasScheme && uri.host.isNotEmpty;
  }
}
