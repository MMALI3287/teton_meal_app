import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderModel {
  final String id;
  final String name;
  final String? details;
  final DateTime dateTime;
  final bool isActive;
  final bool isRepeating;
  final String? repeatType;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReminderModel({
    required this.id,
    required this.name,
    this.details,
    required this.dateTime,
    required this.isActive,
    required this.isRepeating,
    this.repeatType,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'details': details,
      'dateTime': Timestamp.fromDate(dateTime),
      'isActive': isActive,
      'isRepeating': isRepeating,
      'repeatType': repeatType,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      details: map['details'],
      dateTime: (map['dateTime'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? false,
      isRepeating: map['isRepeating'] ?? false,
      repeatType: map['repeatType'],
      userId: map['userId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  ReminderModel copyWith({
    String? id,
    String? name,
    String? details,
    DateTime? dateTime,
    bool? isActive,
    bool? isRepeating,
    String? repeatType,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      details: details ?? this.details,
      dateTime: dateTime ?? this.dateTime,
      isActive: isActive ?? this.isActive,
      isRepeating: isRepeating ?? this.isRepeating,
      repeatType: repeatType ?? this.repeatType,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  DateTime? getNextOccurrence() {
    if (!isRepeating || repeatType == null) return null;

    final now = DateTime.now();
    if (dateTime.isAfter(now)) return dateTime;

    switch (repeatType) {
      case 'daily':
        var nextDate = DateTime(
            now.year, now.month, now.day, dateTime.hour, dateTime.minute);
        if (nextDate.isBefore(now)) {
          nextDate = nextDate.add(const Duration(days: 1));
        }
        return nextDate;
      case 'weekly':
        var nextDate = DateTime(
            now.year, now.month, now.day, dateTime.hour, dateTime.minute);
        final daysDifference = dateTime.weekday - now.weekday;
        if (daysDifference > 0) {
          nextDate = nextDate.add(Duration(days: daysDifference));
        } else if (daysDifference < 0) {
          nextDate = nextDate.add(Duration(days: 7 + daysDifference));
        } else if (nextDate.isBefore(now)) {
          nextDate = nextDate.add(const Duration(days: 7));
        }
        return nextDate;
      case 'monthly':
        var nextDate = DateTime(
            now.year, now.month, dateTime.day, dateTime.hour, dateTime.minute);
        if (nextDate.isBefore(now)) {
          if (now.month == 12) {
            nextDate = DateTime(
                now.year + 1, 1, dateTime.day, dateTime.hour, dateTime.minute);
          } else {
            nextDate = DateTime(now.year, now.month + 1, dateTime.day,
                dateTime.hour, dateTime.minute);
          }
        }
        return nextDate;
      default:
        return null;
    }
  }
}
