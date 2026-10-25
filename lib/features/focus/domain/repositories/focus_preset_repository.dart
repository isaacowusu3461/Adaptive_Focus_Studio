
import '../entities/focus_preset.dart';

abstract class FocusPresetRepository {
  Future<List<FocusPreset>> getAllPresets();

  Future<FocusPreset?> getPresetById(int id);

  Future<int> createPreset(FocusPreset preset);

  Future<int> updatePreset(FocusPreset preset);

  Future<int> deletePreset(int id);
}
