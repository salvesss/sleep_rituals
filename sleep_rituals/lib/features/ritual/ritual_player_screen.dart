import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:just_audio/just_audio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../models/ritual_sequence.dart';
import '../../models/ritual_step.dart';

class RitualPlayerScreen extends StatefulWidget {
  final String? type;
  final RitualSequence? customSequence;

  const RitualPlayerScreen({super.key, this.type, this.customSequence});

  @override
  State<RitualPlayerScreen> createState() => _RitualPlayerScreenState();
}

class _RitualPlayerScreenState extends State<RitualPlayerScreen> with TickerProviderStateMixin {
  int currentStep = 0;
  int remainingSeconds = 0;
  Timer? timer;
  bool isPlaying = true;

  late AudioPlayer _audioPlayer;
  late AnimationController _glowController;

  late List<Map<String, dynamic>> rituals;

  String activeSound = 'rain';
  double volume = 0.8;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);

    if (widget.customSequence != null) {
      rituals = widget.customSequence!.steps.map((step) => {
        "title": step.title,
        "duration": step.durationSeconds,
        "icon": "🌙",
        "color": Colors.deepPurpleAccent,
        "desc": "Твой кастомный шаг",
        "instruction": "Выполняй так, как ты запланировал",
        "fact": "Это твой личный ритуал — он уникальный!",
      }).toList();
    } else if (widget.type == 'morning') {
      rituals = _morningRitual;
    } else {
      rituals = widget.type == 'full' ? _fullRitual : _quickRitual;
    }

    remainingSeconds = rituals[0]['duration'];
    _playSelectedSounds();
    startTimer();
  }

  // Полный ритуал без "Благодарность" и "Полет к Луне"
  final List<Map<String, dynamic>> _fullRitual = [
    {"title": "Дыхание 4-7-8", "duration": 75, "icon": "🌬️", "color": Colors.blueAccent, "desc": "Техника доктора Эндрю Вейла", "instruction": "Вдох 4 сек → задержка 7 сек → выдох 8 сек. Повтори 4–8 раз.", "fact": "Снижает уровень кортизола за 60 секунд."},
    {"title": "Глубокое расслабление", "duration": 120, "icon": "🧘", "color": Colors.purpleAccent, "desc": "Прогрессивная мышечная релаксация", "instruction": "Напрягай и расслабляй мышцы от макушки до пальцев ног.", "fact": "Используется в клинической психологии более 80 лет."},
  ];

  // Быстрый ритуал с новым названием
  final List<Map<String, dynamic>> _quickRitual = [
    {"title": "Коробочное дыхание", "duration": 60, "icon": "📦", "color": Colors.tealAccent, "desc": "Техника Navy SEALs", "instruction": "Вдох 4 → задержка 4 → выдох 4 → задержка 4. Повтори 4 раза.", "fact": "Используется военными для быстрого снижения стресса."},
    {"title": "Сброс мыслей", "duration": 90, "icon": "🌊", "color": Colors.indigoAccent, "desc": "Brain dump", "instruction": "Представь, как все мысли дня уходят, как волны в океан.", "fact": "Запись мыслей перед сном снижает время засыпания на 50%."},
  ];

  // Утренний ритуал (оставлен)
  final List<Map<String, dynamic>> _morningRitual = [
    {"title": "Утреннее дыхание", "duration": 60, "icon": "🌅", "color": Colors.orangeAccent, "desc": "Солнечное дыхание", "instruction": "Глубокий вдох носом на 4 секунды, выдох ртом на 6 секунд. Повтори 8 раз.", "fact": "Утреннее дыхание повышает уровень кислорода и бодрость на весь день."},
    {"title": "Растяжка тела", "duration": 90, "icon": "🧘‍♂️", "color": Colors.cyanAccent, "desc": "Активация тела", "instruction": "Потягайся: руки вверх, наклоны, вращение плечами и шеей.", "fact": "5 минут утренней растяжки улучшают кровообращение."},
    {"title": "Визуализация успеха", "duration": 70, "icon": "🌟", "color": Colors.yellowAccent, "desc": "Настройка на день", "instruction": "Представь свой идеальный день: как ты себя чувствуешь и что достигаешь.", "fact": "Утренние визуализации повышают вероятность достижения целей."},
  ];

  Future<void> _playSelectedSounds() async {
    try {
      await _audioPlayer.stop();
      String assetPath = 'assets/sounds/rain.mp3';
      if (activeSound == 'fire') assetPath = 'assets/sounds/fire.mp3';
      if (activeSound == 'wind') assetPath = 'assets/sounds/wind.mp3';

      await _audioPlayer.setAsset(assetPath);
      await _audioPlayer.setVolume(volume);
      await _audioPlayer.setLoopMode(LoopMode.one);
      if (isPlaying) await _audioPlayer.play();
    } catch (e) {
      print("❌ Ошибка звука: $e");
    }
  }

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remainingSeconds > 0 && isPlaying) {
        setState(() => remainingSeconds--);
      } else if (remainingSeconds <= 0) {
        nextStep();
      }
    });
  }

  void nextStep() {
    if (currentStep < rituals.length - 1) {
      setState(() {
        currentStep++;
        remainingSeconds = rituals[currentStep]['duration'];
      });
    } else {
      _finishRitual();
    }
  }

  void _finishRitual() async {
    timer?.cancel();
    await _audioPlayer.stop();

    final box = Hive.box<RitualSequence>('sequences');
    await box.add(RitualSequence(
      name: widget.customSequence?.name ?? (widget.type == 'morning' ? "Утренний ритуал" : "Ритуал"),
      steps: [],
      lastCompleted: DateTime.now(),
    ));

    if (mounted) {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    _audioPlayer.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ritual = rituals[currentStep];

    return Scaffold(
      backgroundColor: const Color(0xFF05040F),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${currentStep + 1}/${rituals.length}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                    IconButton(icon: const Icon(Icons.close, size: 32), onPressed: () => context.go('/home')),
                  ],
                ),

                const SizedBox(height: 20),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: ScaleTransition(scale: animation, child: child)),
                  child: Container(
                    key: ValueKey(currentStep),
                    height: 300,
                    width: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: (ritual['color'] as Color).withOpacity(0.5), width: 4),
                      boxShadow: [BoxShadow(color: (ritual['color'] as Color).withOpacity(0.4), blurRadius: 60)],
                    ),
                    child: Center(child: Text(ritual['icon'], style: const TextStyle(fontSize: 160))),
                  ),
                ),

                const SizedBox(height: 40),
                Text(ritual['title'], style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(ritual['desc'], style: const TextStyle(fontSize: 17, color: Colors.white70), textAlign: TextAlign.center),

                const SizedBox(height: 30),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
                  child: Text(ritual['instruction'], style: const TextStyle(fontSize: 17, height: 1.6), textAlign: TextAlign.center),
                ),

                const SizedBox(height: 30),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.amber, size: 26),
                    const SizedBox(width: 12),
                    Expanded(child: Text(ritual['fact'], style: const TextStyle(fontSize: 16, color: Colors.amber, fontStyle: FontStyle.italic, height: 1.5))),
                  ],
                ),

                const SizedBox(height: 40),
                Text(remainingSeconds.toString(), style: const TextStyle(fontSize: 92, fontWeight: FontWeight.w100)),

                const SizedBox(height: 50),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), borderRadius: BorderRadius.circular(30)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _asmrButton(Icons.water_drop, "Дождь", activeSound == 'rain', () => _setActiveSound('rain')),
                      _asmrButton(Icons.local_fire_department, "Костёр", activeSound == 'fire', () => _setActiveSound('fire')),
                      _asmrButton(Icons.air, "Ветер", activeSound == 'wind', () => _setActiveSound('wind')),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    const Icon(Icons.volume_down, color: Colors.white54),
                    Expanded(
                      child: Slider(
                        value: volume,
                        min: 0.0,
                        max: 1.0,
                        divisions: 20,
                        activeColor: Colors.deepPurpleAccent,
                        inactiveColor: Colors.white24,
                        onChanged: (value) {
                          setState(() => volume = value);
                          _audioPlayer.setVolume(volume);
                        },
                      ),
                    ),
                    const Icon(Icons.volume_up, color: Colors.white54),
                  ],
                ),

                const SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() => isPlaying = !isPlaying);
                        if (isPlaying) _audioPlayer.play();
                        else _audioPlayer.pause();
                      },
                      icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 90),
                    ),
                    const SizedBox(width: 30),
                    IconButton(onPressed: nextStep, icon: const Icon(Icons.skip_next_rounded, size: 85)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _setActiveSound(String sound) {
    setState(() => activeSound = sound);
    _playSelectedSounds();
  }

  Widget _asmrButton(IconData icon, String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 32, color: active ? Colors.white : Colors.white54),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 13, color: active ? Colors.white : Colors.white54)),
        ],
      ),
    );
  }
}