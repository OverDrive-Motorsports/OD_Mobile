/**
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## auth_gate.dart - Roots the application through authentication state.
 ##
 */

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../home/home_page.dart';
import 'login_page.dart';

class AuthGate extends StatefulWidget {
	const AuthGate({super.key});

	@override
	State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
	late final Future<bool> _sessionFuture;

	@override
	void initState() {
		super.initState();
		_sessionFuture = AuthService.instance.hasValidSession();
	}

	@override
	Widget build(BuildContext context) {
		return FutureBuilder<bool>(
			future: _sessionFuture,
			builder: (context, snapshot) {
				if (snapshot.connectionState != ConnectionState.done) {
					return const Scaffold(
						backgroundColor: AppColors.black,
						body: Center(
							child: CircularProgressIndicator(color: AppColors.accent),
						),
					);
				}

				final hasSession = snapshot.data ?? false;
				if (hasSession) {
					return const HomePage();
				}

				return const LoginPage();
			},
		);
	}
}
