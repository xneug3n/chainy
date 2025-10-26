import 'package:hive/hive.dart';
import '../models/check_in_dto.dart';

/// Hive TypeAdapter for CheckInDto
class CheckInDtoAdapter extends TypeAdapter<CheckInDto> {
  @override
  final int typeId = 1;

  @override
  CheckInDto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CheckInDto(
      id: fields[0] as String,
      habitId: fields[1] as String,
      date: fields[2] as String,
      value: fields[3] as int,
      note: fields[4] as String?,
      createdAt: fields[5] as String,
      updatedAt: fields[6] as String,
      isBackfilled: fields[7] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, CheckInDto obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.habitId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.value)
      ..writeByte(4)
      ..write(obj.note)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.isBackfilled);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheckInDtoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
