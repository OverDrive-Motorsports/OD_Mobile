/**
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## signup_page.dart - Signup screen with password confirmation.
 ##
 */

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../home/home_page.dart';

class SignupPage extends StatefulWidget {
	static const routeName = '/signup';

	const SignupPage({super.key});

	static Route<void> route() {
		return MaterialPageRoute<void>(builder: (_) => const SignupPage());
	}

	@override
	State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
	final _formKey = GlobalKey<FormState>();
	final _emailController = TextEditingController();
	final _passwordController = TextEditingController();
	final _confirmPasswordController = TextEditingController();

	bool _isLoading = false;
	String? _submissionError;

	@override
	void dispose() {
		_emailController.dispose();
		_passwordController.dispose();
		_confirmPasswordController.dispose();
		super.dispose();
	}

	Future<void> _onSubmit() async {
		if (!_formKey.currentState!.validate()) {
			return;
		}

		setState(() {
			_isLoading = true;
			_submissionError = null;
		});

		try {
			await AuthService.instance.signup(
				_emailController.text,
				_passwordController.text,
			);

			if (!mounted) {
				return;
			}

			Navigator.of(context).pushAndRemoveUntil(
				HomePage.route(),
				(route) => false,
			);
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

	String? _validateConfirmation(String? raw) {
		final value = raw ?? '';
		if (value.isEmpty) {
			return 'Confirm your password.';
		}
		if (value != _passwordController.text) {
			return 'Passwords do not match.';
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
								Text('Create your account', style: AppTextStyles.display()),
								const SizedBox(height: 8),
								Text(
									'Signup with email and password to continue.',
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
												hint: 'Create a password',
												validator: _validatePassword,
												obscureText: true,
											),
											const SizedBox(height: 16),
											_buildInputField(
												controller: _confirmPasswordController,
												label: 'Confirm Password',
												hint: 'Repeat your password',
												validator: _validateConfirmation,
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
													: const Text('Sign Up'),
										),
									),
								),
								const SizedBox(height: 16),
								Row(
									mainAxisAlignment: MainAxisAlignment.center,
									children: [
										Text('Already have an account?', style: AppTextStyles.caption()),
										TextButton(
											onPressed: _isLoading
													? null
													: () {
															Navigator.of(context).pop();
														},
											child: const Text('Login'),
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
