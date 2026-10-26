
import '../entities/focus_preset.dart';
import '../repositories/focus_preset_repository.dart';

class UpdateFocusPreset {
  final FocusPresetRepository repository;

  UpdateFocusPreset(this.repository);

  Future<int> call({
    required int id,
    required String name,
    required String moodTag,
    required int durationMinutes,
  }) async {
    if (id <= 0) {
      throw ArgumentError('A valid preset ID is required.');
    }

    final trimmedName = name.trim();
    final trimmedMood = moodTag.trim();

    if (trimmedName.isEmpty) {
      throw ArgumentError('Preset name cannot be empty.');
    }

    if (trimmedName.length > 50) {
      throw ArgumentError(
        'Preset name cannot exceed 50 characters.',
      );
    }

    if (trimmedMood.isEmpty) {
      throw ArgumentError('Mood tag cannot be empty.');
    }

    if (durationMinutes < 1 || durationMinutes > 180) {
      throw ArgumentError(
        'Duration must be between 1 and 180 minutes.',
      );
    }

    final preset = FocusPreset(
      id: id,
      name: trimmedName,
      moodTag: trimmedMood,
      durationMinutes: durationMinutes,
    );

    return repository.updatePreset(preset);
  }
}
