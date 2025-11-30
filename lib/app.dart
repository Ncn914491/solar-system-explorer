import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/home_screen.dart';

class SolarSystemApp extends StatelessWidget {
  const SolarSystemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solar System Explorer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkSpaceTheme,
      home: const HomeScreen(),
    );
  }
}
