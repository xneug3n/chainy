import 'package:hive/hive.dart';
import '../models/habit_dto.dart';

/// Hive TypeAdapter for HabitDto
class HabitDtoAdapter extends TypeAdapter<HabitDto> {
  @override
  final int typeId = 0;

  @override
  HabitDto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitDto(
      id: fields[0] as String,
      name: fields[1] as String,
      icon: fields[2] as String,
      colorValue: fields[3] as int,
      goalType: fields[4] as String,
      targetValue: fields[5] as int,
      unit: fields[6] as String?,
      recurrenceType: fields[7] as String,
      recurrenceConfig: Map<String, dynamic>.from(fields[8] as Map),
      note: fields[9] as String?,
      createdAt: fields[10] as String,
      updatedAt: fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HabitDto obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.icon)
      ..writeByte(3)
      ..write(obj.colorValue)
      ..writeByte(4)
      ..write(obj.goalType)
      ..writeByte(5)
      ..write(obj.targetValue)
      ..writeByte(6)
      ..write(obj.unit)
      ..writeByte(7)
      ..write(obj.recurrenceType)
      ..writeByte(8)
      ..write(obj.recurrenceConfig)
      ..writeByte(9)
      ..write(obj.note)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitDtoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
