import 'package:flutter/material.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/recording_dashboard/recording_dashboard.dart';

class AppRoutes {
  static const String initial = '/';
  static const String loginScreen = '/login-screen';
  static const String recordingDashboard = '/recording-dashboard';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Loading CardioScope AI...'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.loginScreen);
              },
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    ),
    loginScreen: (context) => const LoginScreen(),
    recordingDashboard: (context) => const RecordingDashboard(),
  };
}