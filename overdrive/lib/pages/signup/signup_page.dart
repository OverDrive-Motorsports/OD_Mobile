/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## signup_page.dart - Signup screen with password confirmation.
 ##
 */

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/auth/auth_service.dart';
import 'package:go_router/go_router.dart';

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
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _submissionError;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Handles account creation flow: validates input, sends registration request and redirects user to login.
  Future<void> _onSubmit() async {
    // Debug checkpoint to confirm that the submit action was triggered.
    debugPrint('SUBMIT PRESSED');

    // Prevents sending invalid registration data to backend.
    if (!_formKey.currentState!.validate()) {
      debugPrint('VALIDATION FAILED');
      return;
    }

    debugPrint('VALIDATION OK');

    setState(() {
      // Locks the form during request and clears previous errors.
      _isLoading = true;
      _submissionError = null;
    });

    try {
      // Sends user registration data to authentication service.
      debugPrint('CALLING SIGNUP');

      await AuthService.instance.signup(
        _emailController.text.trim(),
        _passwordController.text,
        _usernameController.text.trim(),
      );

      debugPrint('SIGNUP DONE');

      // Prevents navigation if widget was removed during async request.
      if (!mounted) {
        debugPrint('NOT MOUNTED');
        return;
      }

      // Redirects user to login after successful account creation.
      debugPrint('GOING LOGIN');
      debugPrint('AUTH STATUS = ${AuthService.instance.isAuthenticated}');

      context.go('/login');

      debugPrint('AFTER GO');
    } on AuthServiceException catch (e) {
      // Displays backend authentication errors to the user.
      debugPrint('AUTH ERROR: ${e.message}');

      setState(() {
        _submissionError = e.message;
      });
    } finally {
      // Unlocks the form after request completion.
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

  String? _validateUsername(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) {
      return 'Username is required.';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters.';
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
                        controller: _usernameController,
                        label: 'Username',
                        hint: 'AssassinMaster78541',
                        validator: _validateUsername,
                        keyboardType: TextInputType.name,
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
                    Text(
                      'Already have an account?',
                      style: AppTextStyles.caption(),
                    ),
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
      ),
    );
  }
}
