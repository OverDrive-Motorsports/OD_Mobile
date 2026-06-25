/*
##
## OverDrive 2026
## All Technical rights reserved
##
## login_page.dart - Demo login screen used as the temporary app landing page.
##
*/

import 'package:flutter/material.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth/fake_auth_service.dart';
import '../../widgets/base/app_button.dart';
import '../../widgets/base/error_message.dart';
import '../../widgets/base/app_text_field.dart';
import '../../widgets/base/app_toast.dart';
import 'auth_page_shell.dart';

/// Temporary login route used until the real authentication backend is wired.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

/// Manages the temporary sign-in form, validation, and login navigation.
class _LoginPageState extends State<LoginPage> {
  final FakeAuthService _authService = FakeAuthService.instance;
  final TextEditingController _emailController = TextEditingController(
    text: FakeAuthService.demoEmail,
  );
  final TextEditingController _passwordController = TextEditingController(
    text: FakeAuthService.demoPassword,
  );

  String? _emailError;
  String? _passwordError;
  String? _pageError;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Opens registration and hydrates the login fields with returned credentials.
  Future<void> _openRegisterPage() async {
    final result = await Navigator.of(context).pushNamed(AppRoutes.register);

    if (!mounted || result is! Map<Object?, Object?>) {
      return;
    }

    final email = result['email'];
    final password = result['password'];

    if (email is String && password is String) {
      setState(() {
        _emailController.text = email;
        _passwordController.text = password;
        _emailError = null;
        _passwordError = null;
        _pageError = null;
      });
    }
  }

  /// Validates and submits the sign-in form through the temporary auth service.
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _emailError = _validateEmail(email);
      _passwordError = _validatePassword(password);
      _pageError = null;
    });

    if (_emailError != null || _passwordError != null) {
      return;
    }

    setState(() => _isSubmitting = true);

    final response = await _authService.signIn(
      email: email,
      password: password,
    );

    if (!mounted) {
      return;
    }

    setState(() => _isSubmitting = false);

    if (!response.isSuccess) {
      setState(() => _pageError = response.message);
      return;
    }

    AppToast.show(
      context,
      message: 'Signed in successfully. Welcome to OverDrive.',
      type: ToastType.success,
    );
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  /// Returns a field-level error when the email is empty or malformed.
  String? _validateEmail(String value) {
    if (value.isEmpty) {
      return 'Enter your email address.';
    }

    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(value)) {
      return 'Enter a valid email address.';
    }

    return null;
  }

  /// Returns a field-level error when the password cannot be submitted.
  String? _validatePassword(String value) {
    if (value.isEmpty) {
      return 'Enter your password.';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageShell(
      footer: AuthFooterLink(
        prompt: 'No account yet?',
        label: 'Sign up',
        onTap: _openRegisterPage,
      ),
      formChild: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, sign in.',
            style: AppTextStyles.bodyBold().copyWith(fontSize: 17),
          ),
          if (_pageError != null) ...[
            const SizedBox(height: 16),
            ErrorMessage(
              message: 'Unable to sign in',
              subtitle: _pageError,
              variant: ErrorMessageVariant.banner,
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'EMAIL',
            style: AppTextStyles.label(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          AppTextField(
            controller: _emailController,
            placeholder: 'name@email.com',
            keyboardType: TextInputType.emailAddress,
            leadingIcon: Icons.alternate_email_rounded,
            errorMessage: _emailError,
            onClear: () {
              setState(() {
                _emailError = null;
                _pageError = null;
              });
            },
            onChanged: (_) {
              if (_emailError != null || _pageError != null) {
                setState(() {
                  _emailError = null;
                  _pageError = null;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          Text(
            'PASSWORD',
            style: AppTextStyles.label(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          AppTextField(
            controller: _passwordController,
            placeholder: '1234567890',
            obscureText: true,
            leadingIcon: Icons.lock_outline_rounded,
            errorMessage: _passwordError,
            onClear: () {
              setState(() {
                _passwordError = null;
                _pageError = null;
              });
            },
            onChanged: (_) {
              if (_passwordError != null || _pageError != null) {
                setState(() {
                  _passwordError = null;
                  _pageError = null;
                });
              }
            },
          ),
          const SizedBox(height: 22),
          AppButton(
            label: 'Sign in',
            onPressed: _isSubmitting ? null : _submit,
            isLoading: _isSubmitting,
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}
