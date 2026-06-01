import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05040F),
      appBar: AppBar(title: const Text('Настройки')),
      body: const Center(
        child: Text(
          'Настройки приложения\n(будет расширено позже)',
          style: TextStyle(fontSize: 20, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}