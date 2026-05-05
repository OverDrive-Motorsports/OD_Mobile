/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## main.dart - Application entry point and root app setup.
 ##
 */

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/theme/app_theme.dart';
import 'core/navigation/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const envFile = String.fromEnvironment('ENV_FILE', defaultValue: '.env');

  try {
    await dotenv.load(fileName: envFile);
  } catch (_) {
    // The app can run without an env file and will fallback to default URLs.
  }

  runApp(const OverDriveApp());
}

class OverDriveApp extends StatelessWidget {
  const OverDriveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OverDrive',
      initialRoute: AppRoutes.login,
      onGenerateRoute: buildAppRoute,
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
    );
  }
}
