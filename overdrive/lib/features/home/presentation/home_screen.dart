/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## home_screen.dart - Home feature main presentation screen.
 ##
 */

import 'package:flutter/material.dart';
import '../../../services/api_service.dart';

class HomeScreen extends StatefulWidget {
    const HomeScreen({super.key});

    @override
    State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
    final ApiService _apiService = ApiService();
    bool _isLoading = false;

    Future<void> _checkHealth() async {
        setState(() {
            _isLoading = true;
        });

        final response = await _apiService.checkHealth();

        if (!mounted) {
            return;
        }

        setState(() {
            _isLoading = false;
        });

        if (response.isSuccess && response.data != null) {
            final data = response.data!;
            final status = data['status']?.toString() ?? '-';
            final time = data['time']?.toString() ?? '-';
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Status: $status | Time: $time'),
                ),
            );
            return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(response.error ?? 'Unknown error'),
            ),
        );
    }

    @override
    Widget build(BuildContext context) {
        final theme = Theme.of(context);

        return Scaffold(
            body: SafeArea(
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                            Text(
                                'OVERDRIVE',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.displayLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                                'MOTORSPORT REIMAGINED',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.6,
                                ),
                            ),
                            const SizedBox(height: 28),
                            Text(
                                'Lorem ipsum dolor sit amet, consectetur adipiscing elit, '
                                'sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 20),
                            Text(
                                'VER 1.19.235\nLEC +0.130\nHAD +278',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleMedium,
                            ),
                            const Spacer(),
                            ElevatedButton(
                                onPressed: _isLoading ? null : _checkHealth,
                                child: Text(
                                    _isLoading ? 'Checking...' : 'Check Health',
                                ),
                            ),
                        ],
                    ),
                ),
            ),
        );
    }
}
