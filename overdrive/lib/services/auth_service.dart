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

class AuthServiceException implements Exception {
	const AuthServiceException(this.message);

	final String message;

	@override
	String toString() => message;
}

class AuthService {
	AuthService._privateConstructor()
		: _storage = const FlutterSecureStorage(),
		  _baseUrl = _resolveBaseUrl(null),
		  _dio = Dio(
			  BaseOptions(
				  connectTimeout: const Duration(seconds:15),
				  receiveTimeout: const Duration(seconds:60),
				  validateStatus: (status)=> status != null && status < 500,
			  )
		  ){

		if(_isValidUrl(_baseUrl)){
			_dio.options.baseUrl = _baseUrl;
		}
	}

	static final AuthService instance = AuthService._privateConstructor();

	static const _tokenKey = "od_access_token";
	static const _sessionIdKey = "od_session_id";
	static const _refreshTokenKey = "od_refresh_token";
	static const _expiresAtKey = "od_expires_at";

	final Dio _dio;
	final FlutterSecureStorage _storage;
	final String _baseUrl;

	Future<AuthTokens> login(
		String email,
		String password
	) async {
		return _authenticate(
			"/login",
			{
				"email":email.trim(),
				"password":password.trim()
			}
		);
	}

	Future<AuthTokens> signup(
		String email,
		String password,
		String username
	) async {
		return _authenticate(
			"/register",
			{
				"email":email.trim(),
				"password":password.trim(),
				"username":username.trim()
			}
		);
	}

	Future<AuthTokens> _authenticate(
		String path,
		Map<String, dynamic> body,
	) async {
		try {
			debugPrint("========== AUTH START ==========");
			debugPrint("POST $path");
			debugPrint("REQUEST BODY: $body");
			debugPrint("========== AUTH REQUEST ==========");
			debugPrint("URL: ${_dio.options.baseUrl}$path");
			debugPrint("BODY: $body");
			final response = await _dio.post(path, data: body);

			debugPrint("AUTH STATUS: ${response.statusCode}");
			debugPrint("AUTH BODY: ${response.data}");

			if (response.statusCode == null || response.statusCode! >= 400) {
				throw AuthServiceException(
					_extractError(response.data),
				);
			}

			final data = response.data as Map<String, dynamic>;

			final token = data["token"];
			final refreshToken = data["refreshToken"];

			if (token == null) {
				throw const AuthServiceException("JWT token missing");
			}

			final sessionId = data["sessionId"];

			if (sessionId == null) {
				throw const AuthServiceException("Session ID missing");
			}

			if (refreshToken == null) {
				throw const AuthServiceException("Refresh token missing");
			}

			final expires = data["expiresAt"];

			final tokens = AuthTokens(
				accessToken: token,
				sessionId: sessionId,
				refreshToken: refreshToken,
				expiresAt: expires != null
					? DateTime.tryParse(expires)
					: null,
			);

			debugPrint("Access token: ${tokens.accessToken}");
			debugPrint("Session ID: ${tokens.sessionId}");
			debugPrint("Refresh token: ${tokens.refreshToken}");
			debugPrint("Expires: ${tokens.expiresAt}");

			await _saveToken(tokens);

			debugPrint("Tokens saved.");
			debugPrint("========== AUTH END ==========");

			return tokens;
		} on DioException catch (e) {
			debugPrint("AUTH ERROR: ${e.message}");
			throw AuthServiceException(
			_resolveError(e),
			);
		}
	}

	Future<void> _saveToken(AuthTokens tokens) async {
		await _storage.write(
			key:_tokenKey,
			value:tokens.accessToken,
		);
		await _storage.write(
			key: _sessionIdKey,
			value: tokens.sessionId,
		);
		await _storage.write(
			key: _refreshTokenKey,
			value: tokens.refreshToken,
		);
		await _storage.write(
			key: _expiresAtKey,
			value: tokens.expiresAt?.toIso8601String(),
		);


		debugPrint("TOKEN SAVED");
		debugPrint("SESSION ID: ${tokens.sessionId}");
		debugPrint("REFRESH TOKEN: ${tokens.refreshToken}");
	}

	Future<String?> get accessToken async {
		return await _storage.read(
			key:_tokenKey
		);
	}

	Future<String?> get sessionId async {
		return await _storage.read(
			key: _sessionIdKey,
		);
	}

	Future<String?> get refreshToken async {
		return await _storage.read(
			key: _refreshTokenKey,
		);
	}


	Future<void> testRefresh() async {
	debugPrint("========== REFRESH TEST ==========");

	final oldRefreshToken = await refreshToken;
	final oldSessionId = await sessionId;

	debugPrint("OLD REFRESH TOKEN: $oldRefreshToken");
	debugPrint("OLD SESSION ID: $oldSessionId");

	final response = await _dio.post(
		"/refresh",
		data: {
		"sessionId": oldSessionId,
		"refreshToken": oldRefreshToken,
		},
	);

	debugPrint("REFRESH STATUS: ${response.statusCode}");
	debugPrint("REFRESH RESPONSE: ${response.data}");
	}

	Future<AuthTokens> refreshTokens() async {

		debugPrint("========== REFRESH START ==========");

		final refresh = await refreshToken;

		if (refresh == null) {
			throw const AuthServiceException(
				"No refresh token",
			);
		}

		final session = await sessionId;

		if (session == null) {
			throw const AuthServiceException(
				"No session id",
			);
		}

		debugPrint("Session ID: $session");
		debugPrint("Stored refresh token: $refresh");

		final response = await _dio.post(
			"/refresh",
			data: {
				"sessionId": session,
				"refreshToken": refresh,
			},
		);

		debugPrint("REFRESH STATUS: ${response.statusCode}");
		debugPrint("REFRESH RESPONSE: ${response.data}");

		if (response.statusCode == null ||
			response.statusCode! >= 400) {
			throw AuthServiceException(
				_extractError(response.data),
			);
		}

		final data = response.data as Map<String, dynamic>;

		final token = data["token"];
		final newRefreshToken = data["refreshToken"];

		if (token == null || newRefreshToken == null) {
			throw const AuthServiceException(
				"Invalid refresh response",
			);
		}

		final tokens = AuthTokens(
			accessToken: token,
			sessionId: session,
			refreshToken: newRefreshToken,
			expiresAt: data["expiresAt"] != null
				? DateTime.tryParse(data["expiresAt"])
				: null,
		);

		debugPrint("NEW ACCESS TOKEN: ${tokens.accessToken}");
		debugPrint("NEW REFRESH TOKEN: ${tokens.refreshToken}");
		debugPrint("NEW EXPIRES AT: ${tokens.expiresAt}");

		await _saveToken(tokens);

		debugPrint("Refresh tokens saved.");
		debugPrint("========== REFRESH END ==========");

		return tokens;
	}


	Future<bool> hasValidSession() async {
		final token = await accessToken;

		if (token == null || token.isEmpty) {
			return false;
		}

		final expires = await _storage.read(
			key: _expiresAtKey,
		);

		if (expires == null) {
			return true;
		}

		final expiration = DateTime.tryParse(expires);

		if (expiration == null) {
			return true;
		}

		if (DateTime.now().isBefore(expiration)) {
			return true;
		}

		try {
			await refreshTokens();
			return true;
		} catch (_) {
			await logout();
			return false;
		}
	}

	Future<void> logout() async {
		await _storage.delete(key: _tokenKey);
		await _storage.delete(key: _sessionIdKey);
		await _storage.delete(key: _refreshTokenKey);
		await _storage.delete(key: _expiresAtKey);
	}

	String _extractError(dynamic data){
		if(data is Map<String,dynamic>){
			return data["error"] ?? data["message"] ?? "Authentication failed";
		}

		return "Authentication failed";
	}

	String _resolveError(DioException e){

		if(e.type == DioExceptionType.connectionTimeout){
			return "Backend timeout";
		}

		return e.message ?? "Network error";
	}

	static String _resolveBaseUrl(String? value){
		if(value != null && _isValidUrl(value)) {
			return value;
		}

		final env = dotenv.isInitialized ? dotenv.env["API_BASE_URL"] :	null;

		debugPrint("DOTENV INITIALIZED: ${dotenv.isInitialized}");
		debugPrint("API_BASE_URL FROM ENV: $env");
		
		if(env != null && _isValidUrl(env)){
			return env;
		}
		if(kIsWeb){
			return "http://localhost:3001";
		}
		if(defaultTargetPlatform ==	TargetPlatform.android){
			return "http://10.0.2.2:3001";
		}
		return "http://localhost:3001";
	}

	static bool _isValidUrl(String value){
		final uri =	Uri.tryParse(value);

		return uri != null &&
			   uri.hasScheme &&
			   uri.host.isNotEmpty;
	}
}