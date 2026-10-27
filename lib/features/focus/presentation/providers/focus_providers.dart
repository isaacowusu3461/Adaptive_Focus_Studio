
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/focus_preset.dart';
import '../../domain/entities/session_log.dart';
import '../../domain/entities/session_scout_recommendation.dart';
import '../../domain/repositories/focus_preset_repository.dart';
import '../../domain/repositories/session_log_repository.dart';
import '../../domain/usecases/create_focus_preset.dart';
import '../../domain/usecases/delete_focus_preset.dart';
import '../../domain/usecases/get_session_scout_recommendation.dart';
import '../../domain/usecases/save_session_log.dart';
import '../../domain/usecases/update_focus_preset.dart';
import 'focus_dependencies.dart';

final focusDependenciesProvider = Provider<FocusDependencies>((ref) {
  throw StateError(
    'FocusDependencies must be provided at app startup.',
  );
});

final focusPresetRepositoryProvider =
    Provider<FocusPresetRepository>((ref) {
  return ref.watch(focusDependenciesProvider).presetRepository;
});

final sessionLogRepositoryProvider =
    Provider<SessionLogRepository>((ref) {
  return ref.watch(focusDependenciesProvider).sessionRepository;
});

final createFocusPresetProvider = Provider<CreateFocusPreset>((ref) {
  return ref.watch(focusDependenciesProvider).createFocusPreset;
});

final updateFocusPresetProvider = Provider<UpdateFocusPreset>((ref) {
  return ref.watch(focusDependenciesProvider).updateFocusPreset;
});

final deleteFocusPresetProvider = Provider<DeleteFocusPreset>((ref) {
  return ref.watch(focusDependenciesProvider).deleteFocusPreset;
});

final saveSessionLogProvider = Provider<SaveSessionLog>((ref) {
  return ref.watch(focusDependenciesProvider).saveSessionLog;
});

final getSessionScoutRecommendationProvider =
    Provider<GetSessionScoutRecommendation>((ref) {
  return ref
      .watch(focusDependenciesProvider)
      .getSessionScoutRecommendation;
});

final focusPresetsProvider =
    FutureProvider<List<FocusPreset>>((ref) async {
  final repository = ref.watch(focusPresetRepositoryProvider);
  return repository.getAllPresets();
});

final sessionHistoryProvider =
    FutureProvider<List<SessionLog>>((ref) async {
  final repository = ref.watch(sessionLogRepositoryProvider);
  return repository.getAllSessions();
});

final sessionScoutProvider =
    FutureProvider.family<SessionScoutRecommendation, String>(
  (ref, moodTag) async {
    ref.watch(focusPresetsProvider);
    ref.watch(sessionHistoryProvider);

    final getRecommendation =
        ref.watch(getSessionScoutRecommendationProvider);

    return getRecommendation(moodTag: moodTag);
  },
);
