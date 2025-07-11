import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:teton_meal_app/app/app_theme.dart';
import 'package:teton_meal_app/features/menu_management/presentation/widgets/menu_poll_card_widget.dart';
import 'package:teton_meal_app/shared/presentation/widgets/common/standard_back_button.dart';

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

    final today = DateTime.now();
    selectedDate = DateTime(today.year, today.month, today.day);
    _filterPollsByDate(selectedDate!);
  }

  void _previousMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
      selectedDate = null;
      filteredPolls = [];
    });
  }

  void _nextMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
      selectedDate = null;
      filteredPolls = [];
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      if (selectedDate != null &&
          selectedDate!.year == date.year &&
          selectedDate!.month == date.month &&
          selectedDate!.day == date.day) {
        selectedDate = null;
        filteredPolls = [];
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
      } catch (e) {}
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

    final firstWeekday = firstDay.weekday % 7;
    for (int i = 0; i < firstWeekday; i++) {
      days.add(DateTime(0));
    }

    for (int day = 1; day <= lastDay.day; day++) {
      days.add(DateTime(month.year, month.month, day));
    }

    return days;
  }

  bool _hasOrdersOnDate(DateTime date) {
    if (date.year == 0) return false;

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
      } catch (e) {}
      return false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fWhiteBackground,
      appBar: AppBar(
        backgroundColor: AppColors.fWhiteBackground,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const StandardBackButton(),
            SizedBox(width: 16.w),
            Text(
              'History',
              style: TextStyle(
                color: AppColors.fTextH1,
                fontSize: 20.sp,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w600,
                letterSpacing: -0.02,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.fWhite,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: const Color(0xFFEEEEEE),
                width: 1,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: _previousMonth,
                        child: Container(
                          width: 40.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: AppColors.fWhite,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: const Color(0xFFEEEEEE),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            color: const Color(0xFF666666),
                            size: 16.sp,
                          ),
                        ),
                      ),
                      Text(
                        '${_getMonthName(currentMonth.month)} ${currentMonth.year}',
                        style: TextStyle(
                          color: const Color(0xFF1A1A1A),
                          fontSize: 18.sp,
                          fontFamily: 'DM Sans',
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.02,
                        ),
                      ),
                      GestureDetector(
                        onTap: _nextMonth,
                        child: Container(
                          width: 40.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: AppColors.fWhite,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: const Color(0xFFEEEEEE),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: const Color(0xFF666666),
                            size: 16.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                        .map((day) => Expanded(
                              child: Container(
                                height: 36.h,
                                alignment: Alignment.center,
                                child: Text(
                                  day,
                                  style: TextStyle(
                                    color: const Color(0xFF999999),
                                    fontSize: 14.sp,
                                    fontFamily: 'DM Sans',
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: -0.02,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  SizedBox(height: 8.h),
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
                          children: List.generate(7, (dayIndex) {
                            if (dayIndex < weekDays.length) {
                              final date = weekDays[dayIndex];
                              if (date.year == 0) {
                                return Expanded(
                                  child: Container(
                                    height: 36.h,
                                    alignment: Alignment.center,
                                  ),
                                );
                              }

                              final hasOrders = _hasOrdersOnDate(date);
                              final isSelected = selectedDate != null &&
                                  selectedDate!.year == date.year &&
                                  selectedDate!.month == date.month &&
                                  selectedDate!.day == date.day;

                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => _selectDate(date),
                                  child: Container(
                                    height: 36.h,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 2.w),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.fRedBright
                                          : hasOrders
                                              ? AppColors.fRedBright
                                                  .withValues(alpha: 0.1)
                                              : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${date.day}',
                                      style: TextStyle(
                                        color: isSelected
                                            ? AppColors.fWhite
                                            : hasOrders
                                                ? AppColors.fRedBright
                                                : const Color(0xFF1A1A1A),
                                        fontSize: 14.sp,
                                        fontFamily: 'DM Sans',
                                        fontWeight: hasOrders || isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        letterSpacing: -0.02,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Expanded(
                                child: Container(
                                  height: 36.h,
                                ),
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
          ),
          Expanded(
            child: filteredPolls.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          selectedDate != null
                              ? Icons.event_busy_outlined
                              : Icons.history_outlined,
                          size: 64.sp,
                          color: const Color(0xFF999999),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          selectedDate != null
                              ? 'No orders on this date'
                              : 'Select a date to view orders',
                          style: TextStyle(
                            color: const Color(0xFF1A1A1A),
                            fontSize: 18.sp,
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.02,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          selectedDate != null
                              ? 'Tap the date again to clear selection'
                              : 'Tap on a date to filter orders',
                          style: TextStyle(
                            color: const Color(0xFF666666),
                            fontSize: 14.sp,
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.02,
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
