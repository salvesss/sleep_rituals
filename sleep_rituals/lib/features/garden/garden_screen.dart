import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/ritual_sequence.dart';

class GardenScreen extends StatelessWidget {
  const GardenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои ритуалы')),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<RitualSequence>('sequences').listenable(),
        builder: (context, Box<RitualSequence> box, _) {
          final rituals = box.values.toList();

          if (rituals.isEmpty) {
            return const Center(
              child: Text(
                'Пока нет сохранённых ритуалов\n\nНажми "Конструктор" внизу\nи создай свой',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rituals.length,
            itemBuilder: (context, index) {
              final ritual = rituals[index];
              return Card(
                color: const Color(0xFF1F1F3A),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Text('🌙', style: TextStyle(fontSize: 38)),
                  title: Text(ritual.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                  subtitle: Text('${ritual.steps.length} шагов'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.play_arrow, color: Colors.green, size: 32),
                        onPressed: () => context.push('/ritual', extra: ritual),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () async {
                          await box.deleteAt(index);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Ритуал удалён')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: () => context.go('/builder'),
          icon: const Icon(Icons.add),
          label: const Text('Создать новый ритуал'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }
}