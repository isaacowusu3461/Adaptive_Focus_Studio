
import '../../data/datasources/database_helper.dart';
import '../../data/repositories/focus_preset_repository_impl.dart';
import '../../domain/repositories/focus_preset_repository.dart';
import '../../domain/usecases/create_focus_preset.dart';
import '../../domain/usecases/delete_focus_preset.dart';
import '../../domain/usecases/update_focus_preset.dart';

class FocusDependencies {
  final DatabaseHelper databaseHelper;

  late final FocusPresetRepository presetRepository;
  late final CreateFocusPreset createFocusPreset;
  late final UpdateFocusPreset updateFocusPreset;
  late final DeleteFocusPreset deleteFocusPreset;

  FocusDependencies({DatabaseHelper? databaseHelper})
      : databaseHelper = databaseHelper ?? DatabaseHelper() {
    presetRepository = FocusPresetRepositoryImpl(
      databaseHelper: this.databaseHelper,
    );

    createFocusPreset = CreateFocusPreset(presetRepository);
    updateFocusPreset = UpdateFocusPreset(presetRepository);
    deleteFocusPreset = DeleteFocusPreset(presetRepository);
  }
}
