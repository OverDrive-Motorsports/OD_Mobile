/**
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## api_client.dart - Shared Dio client with JWT token injection.
 ##
 */

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'auth_service.dart';


class ApiClient {
	ApiClient._privateConstructor()
			: _baseUrl = _resolveBaseUrl(null),
			  _dio = Dio(
				BaseOptions(
					connectTimeout: const Duration(seconds:15),
					receiveTimeout: const Duration(seconds:60),
				),
			  ) {
		if(_isValidUrl(_baseUrl)){
			_dio.options.baseUrl = _baseUrl;
		}

		_dio.interceptors.add(
			InterceptorsWrapper(
				onRequest: (options, handler) async {
					final token = await AuthService.instance.accessToken;
					if(token != null && token.isNotEmpty){
						options.headers['Authorization'] = 'Bearer $token';
					}
					return handler.next(options);
				},

				onError: (error, handler) async {
					// TO DO: Refresh logic here after backend provides /refresh endpoint
					return handler.next(error);
				}
			)
		);
	}

	static final ApiClient instance = ApiClient._privateConstructor();
	final Dio _dio;
	final String _baseUrl;

	Dio get dio => _dio;
	static String _resolveBaseUrl(String? explicitBaseUrl){
		final fromArg =	(explicitBaseUrl ?? '').trim();
		if(_isValidUrl(fromArg)){
			return fromArg;
		}

		final fromEnv =	dotenv.isInitialized ? (dotenv.env['API_BASE_URL'] ?? '').trim() : '';

		if(_isValidUrl(fromEnv)){
			return fromEnv;
		}

		if(kIsWeb){
			return 'http://localhost:3001';
		}

		if(defaultTargetPlatform == TargetPlatform.android){
			// For Android emulator: http://10.0.2.2:3001
			// For physical device: computer IP or .env API_BASE_URL

			return 'http://10.0.2.2:3001';
		}
		return 'http://localhost:3001';
	}

	static bool _isValidUrl(String value){
		if(value.isEmpty){
			return false;
		}

		final uri = Uri.tryParse(value);

		return uri != null &&
			   uri.hasScheme &&
			   (uri.scheme == 'http' ||
				uri.scheme == 'https') &&
			   uri.host.isNotEmpty;

	}

}