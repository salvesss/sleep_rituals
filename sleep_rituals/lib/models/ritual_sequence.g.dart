// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ritual_sequence.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RitualSequenceAdapter extends TypeAdapter<RitualSequence> {
  @override
  final int typeId = 1;

  @override
  RitualSequence read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RitualSequence(
      name: fields[0] as String,
      steps: (fields[1] as List).cast<RitualStep>(),
      lastCompleted: fields[2] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, RitualSequence obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.steps)
      ..writeByte(2)
      ..write(obj.lastCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RitualSequenceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
