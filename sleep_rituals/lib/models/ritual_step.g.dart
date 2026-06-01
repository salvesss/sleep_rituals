// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ritual_step.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RitualStepAdapter extends TypeAdapter<RitualStep> {
  @override
  final int typeId = 0;

  @override
  RitualStep read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RitualStep(
      title: fields[0] as String,
      type: fields[1] as String,
      durationSeconds: fields[2] as int,
      audioAsset: fields[3] as String?,
      description: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RitualStep obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.durationSeconds)
      ..writeByte(3)
      ..write(obj.audioAsset)
      ..writeByte(4)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RitualStepAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
