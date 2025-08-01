import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_export.dart';
import 'widgets/login_form_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Add haptic feedback for medical device feel
      HapticFeedback.lightImpact();
      
      // Simulate authentication process
      await Future.delayed(const Duration(seconds: 2));
      
      // Success haptic feedback
      HapticFeedback.heavyImpact();
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.recordingDashboard);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Authentication failed. Please check your credentials.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleBiometricAuth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      HapticFeedback.lightImpact();
      
      // Simulate biometric authentication
      await Future.delayed(const Duration(seconds: 1));
      
      HapticFeedback.heavyImpact();
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.recordingDashboard);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Biometric authentication failed. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 64),
                
                // Medical Logo Section
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.medical_services, size: 60, color: Colors.white),
                ),
                
                const SizedBox(height: 48),
                
                // Login Form
                LoginFormWidget(
                  onLogin: _handleLogin,
                  isLoading: _isLoading,
                  errorMessage: _errorMessage,
                ),
                
                const SizedBox(height: 32),
                
                // Biometric Authentication
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleBiometricAuth,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Use Biometric'),
                ),
                
                const SizedBox(height: 32),
                
                // Back to Splash Option
                TextButton(
                  onPressed: _isLoading ? null : () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Back to Home',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}