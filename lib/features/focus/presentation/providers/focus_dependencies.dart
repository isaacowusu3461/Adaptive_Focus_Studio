
import '../../data/datasources/database_helper.dart';
import '../../data/repositories/focus_preset_repository_impl.dart';
import '../../domain/repositories/focus_preset_repository.dart';
import '../../domain/usecases/create_focus_preset.dart';

class FocusDependencies {
  final DatabaseHelper databaseHelper;
  late final FocusPresetRepository presetRepository;
  late final CreateFocusPreset createFocusPreset;

  FocusDependencies({DatabaseHelper? databaseHelper})
      : databaseHelper = databaseHelper ?? DatabaseHelper() {
    presetRepository = FocusPresetRepositoryImpl(
      databaseHelper: this.databaseHelper,
    );

    createFocusPreset = CreateFocusPreset(presetRepository);
  }
}
