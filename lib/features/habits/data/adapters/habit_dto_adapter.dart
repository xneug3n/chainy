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
    String parseString(dynamic value) => value is String ? value : value.toString();

    String parseGoalType(dynamic value) {
      if (value is String) return value;
      if (value is int) {
        // Legacy enum index
        switch (value) {
          case 0:
            return 'binary';
          case 1:
            return 'quantitative';
        }
      }
      return value.toString();
    }

    String parseRecurrenceType(dynamic value) {
      if (value is String) return value;
      if (value is int) {
        // Legacy enum index order: daily, multiplePerDay, weekly, custom
        switch (value) {
          case 0:
            return 'daily';
          case 1:
            return 'multiplePerDay';
          case 2:
            return 'weekly';
          case 3:
            return 'custom';
        }
      }
      return value.toString();
    }

    String parseDate(dynamic value) {
      if (value is String) return value; // already ISO8601
      if (value is DateTime) return value.toIso8601String();
      if (value is int) {
        // legacy millisecondsSinceEpoch
        return DateTime.fromMillisecondsSinceEpoch(value).toIso8601String();
      }
      return value.toString();
    }

    final rawConfig = fields[8];
    final Map<String, dynamic> config = rawConfig is Map
        ? Map<String, dynamic>.from(rawConfig)
        : <String, dynamic>{};

    final nowIso = DateTime.now().toIso8601String();
    final dynamic rawCreatedAt = fields[10];
    final dynamic rawUpdatedAt = fields[11];

    return HabitDto(
      id: parseString(fields[0] ?? ''),
      name: (fields[1] as String?) ?? '',
      icon: (fields[2] as String?) ?? '📝',
      colorValue: fields[3] is int ? fields[3] as int : int.tryParse('${fields[3]}') ?? 0xFF2196F3,
      goalType: parseGoalType(fields[4] ?? 'binary'),
      targetValue: fields[5] is int ? fields[5] as int : int.tryParse('${fields[5]}') ?? 1,
      unit: fields[6] as String?,
      recurrenceType: parseRecurrenceType(fields[7] ?? 'daily'),
      recurrenceConfig: config,
      note: fields[9] as String?,
      createdAt: rawCreatedAt == null ? nowIso : parseDate(rawCreatedAt),
      updatedAt: rawUpdatedAt == null ? nowIso : parseDate(rawUpdatedAt),
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
