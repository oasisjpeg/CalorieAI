import 'package:calorieai/features/fasting_timer/domain/entity/fasting_schedule_entity.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class FastingNotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  static const String _channelId = 'fasting_timer_channel';
  static const String _channelName = 'Fasting Timer';
  static const String _channelDescription = 'Notifications for fasting timer events';

  FastingNotificationService() : _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(settings: initSettings);

    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      playSound: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  Future<void> scheduleFastingNotifications(
    FastingScheduleEntity schedule,
    String fastingStartedTitle,
    String fastingStartedBody,
    String eatingStartedTitle,
    String eatingStartedBody,
  ) async {
    await cancelAllFastingNotifications();

    if (!schedule.isActive) return;

    final now = DateTime.now();
    final fastingStart = schedule.getNextFastingStart(now);
    final eatingStart = schedule.getNextEatingStart(now);

    await _scheduleNotification(
      id: 1,
      title: fastingStartedTitle,
      body: fastingStartedBody,
      scheduledDate: fastingStart,
    );

    await _scheduleNotification(
      id: 2,
      title: eatingStartedTitle,
      body: eatingStartedBody,
      scheduledDate: eatingStart,
    );
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tzScheduledDate,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAllFastingNotifications() async {
    await _notificationsPlugin.cancel(id: 1);
    await _notificationsPlugin.cancel(id: 2);
  }

  Future<void> showImmediateNotification(String title, String body) async {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
    );
  }
}
