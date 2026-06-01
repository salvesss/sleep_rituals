import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  List<Map<String, dynamic>> alarms = [];
  late AudioPlayer _previewPlayer;
  Timer? _checkTimer;
  Timer? _previewStopTimer;

  String? _currentlyPlayingSound; // какой звук сейчас играет в предпрослушке

  @override
  void initState() {
    super.initState();
    _previewPlayer = AudioPlayer();
    _loadAlarms();
    _startChecking();
  }

  void _loadAlarms() {
    final box = Hive.box('alarms');
    setState(() {
      alarms = List.from(box.get('list', defaultValue: []));
    });
  }

  void _saveAlarms() {
    final box = Hive.box('alarms');
    box.put('list', alarms);
  }

  void _addAlarm() async {
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) return;

    setState(() {
      alarms.add({
        'id': DateTime.now().millisecondsSinceEpoch,
        'hour': time.hour,
        'minute': time.minute,
        'sound': 'classic_alarm',
        'enabled': true,
      });
    });
    _saveAlarms();
  }

  void _deleteAlarm(int id) {
    setState(() => alarms.removeWhere((a) => a['id'] == id));
    _saveAlarms();
  }

  void _toggleAlarm(int id) {
    setState(() {
      final alarm = alarms.firstWhere((a) => a['id'] == id);
      alarm['enabled'] = !alarm['enabled'];
    });
    _saveAlarms();
  }

  void _changeSound(int id, String newSound) {
    // Если уже играет этот же звук — выключаем
    if (_currentlyPlayingSound == newSound) {
      _previewPlayer.stop();
      _previewStopTimer?.cancel();
      setState(() => _currentlyPlayingSound = null);
      return;
    }

    // Иначе — включаем новый звук
    setState(() => _currentlyPlayingSound = newSound);
    _playPreview(newSound);

    // Обновляем выбранный звук в будильнике
    final alarm = alarms.firstWhere((a) => a['id'] == id);
    alarm['sound'] = newSound;
    _saveAlarms();
  }

  Future<void> _playPreview(String sound) async {
    await _previewPlayer.stop();
    _previewStopTimer?.cancel();

    String asset = 'assets/sounds/classic_alarm.mp3';
    if (sound == 'digital_beep') asset = 'assets/sounds/digital_beep.mp3';
    if (sound == 'loud_bell') asset = 'assets/sounds/loud_bell.mp3';

    try {
      await _previewPlayer.setAsset(asset);
      await _previewPlayer.setVolume(0.9);
      await _previewPlayer.play();

      // Жёстко 3 секунды
      _previewStopTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          _previewPlayer.stop();
          setState(() => _currentlyPlayingSound = null);
        }
      });
    } catch (e) {
      print("❌ Предпрослушка: $e");
    }
  }

  void _startChecking() {
    _checkTimer?.cancel();
    _checkTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      final now = TimeOfDay.now();
      for (var alarm in alarms) {
        if (alarm['enabled'] == true && alarm['hour'] == now.hour && alarm['minute'] == now.minute) {
          _triggerAlarm(alarm);
          break;
        }
      }
    });
  }

  Future<void> _triggerAlarm(Map<String, dynamic> alarm) async {
    await _previewPlayer.stop();
    _previewStopTimer?.cancel();

    String asset = 'assets/sounds/classic_alarm.mp3';
    if (alarm['sound'] == 'digital_beep') asset = 'assets/sounds/digital_beep.mp3';
    if (alarm['sound'] == 'loud_bell') asset = 'assets/sounds/loud_bell.mp3';

    try {
      await _previewPlayer.setAsset(asset);
      await _previewPlayer.setVolume(1.0);
      await _previewPlayer.setLoopMode(LoopMode.one);
      await _previewPlayer.play();
    } catch (e) {
      print("❌ Будильник: $e");
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF05040F),
        title: const Text('🌅 Доброе утро!', style: TextStyle(color: Colors.white, fontSize: 28)),
        content: const Text('Время просыпаться!', style: TextStyle(color: Colors.white70, fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () {
              _previewPlayer.stop();
              Navigator.pop(context);
            },
            child: const Text('Отложить 5 мин'),
          ),
          ElevatedButton(
            onPressed: () {
              _previewPlayer.stop();
              Navigator.pop(context);
              context.go('/ritual?type=morning');
            },
            child: const Text('Начать утренний ритуал'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _previewStopTimer?.cancel();
    _previewPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05040F),
      appBar: AppBar(title: const Text('🌙 Будильники')),
      floatingActionButton: FloatingActionButton(onPressed: _addAlarm, child: const Icon(Icons.add)),
      body: alarms.isEmpty
          ? const Center(child: Text('Нажми + чтобы добавить будильник', style: TextStyle(color: Colors.white54, fontSize: 18)))
          : ListView.builder(
        itemCount: alarms.length,
        itemBuilder: (context, index) {
          final alarm = alarms[index];
          final time = TimeOfDay(hour: alarm['hour'], minute: alarm['minute']).format(context);
          return Card(
            color: const Color(0xFF1F1F3A),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.alarm, size: 36, color: Colors.deepPurpleAccent),
              title: Text(time, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w300)),
              subtitle: Row(
                children: [
                  GestureDetector(
                    onTap: () => _changeSound(alarm['id'], 'classic_alarm'),
                    child: Text('🛎️', style: TextStyle(fontSize: 24, color: _currentlyPlayingSound == 'classic_alarm' ? Colors.deepPurpleAccent : null)),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _changeSound(alarm['id'], 'digital_beep'),
                    child: Text('📟', style: TextStyle(fontSize: 24, color: _currentlyPlayingSound == 'digital_beep' ? Colors.deepPurpleAccent : null)),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _changeSound(alarm['id'], 'loud_bell'),
                    child: Text('🔔', style: TextStyle(fontSize: 24, color: _currentlyPlayingSound == 'loud_bell' ? Colors.deepPurpleAccent : null)),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(value: alarm['enabled'], onChanged: (_) => _toggleAlarm(alarm['id']), activeColor: Colors.deepPurpleAccent),
                  IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () => _deleteAlarm(alarm['id'])),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}