/*
##
## OverDrive 2026
## All Technical rights reserved
##
## auth_service.dart - Authentication service for session management.
##
*/

import 'package:flutter/foundation.dart';

/// Exception thrown by the authentication service
class AuthException implements Exception {
    final String message;
    AuthException(this.message);

    @override
    String toString() => message;
    }

    /// Authentication service that manages user session state
    class AuthService extends ChangeNotifier {
    bool _isAuthenticated = false;
    String? _userId;
    String? _userEmail;

    bool get isAuthenticated => _isAuthenticated;
    String? get userId => _userId;
    String? get userEmail => _userEmail;

    /// Simulates login - in production, this would call backend API
    Future<void> login(String email, String password) async {
        try {
        // Simulate network delay
        await Future.delayed(const Duration(milliseconds: 500));

        // Basic validation
        if (email.isEmpty || password.isEmpty) {
            throw AuthException('Email and password are required');
        }

        // Simulate successful login
        _isAuthenticated = true;
        _userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
        _userEmail = email;

        notifyListeners();
        } catch (e) {
        _isAuthenticated = false;
        _userId = null;
        _userEmail = null;
        rethrow;
        }
    }

    /// Simulates logout
    Future<void> logout() async {
        _isAuthenticated = false;
        _userId = null;
        _userEmail = null;
        notifyListeners();
    }

    /// Check if user is authenticated (can be extended for token validation)
    Future<bool> checkAuthStatus() async {
        // In production: validate token, refresh if needed, etc.
        await Future.delayed(const Duration(milliseconds: 300));
        return _isAuthenticated;
    }

    /// Simulate auto-login for development/testing
    void setAuthenticated(bool value) {
        _isAuthenticated = value;
        if (value) {
        _userId = 'dev_user_${DateTime.now().millisecondsSinceEpoch}';
        _userEmail = 'dev@overdrive.local';
        } else {
        _userId = null;
        _userEmail = null;
        }
        notifyListeners();
    }
}
