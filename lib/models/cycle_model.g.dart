// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cycle_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CycleAdapter extends TypeAdapter<Cycle> {
  @override
  final int typeId = 0;

  @override
  Cycle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Cycle(
      startDate: fields[0] as DateTime,
      endDate: fields[1] as DateTime?,
      notes: fields[2] as String?,
      flowIntensity: fields[3] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Cycle obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.startDate)
      ..writeByte(1)
      ..write(obj.endDate)
      ..writeByte(2)
      ..write(obj.notes)
      ..writeByte(3)
      ..write(obj.flowIntensity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CycleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
