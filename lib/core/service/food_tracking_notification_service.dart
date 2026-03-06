import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:calorieai/core/data/repository/config_repository.dart';

class FoodTrackingNotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  final ConfigRepository _configRepository;

  static const String _channelId = 'food_tracking_channel';
  static const String _channelName = 'Food Tracking Reminders';
  static const String _channelDescription = 'Reminders to track your meals throughout the day';

  // Fixed notification times (hour, minute)
  static const List<Map<String, int>> _notificationSchedule = [
    {'hour': 8, 'minute': 0},   // Morning - Breakfast reminder
    {'hour': 12, 'minute': 30}, // Lunch time
    {'hour': 18, 'minute': 30}, // Dinner time
    {'hour': 21, 'minute': 0},  // Evening - Log any missed entries
  ];

  static const int _notificationIdBase = 100;

  FoodTrackingNotificationService(this._configRepository)
      : _notificationsPlugin = FlutterLocalNotificationsPlugin();

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
      importance: Importance.defaultImportance,
      playSound: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // Check if notifications are enabled and schedule if so
    await checkAndScheduleNotifications();
  }

  Future<bool> areNotificationsEnabled() async {
    return await _configRepository.getFoodTrackingNotificationsEnabled();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _configRepository.setFoodTrackingNotificationsEnabled(enabled);
    if (enabled) {
      await scheduleDailyNotifications();
    } else {
      await cancelAllNotifications();
    }
  }

  Future<void> checkAndScheduleNotifications() async {
    final enabled = await areNotificationsEnabled();
    if (enabled) {
      await scheduleDailyNotifications();
    }
  }

  Future<void> scheduleDailyNotifications() async {
    await cancelAllNotifications();

    final enabled = await areNotificationsEnabled();
    if (!enabled) return;

    for (int i = 0; i < _notificationSchedule.length; i++) {
      final time = _notificationSchedule[i];
      await _scheduleDailyNotification(
        id: _notificationIdBase + i,
        hour: time['hour']!,
        minute: time['minute']!,
        title: _getNotificationTitle(i),
        body: _getNotificationBody(i),
      );
    }
  }

  Future<void> _scheduleDailyNotification({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

    // If the time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
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

  String _getNotificationTitle(int index) {
    switch (index) {
      case 0:
        return 'Good Morning! 🌅';
      case 1:
        return 'Lunch Time! 🍽️';
      case 2:
        return 'Dinner Reminder 🍲';
      case 3:
        return 'Evening Check-in 🌙';
      default:
        return 'Track Your Food';
    }
  }

  String _getNotificationBody(int index) {
    switch (index) {
      case 0:
        return 'Start your day right! Log your breakfast to stay on track with your goals.';
      case 1:
        return 'Don\'t forget to track your lunch. What are you having today?';
      case 2:
        return 'Time for dinner! Log your meal and keep your nutrition on point.';
      case 3:
        return 'Quick check - have you logged all your meals for today? Stay consistent!';
      default:
        return 'Remember to track your food intake!';
    }
  }

  Future<void> cancelAllNotifications() async {
    for (int i = 0; i < _notificationSchedule.length; i++) {
      await _notificationsPlugin.cancel(id: _notificationIdBase + i);
    }
  }
}
