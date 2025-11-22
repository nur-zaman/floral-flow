// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fasting_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FastingLogAdapter extends TypeAdapter<FastingLog> {
  @override
  final int typeId = 1;

  @override
  FastingLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FastingLog(
      date: fields[0] as DateTime,
      status: fields[1] as String,
      reason: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FastingLog obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.status)
      ..writeByte(2)
      ..write(obj.reason);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FastingLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
