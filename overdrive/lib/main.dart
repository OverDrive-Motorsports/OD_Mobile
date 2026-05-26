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
import 'package:provider/provider.dart';

import 'config/app_router.dart';
import 'core/theme/app_theme.dart';
import 'services/auth_service.dart';

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
    return ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: Consumer<AuthService>(
        builder: (context, authService, _) {
          final router = createRouter(authService);
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'OverDrive',
            routerConfig: router,
            theme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark,
          );
        },
      ),
    );
  }
}
