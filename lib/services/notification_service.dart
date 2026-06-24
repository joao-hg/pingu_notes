import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

enum PinguNotificationType { review, reminder, memory }

// Must be top-level for the background isolate.
@pragma('vm:entry-point')
void _onBackgroundNotificationResponse(NotificationResponse response) {}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final _tapController = StreamController<int>.broadcast();

  // Emits the noteId whenever a notification is tapped (foreground or background).
  Stream<int> get notificationTaps => _tapController.stream;

  // Set by init() when the app was launched by tapping a notification.
  int? _launchNoteId;
  int? consumeLaunchNoteId() {
    final id = _launchNoteId;
    _launchNoteId = null;
    return id;
  }

  Future<void> init() async {
    // 1. Initialize timezone database and set local timezone.
    tz.initializeTimeZones();
    if (!kIsWeb) {
      try {
        final tzInfo = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
        debugPrint('[NotificationService] Timezone: ${tzInfo.identifier}');
      } catch (e) {
        debugPrint('[NotificationService] Timezone init fallback: $e');
      }
    }

    // 2. Initialize the plugin.
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings darwinSettings =
        DarwinInitializationSettings();

    final LinuxInitializationSettings linuxSettings =
        LinuxInitializationSettings(
          defaultActionName: 'Abrir nota',
          defaultIcon: AssetsLinuxIcon('assets/icon/icon.png'),
        );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
    );

    try {
      await flutterLocalNotificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
        onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationResponse,
      );
    } catch (e) {
      debugPrint('[NotificationService] Init error: $e');
    }

    // 3. Request POST_NOTIFICATIONS permission (Android 13+).
    await _requestAndroidPermission();

    // 4. Detect if this launch was triggered by tapping a notification.
    await _checkLaunchDetails();
  }

  Future<void> _requestAndroidPermission() async {
    if (kIsWeb) return;
    try {
      final androidPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
    } catch (e) {
      debugPrint('[NotificationService] Permission request error: $e');
    }
  }

  Future<void> _checkLaunchDetails() async {
    try {
      final details =
          await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
      if (details?.didNotificationLaunchApp == true) {
        final noteId = _decodeNoteId(details!.notificationResponse?.id);
        if (noteId != null) {
          _launchNoteId = noteId;
          debugPrint('[NotificationService] Launched from notification: noteId=$noteId');
        }
      }
    } catch (e) {
      debugPrint('[NotificationService] Launch details error: $e');
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    final noteId = _decodeNoteId(response.id);
    debugPrint('[NotificationService] Tapped: id=${response.id}, noteId=$noteId');
    if (noteId != null) _tapController.add(noteId);
  }

  // Notification id formula: noteId * 10 + type.index + 1
  // Minimum valid id for noteId=1: 11. So id ~/ 10 = noteId for all valid ids.
  int? _decodeNoteId(int? notificationId) {
    if (notificationId == null || notificationId < 11) return null;
    return notificationId ~/ 10;
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    PinguNotificationType type = PinguNotificationType.reminder,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) return;

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId(type),
            _channelName(type),
            channelDescription: _channelDescription(type),
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
          macOS: const DarwinNotificationDetails(),
          linux: const LinuxNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('[NotificationService] Schedule error (id=$id): $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelNoteNotifications(int noteId) async {
    for (final type in PinguNotificationType.values) {
      await cancelNotification(notificationId(noteId, type));
    }
  }

  int notificationId(int noteId, PinguNotificationType type) {
    return noteId * 10 + type.index + 1;
  }

  static String _channelId(PinguNotificationType type) {
    return switch (type) {
      PinguNotificationType.review => 'pingu_notes_review',
      PinguNotificationType.reminder => 'pingu_notes_reminders',
      PinguNotificationType.memory => 'pingu_notes_memory',
    };
  }

  static String _channelName(PinguNotificationType type) {
    return switch (type) {
      PinguNotificationType.review => 'Revisar nota',
      PinguNotificationType.reminder => 'Lembretes agendados',
      PinguNotificationType.memory => 'Não Me Deixe Esquecer',
    };
  }

  static String _channelDescription(PinguNotificationType type) {
    return switch (type) {
      PinguNotificationType.review => 'Notificações para revisar notas recentes.',
      PinguNotificationType.reminder => 'Lembretes agendados pelo usuário.',
      PinguNotificationType.memory => 'Alertas de notas que podem estar esquecidas.',
    };
  }
}
