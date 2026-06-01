import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/ritual_step.dart';
import '../../models/ritual_sequence.dart';

class RitualBuilderScreen extends StatefulWidget {
  const RitualBuilderScreen({super.key});

  @override
  State<RitualBuilderScreen> createState() => _RitualBuilderScreenState();
}

class _RitualBuilderScreenState extends State<RitualBuilderScreen> {
  List<RitualStep> currentSequence = [];

  final List<RitualStep> availableSteps = [
    RitualStep(title: "Дыхание 4-7-8", type: "breathing", durationSeconds: 75),
    RitualStep(title: "Глубокое расслабление", type: "body", durationSeconds: 120),
    RitualStep(title: "Сброс мыслей", type: "mind", durationSeconds: 90),
    RitualStep(title: "Коробочное дыхание", type: "breathing", durationSeconds: 60),
  ];

  void saveSequence() async {
    if (currentSequence.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Добавь хотя бы один шаг')),
      );
      return;
    }

    final box = Hive.box<RitualSequence>('sequences');
    final sequence = RitualSequence(
      name: "Мой ритуал ${DateTime.now().day}.${DateTime.now().month}",
      steps: List.from(currentSequence),
      lastCompleted: DateTime.now(),
    );

    await box.add(sequence);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Ритуал успешно сохранён!')),
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Конструктор ритуала'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text('Сохранить', style: TextStyle(color: Colors.white)),
            onPressed: saveSequence,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black26,
            child: const Text('Твоя последовательность (перетаскивай)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),

          Expanded(
            child: currentSequence.isEmpty
                ? const Center(
              child: Text(
                'Перетащи шаги сюда\nили нажми на доступные ниже',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
                : ReorderableListView(
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = currentSequence.removeAt(oldIndex);
                  currentSequence.insert(newIndex, item);
                });
              },
              children: currentSequence
                  .map((step) => ListTile(
                key: ValueKey(step),
                title: Text(step.title),
                subtitle: Text('${step.durationSeconds} сек'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => setState(() => currentSequence.remove(step)),
                ),
              ))
                  .toList(),
            ),
          ),

          const Divider(height: 1),

          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Доступные шаги (нажми чтобы добавить)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: availableSteps.length,
              itemBuilder: (context, index) {
                final step = availableSteps[index];
                return ListTile(
                  title: Text(step.title),
                  subtitle: Text('${step.durationSeconds} сек'),
                  trailing: const Icon(Icons.add_circle_outline, color: Colors.deepPurpleAccent),
                  onTap: () {
                    setState(() => currentSequence.add(step));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}