/*
##
## OverDrive 2026
## All Technical rights reserved
##
## register_page.dart - Local sign-up flow used until backend account creation is connected.
##
*/

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/auth/fake_auth_service.dart';
import '../../widgets/base/app_button.dart';
import '../../widgets/base/error_message.dart';
import '../../widgets/base/app_text_field.dart';
import '../../widgets/base/app_toast.dart';
import 'auth_page_shell.dart';

/// Temporary registration route used to simulate local account creation.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

/// Manages the temporary account creation form and validation lifecycle.
class _RegisterPageState extends State<RegisterPage> {
  final FakeAuthService _authService = FakeAuthService.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _pageError;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Validates the form and returns created credentials to the login page.
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _nameError = _validateName(name);
      _emailError = _validateEmail(email);
      _passwordError = _validatePassword(password);
      _confirmPasswordError = _validateConfirmPassword(
        password,
        confirmPassword,
      );
      _pageError = null;
    });

    if (_nameError != null ||
        _emailError != null ||
        _passwordError != null ||
        _confirmPasswordError != null) {
      return;
    }

    setState(() => _isSubmitting = true);

    final response = await _authService.register(
      fullName: name,
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
      message: 'Account created. You can now sign in.',
      type: ToastType.success,
    );

    Navigator.of(context).pop(<String, String>{
      'email': response.email ?? email,
      'password': password,
    });
  }

  /// Returns a field-level error when the display name is invalid.
  String? _validateName(String value) {
    if (value.isEmpty) {
      return 'Enter your name or username.';
    }

    if (value.length < 2) {
      return 'Use at least 2 characters.';
    }

    return null;
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

  /// Returns a field-level error when the password is too weak for sign-up.
  String? _validatePassword(String value) {
    if (value.isEmpty) {
      return 'Choose a password.';
    }

    if (value.length < 8) {
      return 'Use at least 8 characters.';
    }

    return null;
  }

  /// Returns a field-level error when confirmation is missing or mismatched.
  String? _validateConfirmPassword(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) {
      return 'Confirm your password.';
    }

    if (password != confirmPassword) {
      return 'Passwords do not match.';
    }

    return null;
  }

  /// Clears form validation errors after the user edits or clears a field.
  void _clearErrors({bool clearPage = true}) {
    setState(() {
      _nameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      if (clearPage) {
        _pageError = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageShell(
      footer: AuthFooterLink(
        prompt: 'Already have an account?',
        label: 'Sign in',
        onTap: () => Navigator.of(context).pop(),
      ),
      formChild: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, sign up.',
            style: AppTextStyles.bodyBold().copyWith(fontSize: 17),
          ),
          if (_pageError != null) ...[
            const SizedBox(height: 16),
            ErrorMessage(
              message: 'Unable to sign up',
              subtitle: _pageError,
              variant: ErrorMessageVariant.banner,
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'NAME / USERNAME',
            style: AppTextStyles.label(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          AppTextField(
            controller: _nameController,
            placeholder: 'Your username',
            leadingIcon: Icons.person_outline_rounded,
            errorMessage: _nameError,
            onClear: _clearErrors,
            onChanged: (_) {
              if (_nameError != null || _pageError != null) {
                _clearErrors();
              }
            },
          ),
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
            onClear: _clearErrors,
            onChanged: (_) {
              if (_emailError != null || _pageError != null) {
                _clearErrors();
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
            placeholder: 'Minimum 8 characters',
            obscureText: true,
            leadingIcon: Icons.lock_outline_rounded,
            errorMessage: _passwordError,
            onClear: _clearErrors,
            onChanged: (_) {
              if (_passwordError != null || _pageError != null) {
                _clearErrors();
              }
            },
          ),
          const SizedBox(height: 16),
          Text(
            'CONFIRM PASSWORD',
            style: AppTextStyles.label(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          AppTextField(
            controller: _confirmPasswordController,
            placeholder: 'Re-enter your password',
            obscureText: true,
            leadingIcon: Icons.verified_user_outlined,
            errorMessage: _confirmPasswordError,
            onClear: _clearErrors,
            onChanged: (_) {
              if (_confirmPasswordError != null || _pageError != null) {
                _clearErrors();
              }
            },
          ),
          const SizedBox(height: 22),
          AppButton(
            label: 'Create account',
            onPressed: _isSubmitting ? null : _submit,
            isLoading: _isSubmitting,
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}
