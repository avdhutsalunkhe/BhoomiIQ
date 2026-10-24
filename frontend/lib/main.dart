import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/main_shell_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BhoomiIQApp());
}

class BhoomiIQApp extends StatelessWidget {
  const BhoomiIQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BhoomiIQ — Sugarcane Satellite Intelligence',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkCommandTheme,
      home: const MainShellScreen(),
    );
  }
}
