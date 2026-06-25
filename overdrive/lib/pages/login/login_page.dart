/*
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
import '../../widgets/base/app_button.dart';
import '../../widgets/base/app_text_field.dart';
import '../../widgets/base/error_message.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController(
    text: 'user@overdrive.eu',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: 'wHyArEyOuGaY',
  );

  String? _emailError;
  String? _passwordError;
  String? _pageError;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String value) {
    if (value.isEmpty) return 'Saisis ton adresse email.';
    final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!pattern.hasMatch(value)) return 'Adresse email invalide.';
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) return 'Saisis ton mot de passe.';
    if (value.length < 6) return 'Minimum 6 caractères.';
    return null;
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _emailError = _validateEmail(email);
      _passwordError = _validatePassword(password);
      _pageError = null;
    });

    if (_emailError != null || _passwordError != null) return;

    setState(() => _isLoading = true);

    try {
      await context.read<AuthService>().login(email, password);
    } on Exception catch (e) {
      if (mounted) {
        setState(() => _pageError = e.toString());
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
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          // ── Backdrop ────────────────────────────────────────────────────
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.6),
                radius: 1.2,
                colors: [
                  AppColors.grayOpaque.withValues(alpha: 0.18),
                  AppColors.black,
                ],
              ),
            ),
            child: const SizedBox.expand(),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 64),

                  // ── Header ───────────────────────────────────────────────
                  Text(
                    'OverDrive',
                    style: AppTextStyles.bodyBold().copyWith(fontSize: 34),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Connecte-toi pour continuer.',
                    style: AppTextStyles.body(color: AppColors.textSecondary)
                        .copyWith(fontSize: 16),
                  ),

                  const SizedBox(height: 40),

                  // ── Page-level error ─────────────────────────────────────
                  if (_pageError != null) ...[
                    ErrorMessage(
                      message: 'Connexion impossible',
                      subtitle: _pageError,
                      variant: ErrorMessageVariant.banner,
                    ),
                    const SizedBox(height: 20),
                  ],

                  // ── Email ────────────────────────────────────────────────
                  Text(
                    'EMAIL',
                    style: AppTextStyles.label(color: AppColors.textSecondary)
                        .copyWith(letterSpacing: 1.0),
                  ),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: _emailController,
                    placeholder: 'nom@email.com',
                    keyboardType: TextInputType.emailAddress,
                    leadingIcon: Icons.alternate_email_rounded,
                    errorMessage: _emailError,
                    onChanged: (_) {
                      if (_emailError != null || _pageError != null) {
                        setState(() {
                          _emailError = null;
                          _pageError = null;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 18),

                  // ── Password ─────────────────────────────────────────────
                  Text(
                    'MOT DE PASSE',
                    style: AppTextStyles.label(color: AppColors.textSecondary)
                        .copyWith(letterSpacing: 1.0),
                  ),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: _passwordController,
                    placeholder: '••••••••',
                    obscureText: true,
                    leadingIcon: Icons.lock_outline_rounded,
                    errorMessage: _passwordError,
                    onChanged: (_) {
                      if (_passwordError != null || _pageError != null) {
                        setState(() {
                          _passwordError = null;
                          _pageError = null;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 28),

                  // ── Submit ───────────────────────────────────────────────
                  AppButton(
                    label: 'Se connecter',
                    onPressed: _isLoading ? null : _handleLogin,
                    isLoading: _isLoading,
                    fullWidth: true,
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: Text(
                      'Démo — identifiants pré-remplis',
                      style: AppTextStyles.body(color: AppColors.textMuted)
                          .copyWith(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
