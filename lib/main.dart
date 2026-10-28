import 'package:flutter/material.dart';
import 'package:adaptive_focus_studio/app.dart';

import 'core/notifications/focus_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await LocalFocusNotificationService().initialize();
  } catch (error) {
    debugPrint('Notification initialization failed: $error');
  }

  runApp(const AdaptiveFocusStudioApp());
}
