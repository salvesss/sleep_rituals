import 'package:hive/hive.dart';
import 'ritual_step.dart';

part 'ritual_sequence.g.dart';

@HiveType(typeId: 1)
class RitualSequence {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final List<RitualStep> steps;

  @HiveField(2)
  DateTime? lastCompleted;

  RitualSequence({
    required this.name,
    required this.steps,
    this.lastCompleted,
  });

  int get totalDuration => steps.fold(0, (sum, s) => sum + s.durationSeconds);
}