import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/reminder_model.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';

class ReminderService {
  static final ReminderService _instance = ReminderService._internal();
  factory ReminderService() => _instance;
  ReminderService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();
  final Uuid _uuid = const Uuid();

  String get _currentUserId => AuthService().currentUser?.uid ?? '';

  CollectionReference get _remindersCollection =>
      _firestore.collection('reminders');

  Future<String> createReminder({
    required String name,
    String? details,
    required DateTime dateTime,
    required bool isRepeating,
    String? repeatType,
  }) async {
    final String reminderId = _uuid.v4();
    final now = DateTime.now();

    final reminder = ReminderModel(
      id: reminderId,
      name: name,
      details: details,
      dateTime: dateTime,
      isActive: true,
      isRepeating: isRepeating,
      repeatType: repeatType,
      userId: _currentUserId,
      createdAt: now,
      updatedAt: now,
    );

    await _remindersCollection.doc(reminderId).set(reminder.toMap());

    // Schedule notification
    await _notificationService.scheduleReminder(reminder);

    return reminderId;
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    final updatedReminder = reminder.copyWith(updatedAt: DateTime.now());

    await _remindersCollection.doc(reminder.id).update(updatedReminder.toMap());

    // Update notification
    if (updatedReminder.isActive) {
      await _notificationService.scheduleReminder(updatedReminder);
    } else {
      await _notificationService.cancelReminder(updatedReminder.id);
    }
  }

  Future<void> toggleReminderStatus(String reminderId, bool isActive) async {
    await _remindersCollection.doc(reminderId).update({
      'isActive': isActive,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });

    if (isActive) {
      final reminderDoc = await _remindersCollection.doc(reminderId).get();
      if (reminderDoc.exists) {
        final reminder = ReminderModel.fromMap(
          reminderDoc.data() as Map<String, dynamic>,
        );
        await _notificationService.scheduleReminder(reminder);
      }
    } else {
      await _notificationService.cancelReminder(reminderId);
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    await _remindersCollection.doc(reminderId).delete();
    await _notificationService.cancelReminder(reminderId);
  }

  Stream<List<ReminderModel>> getUserReminders() {
    return _remindersCollection
        .where('userId', isEqualTo: _currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ReminderModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<ReminderModel?> getReminderById(String reminderId) async {
    final doc = await _remindersCollection.doc(reminderId).get();

    if (doc.exists) {
      return ReminderModel.fromMap(doc.data() as Map<String, dynamic>);
    }

    return null;
  }

  Future<void> rescheduleAllActiveReminders() async {
    final reminders = await _remindersCollection
        .where('userId', isEqualTo: _currentUserId)
        .where('isActive', isEqualTo: true)
        .get();

    for (final doc in reminders.docs) {
      final reminder =
          ReminderModel.fromMap(doc.data() as Map<String, dynamic>);
      await _notificationService.scheduleReminder(reminder);
    }
  }

  Future<void> cleanupExpiredReminders() async {
    final now = DateTime.now();
    final expiredReminders = await _remindersCollection
        .where('userId', isEqualTo: _currentUserId)
        .where('isRepeating', isEqualTo: false)
        .where('dateTime', isLessThan: Timestamp.fromDate(now))
        .get();

    for (final doc in expiredReminders.docs) {
      final reminder =
          ReminderModel.fromMap(doc.data() as Map<String, dynamic>);
      if (!reminder.isRepeating && reminder.dateTime.isBefore(now)) {
        await toggleReminderStatus(reminder.id, false);
      }
    }
  }
}
