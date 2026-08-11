import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class HomePage extends StatelessWidget {
  final Function(ThemeMode) toggleTheme;
  final ThemeMode currentTheme;
  const HomePage({super.key, required this.toggleTheme, required this.currentTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TEXORA')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(20)),
              child: const Center(child: Text('T', style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold))),
            ),
            const SizedBox(height: 20),
            const Text('TEXORA Marketplace', style: AppTextStyles.h2),
            const Text('Offline-first, local DB'),
          ],
        ),
      ),
    );
  }
}
