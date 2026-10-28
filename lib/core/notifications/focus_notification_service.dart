
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class FocusNotificationService {
  Future<void> initialize();

  Future<bool> requestPermission();

  Future<void> notifySessionCompleted({
    required String presetName,
  });
}

class LocalFocusNotificationService
    implements FocusNotificationService {
  LocalFocusNotificationService({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  static const String channelId = 'focus_sessions';
  static const String channelName = 'Focus Sessions';

  @override
  Future<void> initialize() async {
    const android = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(
      android: android,
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _plugin.initialize(settings: settings);
  }

  @override
  Future<bool> requestPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      return await android?.requestNotificationsPermission() ??
          false;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      return await ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }

    return false;
  }

  @override
  Future<void> notifySessionCompleted({
    required String presetName,
  }) async {
    final preferences = await SharedPreferences.getInstance();

    if (!(preferences.getBool('reminders_enabled') ?? false)) {
      return;
    }

    const android = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription:
          'Notifications when focus sessions are completed.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: android,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      id: 100,
      title: 'Focus session completed',
      body: 'You finished your $presetName focus session.',
      notificationDetails: details,
    );
  }
}
