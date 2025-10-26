import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import '../../domain/models/check_in.dart';

part 'check_in_dto.freezed.dart';
part 'check_in_dto.g.dart';

/// Data Transfer Object for CheckIn persistence
@freezed
@HiveType(typeId: 1)
class CheckInDto with _$CheckInDto {
  const factory CheckInDto({
    @HiveField(0) required String id,
    @HiveField(1) required String habitId,
    @HiveField(2) required String date,
    @HiveField(3) required int value,
    @HiveField(4) String? note,
    @HiveField(5) required String createdAt,
    @HiveField(6) required String updatedAt,
    @HiveField(7) @Default(false) bool isBackfilled,
  }) = _CheckInDto;

  factory CheckInDto.fromJson(Map<String, dynamic> json) => _$CheckInDtoFromJson(json);

  /// Convert from domain model
  factory CheckInDto.fromDomain(CheckIn checkIn) {
    return CheckInDto(
      id: checkIn.id,
      habitId: checkIn.habitId,
      date: checkIn.date.toIso8601String(),
      value: checkIn.value,
      note: checkIn.note,
      createdAt: checkIn.createdAt.toIso8601String(),
      updatedAt: checkIn.updatedAt.toIso8601String(),
      isBackfilled: checkIn.isBackfilled,
    );
  }
}

/// Extension to convert DTO to domain model
extension CheckInDtoExtension on CheckInDto {
  CheckIn toDomain() {
    return CheckIn(
      id: id,
      habitId: habitId,
      date: DateTime.parse(date),
      value: value,
      note: note,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      isBackfilled: isBackfilled,
    );
  }
}
