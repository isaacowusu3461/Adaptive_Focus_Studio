
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/focus_backup_service.dart';
import 'focus_providers.dart';

final focusBackupServiceProvider =
    Provider<FocusBackupService>((ref) {
  final dependencies = ref.watch(focusDependenciesProvider);

  return FocusBackupService(
    databaseHelper: dependencies.databaseHelper,
  );
});
