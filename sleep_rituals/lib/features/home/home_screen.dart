import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF05040F), Color(0xFF1A1835)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Доброй ночи 🌙", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                    Text("Готов ко сну?", style: TextStyle(fontSize: 18, color: Colors.grey)),
                  ],
                ),

                const SizedBox(height: 50),

                GestureDetector(
                  onTap: () => context.push('/garden'),
                  child: Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      gradient: const LinearGradient(colors: [Color(0xFF2A1B4D), Color(0xFF1A0F35)]),
                    ),
                    child: const Center(
                      child: Text('🌕', style: TextStyle(fontSize: 155)),
                    ),
                  ),
                ),

                const SizedBox(height: 55),

                const Text('Сегодня', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                _buildCard(context, "Полный ритуал", "🌕", Colors.deepPurpleAccent, () => context.push('/ritual?type=full')),
                const SizedBox(height: 12),
                _buildCard(context, "Быстрый ритуал", "🌲", Colors.tealAccent, () => context.push('/ritual?type=quick')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, String icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1F1F3A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 48)),
            const SizedBox(width: 20),
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
            ),
            Icon(Icons.arrow_forward_ios, color: color),
          ],
        ),
      ),
    );
  }
}