/*
##
## OverDrive 2026
## All Technical rights reserved
##
## login_page.dart - Login screen with email/password form
##
*/

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/auth/auth_service.dart';
import 'package:go_router/go_router.dart';

/// Login screen responsible for user authentication flow.
class LoginPage extends StatefulWidget {
	static const routeName = '/login';

	const LoginPage({super.key});

	static Route<void> route() {
		return MaterialPageRoute<void>(builder: (_) => const LoginPage());
	}

	@override
	State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
	// Form key controls validation lifecycle before sending credentials.
	final _formKey = GlobalKey<FormState>();
	// Controllers store user input before authentication request.
	final _emailController = TextEditingController();
	final _passwordController = TextEditingController();

	// Prevents multiple authentication requests and tracks backend errors.
	bool _isLoading = false;
	String? _submissionError;

	// Release controllers to avoid memory leaks.
	@override
	void dispose() {
		_emailController.dispose();
		_passwordController.dispose();
		super.dispose();
	}

	/// Validates credentials, authenticates user and updates application session.
	Future<void> _onSubmit() async {
		// Stop submission if local validation fails.
		if (!_formKey.currentState!.validate()) {
			return;
		}

		setState(() {
			_isLoading = true;
			_submissionError = null;
		});

		try {
			// Sends credentials to backend and stores received tokens.
			await AuthService.instance.login(
				_emailController.text,
				_passwordController.text,
			);

			if (!mounted) {
				return;
			}
		
			// Redirect to main application after successful authentication.
			context.go('/');
		} on AuthServiceException catch (exception) {
			setState(() {
				_submissionError = exception.message;
			});
		} finally {
			if (mounted) {
				setState(() {
					_isLoading = false;
				});
			}
		}
	}

	/// Checks that email has a minimal valid format.
	String? _validateEmail(String? raw) {
		final value = raw?.trim() ?? '';
		if (value.isEmpty) {
			return 'Email is required.';
		}
		if (!value.contains('@') || value.length < 5) {
			return 'Enter a valid email address.';
		}
		return null;
	}
	
	/// Checks password presence and minimal security requirement
	String? _validatePassword(String? raw) {
		final value = raw ?? '';
		if (value.isEmpty) {
			return 'Password is required.';
		}
		if (value.length < 8) {
			return 'Password must be at least 8 characters.';
		}
		return null;
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: AppColors.black,
			body: SafeArea(
				child: Center(
					child: SingleChildScrollView(
						padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
						child: Column(
							mainAxisSize: MainAxisSize.min,
							children: [
								Text('Welcome back', style: AppTextStyles.display()),
								const SizedBox(height: 8),
								Text(
									'Log in to access OverDrive.',
									style: AppTextStyles.body(color: AppColors.textSecondary),
									textAlign: TextAlign.center,
								),
								const SizedBox(height: 32),
								Form(
									key: _formKey,
									child: Column(
										children: [
											_buildInputField(
												controller: _emailController,
												label: 'Email',
												hint: 'name@example.com',
												validator: _validateEmail,
												keyboardType: TextInputType.emailAddress,
											),
											const SizedBox(height: 16),
											_buildInputField(
												controller: _passwordController,
												label: 'Password',
												hint: 'Enter your password',
												validator: _validatePassword,
												obscureText: true,
											),
										],
									),
								),
								if (_submissionError != null) ...[
									const SizedBox(height: 16),
									Text(
										_submissionError!,
										style: AppTextStyles.body(color: AppColors.error),
										textAlign: TextAlign.center,
									),
								],
								const SizedBox(height: 24),
								ElevatedButton(
									onPressed: _isLoading ? null : _onSubmit,
									child: SizedBox(
										width: double.infinity,
										child: Center(
											child: _isLoading
													? const SizedBox(
															height: 20,
															width: 20,
															child: CircularProgressIndicator(
																color: AppColors.black,
																strokeWidth: 2,
															),
														)
													: const Text('Login'),
										),
									),
								),
								const SizedBox(height: 16),
								Row(
									mainAxisAlignment: MainAxisAlignment.center,
									children: [
										Text('Need an account?', style: AppTextStyles.caption()),
										TextButton(
											onPressed: _isLoading
													? null
													: () {
															context.go('/signup');
														},
											child: const Text('Sign Up'),
										),
									],
								),
							],
						),
					),
				),
			),
		);
	}

	/// Reusable input component to keep authentication fields consistent.
	Widget _buildInputField({
		required TextEditingController controller,
		required String label,
		required String hint,
		required String? Function(String?) validator,
		bool obscureText = false,
		TextInputType keyboardType = TextInputType.text,
	}) {
		return TextFormField(
			controller: controller,
			keyboardType: keyboardType,
			obscureText: obscureText,
			style: AppTextStyles.body(),
			validator: validator,
			autovalidateMode: AutovalidateMode.onUserInteraction,
			decoration: InputDecoration(
				labelText: label,
				hintText: hint,
				labelStyle: AppTextStyles.caption(color: AppColors.textMuted),
				hintStyle: AppTextStyles.caption(color: AppColors.textMuted),
				filled: true,
				fillColor: AppColors.surface,
				border: OutlineInputBorder(
					borderRadius: BorderRadius.circular(16),
					borderSide: BorderSide.none,
				),
				contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
			),
		);
	}
}
