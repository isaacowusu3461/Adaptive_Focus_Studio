
import 'package:flutter_test/flutter_test.dart';

import 'package:adaptive_focus_studio/core/notifications/focus_notification_controller.dart';
import 'package:adaptive_focus_studio/core/notifications/focus_notification_service.dart';

class FakeFocusNotificationService
    implements FocusNotificationService {
  int notificationCount = 0;
  String? lastPresetName;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> notifySessionCompleted({
    required String presetName,
  }) async {
    notificationCount++;
    lastPresetName = presetName;
  }
}

void main() {
  late FakeFocusNotificationService service;
  late FocusNotificationController controller;

  setUp(() {
    service = FakeFocusNotificationService();
    controller = FocusNotificationController(service);
  });

  test('notifies after natural completion', () async {
    await controller.onSessionSaved(
      presetName: 'Morning Study',
      completedNaturally: true,
      status: 'completed',
    );

    expect(service.notificationCount, 1);
    expect(service.lastPresetName, 'Morning Study');
  });

  test('does not notify after finishing early', () async {
    await controller.onSessionSaved(
      presetName: 'Morning Study',
      completedNaturally: false,
      status: 'partial',
    );

    expect(service.notificationCount, 0);
  });

  test('does not notify after manual completion', () async {
    await controller.onSessionSaved(
      presetName: 'Morning Study',
      completedNaturally: false,
      status: 'completed',
    );

    expect(service.notificationCount, 0);
  });

  test('does not notify for partial status', () async {
    await controller.onSessionSaved(
      presetName: 'Morning Study',
      completedNaturally: true,
      status: 'partial',
    );

    expect(service.notificationCount, 0);
  });

  test('passes preset name to notification service', () async {
    await controller.onSessionSaved(
      presetName: 'Algorithms Practice',
      completedNaturally: true,
      status: 'completed',
    );

    expect(
      service.lastPresetName,
      'Algorithms Practice',
    );
  });
}
