/**
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## main.dart - Application entry point and root app setup.
 ##
 */

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'pages/auth/auth_gate.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
	WidgetsFlutterBinding.ensureInitialized();
	const envFile = String.fromEnvironment('ENV_FILE', defaultValue: '.env');

	var envLoaded = false;

	try {
		await dotenv.load(fileName: envFile);
		envLoaded = true;
	} catch (_) {
		// The app can run without an env file and will fallback to default URLs.
	}

	final apiBaseUrl = envLoaded ? dotenv.env['API_BASE_URL'] : 'not loaded';
	debugPrint('Resolved API_BASE_URL=$apiBaseUrl');

	runApp(const OverDriveApp());
}

class OverDriveApp extends StatelessWidget {
	const OverDriveApp({super.key});

	@override
	Widget build(BuildContext context) {
	return MaterialApp(
		debugShowCheckedModeBanner: false,
		title: 'OverDrive',
		home: const AuthGate(),
		theme: AppTheme.darkTheme,
		themeMode: ThemeMode.dark,
	);
	}
}
