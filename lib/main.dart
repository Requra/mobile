import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const RequraApp());
}

class RequraApp extends StatelessWidget {
  const RequraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Requra Auth',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5A3D9A)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
