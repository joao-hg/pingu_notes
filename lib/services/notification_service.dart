import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

enum PinguNotificationType { review, reminder, memory }

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    final LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(
          defaultActionName: 'Open notification',
          defaultIcon: AssetsLinuxIcon('assets/icon/icon.png'),
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
          macOS: initializationSettingsDarwin,
          linux: initializationSettingsLinux,
        );

    try {
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    } catch (e) {
      debugPrint('Erro ao inicializar notificações: $e');
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    PinguNotificationType type = PinguNotificationType.reminder,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) return;

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
      PinguNotificationType.review =>
        'Notificações para revisar notas recentes.',
      PinguNotificationType.reminder => 'Lembretes agendados pelo usuário.',
      PinguNotificationType.memory =>
        'Alertas de notas que podem estar esquecidas.',
    };
  }
}
