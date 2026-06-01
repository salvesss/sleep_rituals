import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';

class AlarmRingingScreen extends StatefulWidget {
  final Map<String, dynamic> alarm;
  const AlarmRingingScreen({super.key, required this.alarm});

  @override
  State<AlarmRingingScreen> createState() => _AlarmRingingScreenState();
}

class _AlarmRingingScreenState extends State<AlarmRingingScreen> with TickerProviderStateMixin {
  late AudioPlayer player;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    player = AudioPlayer();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _playAlarm();
  }

  Future<void> _playAlarm() async {
    String asset = 'assets/sounds/classic_alarm.mp3';
    if (widget.alarm['sound'] == 'digital_beep') asset = 'assets/sounds/digital_beep.mp3';
    if (widget.alarm['sound'] == 'loud_bell') asset = 'assets/sounds/loud_bell.mp3';

    try {
      await player.setAsset(asset);
      await player.setVolume(1.0);
      await player.setLoopMode(LoopMode.one);
      await player.play();
    } catch (e) {}
  }

  @override
  void dispose() {
    player.stop();
    player.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A0F35), Color(0xFF2A1B4D), Color(0xFF3D2A1F)],
          ),
        ),
        child: SafeArea(
          child: Center(  // ← теперь строго по центру
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Солнце посередине
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.7), blurRadius: 100, spreadRadius: 30)],
                  ),
                  child: const Text('☀️', style: TextStyle(fontSize: 180))
                      .animate(controller: _pulseController)
                      .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.2, 1.2)),
                ),

                const SizedBox(height: 40),

                const Text(
                  'ДОБРОЕ УТРО!',
                  style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 3),
                ),

                const SizedBox(height: 8),
                Text(
                  TimeOfDay.now().format(context),
                  style: const TextStyle(fontSize: 64, color: Colors.white70, fontWeight: FontWeight.w200),
                ),

                const SizedBox(height: 50),

                const Text(
                  'Время начинать новый день\nс хорошим настроением',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 19, color: Colors.white70, height: 1.4),
                ),

                const SizedBox(height: 70),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        player.stop();
                        Navigator.of(context).pop(); // закрываем окно
                        context.go('/home');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white24,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                      ),
                      child: const Text('Отложить 5 мин', style: TextStyle(fontSize: 17)),
                    ),
                    const SizedBox(width: 24),
                    ElevatedButton(
                      onPressed: () {
                        player.stop();
                        Navigator.of(context).pop(); // закрываем окно
                        context.go('/ritual?type=morning');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                      ),
                      child: const Text('УТРЕННИЙ РИТУАЛ', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}