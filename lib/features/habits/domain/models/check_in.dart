import 'package:freezed_annotation/freezed_annotation.dart';

part 'check_in.freezed.dart';
part 'check_in.g.dart';

/// Domain model for a habit check-in
@freezed
class CheckIn with _$CheckIn {
  const factory CheckIn({
    required String id,
    required String habitId,
    required DateTime date,
    required int value,
    String? note,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isBackfilled,
  }) = _CheckIn;

  factory CheckIn.fromJson(Map<String, dynamic> json) => _$CheckInFromJson(json);
}
