import 'package:flutter/material.dart';
class ProfilePage extends StatelessWidget {
  final Function(ThemeMode) toggleTheme;
  final ThemeMode currentTheme;
  const ProfilePage({super.key, required this.toggleTheme, required this.currentTheme});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Profil')), body: const Center(child: Text('TEXORA Profil')));
  }
}
