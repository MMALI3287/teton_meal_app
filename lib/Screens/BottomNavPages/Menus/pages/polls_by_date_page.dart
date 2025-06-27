import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:teton_meal_app/Styles/colors.dart';
import '../components/menu_poll_card.dart';

class PollsByDatePage extends StatefulWidget {
  final List<QueryDocumentSnapshot> polls;

  const PollsByDatePage({super.key, required this.polls});

  @override
  State<PollsByDatePage> createState() => _PollsByDatePageState();
}

class _PollsByDatePageState extends State<PollsByDatePage> {
  DateTime currentMonth = DateTime.now();
  DateTime? selectedDate;
  List<QueryDocumentSnapshot> filteredPolls = [];

  @override
  void initState() {
    super.initState();
    // Set today's date as selected by default
    final today = DateTime.now();
    selectedDate = DateTime(today.year, today.month, today.day);
    _filterPollsByDate(selectedDate!);
  }

  void _previousMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
      selectedDate = null;
      filteredPolls = []; // Clear polls when changing month
    });
  }

  void _nextMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
      selectedDate = null;
      filteredPolls = []; // Clear polls when changing month
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      // If the same date is selected again, deselect it and clear the list
      if (selectedDate != null &&
          selectedDate!.year == date.year &&
          selectedDate!.month == date.month &&
          selectedDate!.day == date.day) {
        selectedDate = null;
        filteredPolls = []; // Clear list when deselecting
      } else {
        selectedDate = date;
        _filterPollsByDate(date);
      }
    });
  }

  void _filterPollsByDate(DateTime date) {
    filteredPolls = widget.polls.where((poll) {
      final pollData = poll.data() as Map<String, dynamic>;
      final pollDateString = pollData['date'] ?? '';

      try {
        // Parse the date string (assuming format: dd/mm/yyyy)
        final parts = pollDateString.split('/');
        if (parts.length == 3) {
          final pollDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
          return pollDate.year == date.year &&
              pollDate.month == date.month &&
              pollDate.day == date.day;
        }
      } catch (e) {
        // If parsing fails, don't include this poll
      }
      return false;
    }).toList();
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    final List<DateTime> days = [];

    // Add empty cells for days before the first day of the month
    final firstWeekday = firstDay.weekday % 7; // Convert to 0-6 (Mon-Sun)
    for (int i = 0; i < firstWeekday; i++) {
      days.add(DateTime(0)); // Placeholder for empty cells
    }

    // Add all days of the month
    for (int day = 1; day <= lastDay.day; day++) {
      days.add(DateTime(month.year, month.month, day));
    }

    return days;
  }

  bool _hasOrdersOnDate(DateTime date) {
    if (date.year == 0) return false; // Empty cell

    return widget.polls.any((poll) {
      final pollData = poll.data() as Map<String, dynamic>;
      final pollDateString = pollData['date'] ?? '';

      try {
        final parts = pollDateString.split('/');
        if (parts.length == 3) {
          final pollDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
          return pollDate.year == date.year &&
              pollDate.month == date.month &&
              pollDate.day == date.day;
        }
      } catch (e) {
        // If parsing fails, return false
      }
      return false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            // Custom back button with dark background
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 36.w,
                height: 36.h,
                decoration: BoxDecoration(
                  color: AppColors.primaryText,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.white,
                  size: 18.sp,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            // History title
            Text(
              'History',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 18.sp,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Calendar section
          Container(
            margin: EdgeInsets.all(16.w),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 4.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: Column(
              children: [
                // Month navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _previousMonth,
                      icon: Icon(
                        Icons.chevron_left,
                        color: AppColors.primaryText,
                        size: 24.sp,
                      ),
                    ),
                    Text(
                      '${_getMonthName(currentMonth.month)} ${currentMonth.year}',
                      style: TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 16.sp,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: _nextMonth,
                      icon: Icon(
                        Icons.chevron_right,
                        color: AppColors.primaryText,
                        size: 24.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                // Weekday headers
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                      .map((day) => Container(
                            width: 32.w,
                            alignment: Alignment.center,
                            child: Text(
                              day,
                              style: TextStyle(
                                color: AppColors.tertiaryText,
                                fontSize: 12.sp,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ))
                      .toList(),
                ),
                SizedBox(height: 8.h),
                // Calendar grid
                ...List.generate(
                  (_getDaysInMonth(currentMonth).length / 7).ceil(),
                  (weekIndex) {
                    final weekStart = weekIndex * 7;
                    final weekEnd = (weekStart + 7)
                        .clamp(0, _getDaysInMonth(currentMonth).length);
                    final weekDays = _getDaysInMonth(currentMonth)
                        .sublist(weekStart, weekEnd);

                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(7, (dayIndex) {
                          if (dayIndex < weekDays.length) {
                            final date = weekDays[dayIndex];
                            if (date.year == 0) {
                              // Empty cell
                              return Container(
                                width: 32.w,
                                height: 32.h,
                              );
                            }

                            final hasOrders = _hasOrdersOnDate(date);
                            final isSelected = selectedDate != null &&
                                selectedDate!.year == date.year &&
                                selectedDate!.month == date.month &&
                                selectedDate!.day == date.day;

                            return GestureDetector(
                              onTap: () => _selectDate(date),
                              child: Container(
                                width: 32.w,
                                height: 32.h,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryColor
                                      : hasOrders
                                          ? AppColors.primaryColor
                                              .withOpacity(0.1)
                                          : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${date.day}',
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.white
                                        : hasOrders
                                            ? AppColors.primaryColor
                                            : AppColors.tertiaryText,
                                    fontSize: 14.sp,
                                    fontFamily: 'Inter',
                                    fontWeight: hasOrders
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return Container(
                              width: 32.w,
                              height: 32.h,
                            );
                          }
                        }),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Orders list
          Expanded(
            child: filteredPolls.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          selectedDate != null
                              ? Icons.event_busy
                              : Icons.history,
                          size: 64.sp,
                          color: AppColors.tertiaryText,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          selectedDate != null
                              ? 'No orders on this date'
                              : 'Select a date to view orders',
                          style: TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 16.sp,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          selectedDate != null
                              ? 'Tap the date again to clear selection'
                              : 'Tap on a date to filter orders',
                          style: TextStyle(
                            color: AppColors.tertiaryText,
                            fontSize: 14.sp,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: ListView.builder(
                      itemCount: filteredPolls.length,
                      itemBuilder: (context, index) {
                        return MenuPollCard(pollData: filteredPolls[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
