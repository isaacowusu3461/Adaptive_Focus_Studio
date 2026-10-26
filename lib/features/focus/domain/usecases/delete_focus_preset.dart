
import '../repositories/focus_preset_repository.dart';

class DeleteFocusPreset {
  final FocusPresetRepository repository;

  DeleteFocusPreset(this.repository);

  Future<int> call(int id) async {
    if (id <= 0) {
      throw ArgumentError(
        'A valid preset ID is required for deletion.',
      );
    }

    return repository.deletePreset(id);
  }
}
