import 'package:flutter/material.dart';
import 'package:iosmobileapp/core/theme/app_theme.dart';
import 'package:iosmobileapp/features/auth/presentation/splash_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'uTime',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
