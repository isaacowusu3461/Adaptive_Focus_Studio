
import 'focus_notification_service.dart';

class FocusNotificationController {
  const FocusNotificationController(this.service);

  final FocusNotificationService service;

  Future<void> onSessionSaved({
    required String presetName,
    required bool completedNaturally,
    required String status,
  }) async {
    if (!completedNaturally || status != 'completed') {
      return;
    }

    await service.notifySessionCompleted(
      presetName: presetName,
    );
  }
}
