import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:teton_meal_app/data/models/reminder_model.dart';
import 'package:teton_meal_app/data/services/reminder_service.dart';

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
        // Handle notification tap and mark reminder as triggered if it's a one-time reminder
        if (kDebugMode) {
          print('Notification tapped: ${response.payload}');
        }

        // If the notification has a payload (reminder ID), mark it as triggered
        if (response.payload != null) {
          final reminderService = ReminderService();
          await reminderService.markReminderAsTriggered(response.payload!);
        }
      },
      onDidReceiveBackgroundNotificationResponse:
          _backgroundNotificationResponseHandler,
    );

    // Create notification channel for Android
    await _createNotificationChannel();
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
      enableVibration: true,
      playSound: true,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      categoryIdentifier: 'reminder_category',
      interruptionLevel: InterruptionLevel.critical,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    // Cancel existing notification
    await _flutterLocalNotificationsPlugin.cancel(notificationId);

    if (!reminder.isActive) {
      return;
    }

    final DateTime scheduledDate = reminder.isRepeating
        ? (reminder.getNextOccurrence() ?? reminder.dateTime)
        : reminder.dateTime;

    if (scheduledDate.isBefore(DateTime.now())) {
      return;
    }

    final tz.TZDateTime tzScheduledDate =
        tz.TZDateTime.from(scheduledDate, tz.local);

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        reminder.name,
        reminder.details ?? 'Teton Meal App Reminder',
        tzScheduledDate,
        notificationDetails,
        payload: reminder.id,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: reminder.isRepeating
            ? _getMatchDateTimeComponents(reminder.repeatType)
            : null,
      );

      if (kDebugMode) {
        print('Scheduled reminder: ${reminder.name} for $scheduledDate');
      }

      // For non-repeating reminders, schedule a cleanup notification a few minutes later
      // This ensures the reminder gets disabled even if the user doesn't interact with the notification
      if (!reminder.isRepeating) {
        await _scheduleCleanupNotification(reminder.id, scheduledDate);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error scheduling reminder: $e');
      }
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
    final int cleanupNotificationId = '${reminderId}_cleanup'.hashCode;

    // Cancel both the main reminder and its cleanup notification
    await _flutterLocalNotificationsPlugin.cancel(notificationId);
    await _flutterLocalNotificationsPlugin.cancel(cleanupNotificationId);

    if (kDebugMode) {
      print('Cancelled reminder and cleanup: $reminderId');
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

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel reminderChannel =
        AndroidNotificationChannel(
      'reminder_channel',
      'Reminders',
      description: 'Meal app reminders and alarms',
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
      showBadge: true,
    );

    const AndroidNotificationChannel cleanupChannel =
        AndroidNotificationChannel(
      'cleanup_channel',
      'Cleanup',
      description: 'Silent cleanup notifications',
      importance: Importance.min,
      enableVibration: false,
      playSound: false,
      showBadge: false,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(reminderChannel);
      await androidPlugin.createNotificationChannel(cleanupChannel);
    }
  }

  Future<bool> checkExactAlarmPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      final bool? hasPermission =
          await androidImplementation.canScheduleExactNotifications();
      return hasPermission ?? false;
    }

    return true; // Assume permission granted on other platforms
  }

  Future<void> requestExactAlarmPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestExactAlarmsPermission();
    }
  }

  // Background notification response handler (static method required)
  static void _backgroundNotificationResponseHandler(
      NotificationResponse response) {
    // Handle background notification response
    if (kDebugMode) {
      print('Background notification received: ${response.payload}');
    }

    // For background handling, we need to mark the reminder as triggered
    // This runs in the background so we need to be careful with async operations
    if (response.payload != null) {
      _handleBackgroundReminderTrigger(response.payload!);
    }
  }

  static void _handleBackgroundReminderTrigger(String reminderId) async {
    try {
      final reminderService = ReminderService();
      await reminderService.markReminderAsTriggered(reminderId);
      if (kDebugMode) {
        print('Background reminder marked as triggered: $reminderId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error marking background reminder as triggered: $e');
      }
    }
  }

  Future<void> _scheduleCleanupNotification(
      String reminderId, DateTime originalScheduledDate) async {
    // Schedule a silent cleanup notification 2 minutes after the original reminder
    // This ensures non-repeating reminders get disabled even if user doesn't interact
    final cleanupDate = originalScheduledDate.add(const Duration(minutes: 2));
    final cleanupNotificationId = '${reminderId}_cleanup'.hashCode;

    // Only schedule if the cleanup date is in the future
    if (cleanupDate.isBefore(DateTime.now())) {
      return;
    }

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'cleanup_channel',
      'Cleanup',
      channelDescription: 'Silent cleanup notifications',
      importance: Importance.min,
      priority: Priority.min,
      showWhen: false,
      enableVibration: false,
      playSound: false,
      silent: true,
      ongoing: false,
      autoCancel: true,
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    final tz.TZDateTime tzCleanupDate =
        tz.TZDateTime.from(cleanupDate, tz.local);

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        cleanupNotificationId,
        '', // Empty title for silent notification
        '', // Empty body for silent notification
        tzCleanupDate,
        notificationDetails,
        payload: reminderId, // Use the original reminder ID as payload
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      if (kDebugMode) {
        print(
            'Scheduled cleanup notification for reminder: $reminderId at $cleanupDate');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error scheduling cleanup notification: $e');
      }
    }
  }
}
