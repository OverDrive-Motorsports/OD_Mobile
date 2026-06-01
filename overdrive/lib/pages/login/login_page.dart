/**
##
## OverDrive 2026
## All Technical rights reserved
##
## login_page.dart - Login screen for user authentication.
##
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';

class LoginPage extends StatefulWidget {
	const LoginPage({super.key});

	@override
	State<LoginPage> createState() => _LoginPageState();
	}

	class _LoginPageState extends State<LoginPage> {
	late final TextEditingController _emailController;
	late final TextEditingController _passwordController;
	bool _isLoading = false;
	String? _errorMessage;

	@override
	void initState() {
		super.initState();
		_emailController = TextEditingController(text: 'user@overdrive.eu');
		_passwordController = TextEditingController(text: 'wHyArEyOuGaY');
	}

	@override
	void dispose() {
		_emailController.dispose();
		_passwordController.dispose();
		super.dispose();
	}

	Future<void> _handleLogin() async {
		if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
		setState(() => _errorMessage = 'Please fill in all fields');
		return;
		}

		setState(() {
		_isLoading = true;
		_errorMessage = null;
		});

		try {
		final authService = context.read<AuthService>();
		await authService.login(_emailController.text, _passwordController.text);

		if (mounted) {
			// Navigation handled by GoRouter redirect
		}
		} on Exception catch (e) {
		if (mounted) {
			setState(() => _errorMessage = e.toString());
		}
		} finally {
		if (mounted) {
			setState(() => _isLoading = false);
		}
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
		backgroundColor: AppColors.background,
		body: SafeArea(
			child: SingleChildScrollView(
			child: Padding(
				padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
				child: Column(
				mainAxisAlignment: MainAxisAlignment.center,
				children: [
					const SizedBox(height: 32),
					Text(
					'OverDrive',
					style: AppTextStyles.display(),
					),
					const SizedBox(height: 24),
					Text(
					'Sign in to continue',
					style: AppTextStyles.body(color: AppColors.textSecondary),
					textAlign: TextAlign.center,
					),
					const SizedBox(height: 48),
					TextField(
					controller: _emailController,
					style: AppTextStyles.body(),
					decoration: InputDecoration(
						hintText: 'Email',
						hintStyle: AppTextStyles.body(color: AppColors.textMuted),
						filled: true,
						fillColor: AppColors.surface,
						border: OutlineInputBorder(
						borderRadius: BorderRadius.circular(8),
						borderSide: const BorderSide(color: AppColors.border),
						),
						enabledBorder: OutlineInputBorder(
						borderRadius: BorderRadius.circular(8),
						borderSide: const BorderSide(color: AppColors.border),
						),
						focusedBorder: OutlineInputBorder(
						borderRadius: BorderRadius.circular(8),
						borderSide: const BorderSide(color: AppColors.gold),
						),
						contentPadding: const EdgeInsets.symmetric(
						horizontal: 16,
						vertical: 12,
						),
					),
					keyboardType: TextInputType.emailAddress,
					enabled: !_isLoading,
					),
					const SizedBox(height: 16),
					TextField(
					controller: _passwordController,
					style: AppTextStyles.body(),
					obscureText: true,
					decoration: InputDecoration(
						hintText: 'Password',
						hintStyle: AppTextStyles.body(color: AppColors.textMuted),
						filled: true,
						fillColor: AppColors.surface,
						border: OutlineInputBorder(
						borderRadius: BorderRadius.circular(8),
						borderSide: const BorderSide(color: AppColors.border),
						),
						enabledBorder: OutlineInputBorder(
						borderRadius: BorderRadius.circular(8),
						borderSide: const BorderSide(color: AppColors.border),
						),
						focusedBorder: OutlineInputBorder(
						borderRadius: BorderRadius.circular(8),
						borderSide: const BorderSide(color: AppColors.gold),
						),
						contentPadding: const EdgeInsets.symmetric(
						horizontal: 16,
						vertical: 12,
						),
					),
					enabled: !_isLoading,
					),
					if (_errorMessage != null) ...[
					const SizedBox(height: 16),
					Text(
						_errorMessage!,
						style: AppTextStyles.body(color: AppColors.red),
						textAlign: TextAlign.center,
					),
					],
					const SizedBox(height: 32),
					SizedBox(
					width: double.infinity,
					height: 48,
					child: ElevatedButton(
						onPressed: _isLoading ? null : _handleLogin,
						style: ElevatedButton.styleFrom(
						backgroundColor: AppColors.gold,
						disabledBackgroundColor: AppColors.textMuted,
						shape: RoundedRectangleBorder(
							borderRadius: BorderRadius.circular(8),
						),
						),
						child: _isLoading
							? const SizedBox(
								height: 24,
								width: 24,
								child: CircularProgressIndicator(
								strokeWidth: 2,
								valueColor:
									AlwaysStoppedAnimation<Color>(AppColors.black),
								),
							)
							: Text(
								'Sign In',
								style: AppTextStyles.bodyBold(
								color: AppColors.black,
								),
							),
					),
					),
					const SizedBox(height: 24),
					Text(
					'Demo: Pre-filled credentials for testing',
					style: AppTextStyles.body(color: AppColors.textMuted)
						.copyWith(fontSize: 12),
					textAlign: TextAlign.center,
					),
				],
				),
			),
			),
		),
		);
	}
}
