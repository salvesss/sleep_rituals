import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';

import 'features/home/home_screen.dart';
import 'features/garden/garden_screen.dart';
import 'features/builder/ritual_builder_screen.dart';
import 'features/ritual/ritual_player_screen.dart';
import 'features/alarm/alarm_screen.dart';
import 'features/alarm/alarm_ringing_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/onboarding/terms_screen.dart';

import 'models/ritual_step.dart';
import 'models/ritual_sequence.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(RitualStepAdapter());
  Hive.registerAdapter(RitualSequenceAdapter());

  await Hive.openBox<RitualSequence>('sequences');
  await Hive.openBox('settings');
  await Hive.openBox('alarms');

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Timer? _alarmTimer;

  @override
  void initState() {
    super.initState();
    _startAlarmChecker();
  }

  void _startAlarmChecker() {
    _alarmTimer?.cancel();
    _alarmTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      final box = Hive.box('alarms');
      final alarms = List.from(box.get('list', defaultValue: []));

      final now = TimeOfDay.now();
      for (var alarm in alarms) {
        if (alarm['enabled'] == true &&
            alarm['hour'] == now.hour &&
            alarm['minute'] == now.minute) {
          final context = navigatorKey.currentContext;
          if (context != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => AlarmRingingScreen(alarm: alarm),
              ),
            );
          }
          break;
        }
      }
    });
  }

  @override
  void dispose() {
    _alarmTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sleep Rituals',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF05040F),
      ),
      routerConfig: _router,
    );
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final GoRouter _router = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: '/terms',
  routes: [
    GoRoute(
      path: '/terms',
      builder: (context, state) {
        final box = Hive.box('settings');
        final accepted = box.get('accepted_terms', defaultValue: false);
        return accepted ? const HomeScreen() : const TermsScreen();
      },
    ),
    ShellRoute(
      builder: (context, state, child) => ScaffoldWithBottomNav(child: child),
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(path: '/garden', builder: (context, state) => const GardenScreen()),
        GoRoute(path: '/builder', builder: (context, state) => const RitualBuilderScreen()),
        GoRoute(path: '/alarm', builder: (context, state) => const AlarmScreen()),
        GoRoute(
          path: '/ritual',
          builder: (context, state) {
            final type = state.uri.queryParameters['type'];
            final custom = state.extra as RitualSequence?;
            return RitualPlayerScreen(type: type, customSequence: custom);
          },
        ),
        GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
      ],
    ),
    GoRoute(
      path: '/alarm-ringing',
      builder: (context, state) {
        final alarm = state.extra as Map<String, dynamic>;
        return AlarmRingingScreen(alarm: alarm);
      },
    ),
  ],
);

class ScaffoldWithBottomNav extends StatefulWidget {
  final Widget child;
  const ScaffoldWithBottomNav({super.key, required this.child});

  @override
  State<ScaffoldWithBottomNav> createState() => _ScaffoldWithBottomNavState();
}

class _ScaffoldWithBottomNavState extends State<ScaffoldWithBottomNav> {
  int _currentIndex = 0;

  void _onTap(int index) {
    setState(() => _currentIndex = index);
    switch (index) {
      case 0: context.go('/home'); break;
      case 1: context.go('/garden'); break;
      case 2: context.go('/alarm'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        backgroundColor: const Color(0xFF0F0D24),
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Дом'),
          BottomNavigationBarItem(icon: Icon(Icons.park), label: 'Мои ритуалы'),
          BottomNavigationBarItem(icon: Icon(Icons.alarm), label: 'Будильник'),
        ],
      ),
    );
  }
}