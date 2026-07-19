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
		this.expiresAt,
	});

	final String accessToken;
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

	static final AuthService instance =
		AuthService._privateConstructor();

	static const _tokenKey = "od_access_token";

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
		Map<String,dynamic> body
	) async {
		try{
			final response = await _dio.post(path, data:body);

			debugPrint(
			'AAAAAAAAAAAAAAAAAAAAAUTH RESPONSE ${response.statusCode}: ${response.data}/n/n'
			);

			if(response.statusCode == null || response.statusCode! >=400){
				throw AuthServiceException(
					_extractError(response.data)
				);
			}

			final data = response.data as Map<String,dynamic>;

			final token = data["token"];

			if(token == null){
				throw const AuthServiceException(
					"JWT token missing"
				);
			}

			final expires = data["expiresAt"];
			final tokens = AuthTokens(
					accessToken:token,
					expiresAt:
						expires != null
						? DateTime.tryParse(expires)
						: null
				);
			await _saveToken(tokens);

			return tokens;
		}

		on DioException catch(e){
			throw AuthServiceException(
				_resolveError(e)
			);
		}
	}

	Future<void> _saveToken(AuthTokens tokens) async {
		await _storage.write(
			key:_tokenKey,
			value:tokens.accessToken
		);
	}

	Future<String?> get accessToken async {
		return await _storage.read(
			key:_tokenKey
		);
	}

	Future<bool> hasValidSession() async {
		final token = await accessToken;

		return token != null && token.isNotEmpty;
	}

	Future<void> logout() async {
		await _storage.delete(
			key:_tokenKey
		);
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