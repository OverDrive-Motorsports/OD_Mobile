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

enum _HealthViewState { idle, loading, result }

class HomeScreen extends StatefulWidget {
    const HomeScreen({super.key});

    @override
    State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
    final ApiService _apiService = ApiService();

    _HealthViewState _state = _HealthViewState.idle;
    String? _status;
    String? _time;
    String? _error;

    Future<void> _checkHealth() async {
        setState(() {
            _state = _HealthViewState.loading;
            _status = null;
            _time = null;
            _error = null;
        });

        final response = await _apiService.checkHealth();

        if (!mounted) {
            return;
        }

        setState(() {
            _state = _HealthViewState.result;

            if (response.isSuccess && response.data != null) {
                final data = response.data!;
                _status = data['status']?.toString();
                _time = data['time']?.toString();
                _error = null;
            } else {
                _error = response.error ?? 'Unknown error';
            }
        });
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: Center(
                child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            ElevatedButton(
                                onPressed: _state == _HealthViewState.loading
                                    ? null
                                    : _checkHealth,
                                child: const Text('Check Health'),
                            ),
                            const SizedBox(height: 16),
                            if (_state == _HealthViewState.loading)
                                const CircularProgressIndicator()
                            else if (_state == _HealthViewState.result &&
                                _error != null)
                                Text(
                                    _error!,
                                    style: const TextStyle(color: Colors.red),
                                )
                            else if (_state == _HealthViewState.result)
                                Column(
                                    children: [
                                        Text('Status: ${_status ?? '-'}'),
                                        Text('Time: ${_time ?? '-'}'),
                                    ],
                                ),
                        ],
                    ),
                ),
            ),
        );
    }
}