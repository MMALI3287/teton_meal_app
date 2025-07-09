import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:teton_meal_app/app/app_theme.dart';
import 'package:teton_meal_app/data/models/reminder_model.dart';

class ReminderCardWidget extends StatelessWidget {
  final ReminderModel reminder;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;

  const ReminderCardWidget({
    super.key,
    required this.reminder,
    this.onTap,
    this.onToggle,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final DateFormat timeFormat = DateFormat('h:mm a');
    final DateFormat dateFormat = DateFormat('MMM dd, yyyy');

    String displayTime = timeFormat.format(reminder.dateTime);
    String displayDate = dateFormat.format(reminder.dateTime);

    if (reminder.isRepeating) {
      switch (reminder.repeatType) {
        case 'daily':
          displayDate = 'Everyday';
          break;
        case 'weekly':
          displayDate = DateFormat('EEEE').format(reminder.dateTime);
          break;
        case 'monthly':
          displayDate =
              'Every ${reminder.dateTime.day}${_getOrdinalSuffix(reminder.dateTime.day)}';
          break;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.fWhite,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
          children: [
            // Time icon
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: AppColors.fIconAndLabelText.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.access_time,
                color: AppColors.fIconAndLabelText,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 16.w),
            // Reminder info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.fTextH1,
                      fontFamily: 'Mulish',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (reminder.details != null &&
                      reminder.details!.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      reminder.details!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.fIconAndLabelText,
                        fontFamily: 'Mulish',
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Text(
                        displayTime,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.fRedBright,
                          fontFamily: 'Mulish',
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '•',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.fIconAndLabelText,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        displayDate,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.fIconAndLabelText,
                          fontFamily: 'Mulish',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            // Toggle switch
            GestureDetector(
              onTap: onToggle,
              child: Container(
                width: 48.w,
                height: 28.h,
                decoration: BoxDecoration(
                  color: reminder.isActive
                      ? AppColors.fRedBright
                      : AppColors.fIconAndLabelText.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: AnimatedAlign(
                  alignment: reminder.isActive
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: 24.w,
                    height: 24.h,
                    margin: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppColors.fWhite,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 2.r,
                          offset: Offset(0, 1.h),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            // Delete button
            GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 36.w,
                height: 36.h,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 18.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getOrdinalSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}
