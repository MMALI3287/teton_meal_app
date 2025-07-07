import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/reminder_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap
        if (kDebugMode) {
          print('Notification tapped: ${response.payload}');
        }
      },
    );
  }

  Future<bool> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      final bool? granted =
          await androidImplementation.requestNotificationsPermission();
      return granted ?? false;
    }

    return true; // iOS permissions are requested during initialization
  }

  Future<void> scheduleReminder(ReminderModel reminder) async {
    final int notificationId = reminder.id.hashCode;

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      channelDescription: 'Meal app reminders and alarms',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      categoryIdentifier: 'reminder_category',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    // Cancel existing notification
    await _flutterLocalNotificationsPlugin.cancel(notificationId);

    if (!reminder.isActive) return;

    final DateTime scheduledDate = reminder.isRepeating
        ? (reminder.getNextOccurrence() ?? reminder.dateTime)
        : reminder.dateTime;

    if (scheduledDate.isBefore(DateTime.now())) return;

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      reminder.name,
      reminder.details ?? 'Teton Meal App Reminder',
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      payload: reminder.id,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: reminder.isRepeating
          ? _getMatchDateTimeComponents(reminder.repeatType)
          : null,
    );

    if (kDebugMode) {
      print('Scheduled reminder: ${reminder.name} for ${scheduledDate}');
    }
  }

  DateTimeComponents? _getMatchDateTimeComponents(String? repeatType) {
    switch (repeatType) {
      case 'daily':
        return DateTimeComponents.time;
      case 'weekly':
        return DateTimeComponents.dayOfWeekAndTime;
      case 'monthly':
        return DateTimeComponents.dayOfMonthAndTime;
      default:
        return null;
    }
  }

  Future<void> cancelReminder(String reminderId) async {
    final int notificationId = reminderId.hashCode;
    await _flutterLocalNotificationsPlugin.cancel(notificationId);

    if (kDebugMode) {
      print('Cancelled reminder: $reminderId');
    }
  }

  Future<void> cancelAllReminders() async {
    await _flutterLocalNotificationsPlugin.cancelAll();

    if (kDebugMode) {
      print('Cancelled all reminders');
    }
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }
}
