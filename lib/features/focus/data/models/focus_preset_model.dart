
import '../../domain/entities/focus_preset.dart';

class FocusPresetModel extends FocusPreset {
  const FocusPresetModel({
    super.id,
    required super.name,
    required super.moodTag,
    required super.durationMinutes,
  });

  factory FocusPresetModel.fromMap(Map<String, Object?> map) {
    return FocusPresetModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      moodTag: map['mood_tag'] as String,
      durationMinutes: map['duration_minutes'] as int,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'mood_tag': moodTag,
      'duration_minutes': durationMinutes,
    };
  }

  factory FocusPresetModel.fromEntity(FocusPreset preset) {
    return FocusPresetModel(
      id: preset.id,
      name: preset.name,
      moodTag: preset.moodTag,
      durationMinutes: preset.durationMinutes,
    );
  }
}
