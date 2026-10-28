
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/study_statistics_service.dart';
import '../../domain/entities/study_statistics.dart';
import 'focus_providers.dart';

final studyStatisticsServiceProvider =
    Provider<StudyStatisticsService>((ref) {
  return StudyStatisticsService();
});

final studyStatisticsProvider =
    FutureProvider<StudyStatistics>((ref) async {
  final sessions = await ref.watch(
    sessionHistoryProvider.future,
  );

  final service = ref.watch(
    studyStatisticsServiceProvider,
  );

  return service.calculate(sessions);
});
