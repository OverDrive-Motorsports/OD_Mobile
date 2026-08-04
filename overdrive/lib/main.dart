/*
##
## OverDrive 2026
## All Technical rights reserved
##
## main.dart - Application entry point and root app setup.
##
*/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'config/app_router.dart';
import 'core/theme/app_theme.dart';
import 'services/auth/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
    ),
  );

  const envFile = String.fromEnvironment('ENV_FILE', defaultValue: '.env');

  var envLoaded = false;

  try {
    await dotenv.load(fileName: envFile);

    envLoaded = true;
  } catch (_) {
    // The app can run without an env file
    // and will fallback to default URLs.
  }

  final apiBaseUrl = envLoaded ? dotenv.env['API_BASE_URL'] : 'not loaded';

  debugPrint('Resolved API_BASE_URL=$apiBaseUrl');

  await AuthService.instance.initialize();

  runApp(const OverDriveApp());
}

class OverDriveApp extends StatelessWidget {
  const OverDriveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: AuthService.instance,

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
