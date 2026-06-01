import 'package:hive/hive.dart';

part 'ritual_step.g.dart';

@HiveType(typeId: 0)
class RitualStep {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String type;

  @HiveField(2)
  final int durationSeconds;

  @HiveField(3)
  final String? audioAsset;

  @HiveField(4)
  final String? description;

  RitualStep({
    required this.title,
    required this.type,
    required this.durationSeconds,
    this.audioAsset,
    this.description,
  });
}