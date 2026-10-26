
import '../entities/focus_preset.dart';
import '../repositories/focus_preset_repository.dart';

class CreateFocusPreset {
  final FocusPresetRepository repository;

  CreateFocusPreset(this.repository);

  Future<int> call({
    required String name,
    required String moodTag,
    required int durationMinutes,
  }) async {
    if (name.trim().isEmpty) {
      throw ArgumentError('Preset name cannot be empty.');
    }

    if (moodTag.trim().isEmpty) {
      throw ArgumentError('Mood tag cannot be empty.');
    }

    if (durationMinutes <= 0) {
      throw ArgumentError(
        'Duration must be greater than zero.',
      );
    }

    final preset = FocusPreset(
      name: name.trim(),
      moodTag: moodTag.trim(),
      durationMinutes: durationMinutes,
    );

    return repository.createPreset(preset);
  }
}
