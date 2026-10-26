
import '../../data/datasources/database_helper.dart';
import '../../data/repositories/focus_preset_repository_impl.dart';
import '../../data/repositories/session_log_repository_impl.dart';
import '../../domain/repositories/focus_preset_repository.dart';
import '../../domain/repositories/session_log_repository.dart';
import '../../domain/usecases/calculate_session_scout.dart';
import '../../domain/usecases/create_focus_preset.dart';
import '../../domain/usecases/delete_focus_preset.dart';
import '../../domain/usecases/get_session_scout_recommendation.dart';
import '../../domain/usecases/save_session_log.dart';
import '../../domain/usecases/update_focus_preset.dart';

class FocusDependencies {
  final DatabaseHelper databaseHelper;

  late final FocusPresetRepository presetRepository;
  late final SessionLogRepository sessionRepository;

  late final CreateFocusPreset createFocusPreset;
  late final UpdateFocusPreset updateFocusPreset;
  late final DeleteFocusPreset deleteFocusPreset;
  late final SaveSessionLog saveSessionLog;

  late final CalculateSessionScout calculateSessionScout;
  late final GetSessionScoutRecommendation
      getSessionScoutRecommendation;

  FocusDependencies({DatabaseHelper? databaseHelper})
      : databaseHelper = databaseHelper ?? DatabaseHelper() {
    presetRepository = FocusPresetRepositoryImpl(
      databaseHelper: this.databaseHelper,
    );

    sessionRepository = SessionLogRepositoryImpl(
      databaseHelper: this.databaseHelper,
    );

    createFocusPreset = CreateFocusPreset(presetRepository);
    updateFocusPreset = UpdateFocusPreset(presetRepository);
    deleteFocusPreset = DeleteFocusPreset(presetRepository);
    saveSessionLog = SaveSessionLog(sessionRepository);

    calculateSessionScout = CalculateSessionScout();

    getSessionScoutRecommendation =
        GetSessionScoutRecommendation(
      presetRepository: presetRepository,
      sessionRepository: sessionRepository,
      calculateSessionScout: calculateSessionScout,
    );
  }
}
