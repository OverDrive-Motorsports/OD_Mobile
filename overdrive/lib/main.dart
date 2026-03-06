/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## main.dart - Application entry point and startup configuration.
 ##
 */
 
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
    const envFile = String.fromEnvironment('ENV_FILE', defaultValue: '.env');
    await dotenv.load(fileName: envFile);
    runApp(const MyApp());
}

class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
        final appEnv = dotenv.env['APP_ENV'] ?? 'unknown';

        return MaterialApp.router(
            title: 'OverDrive ($appEnv)',
            routerConfig: appRouter,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
        );
    }
}
