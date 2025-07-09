import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:teton_meal_app/app/app_theme.dart';
import 'package:teton_meal_app/data/models/reminder_model.dart';
import 'package:teton_meal_app/data/services/reminder_service.dart';
import 'package:teton_meal_app/shared/presentation/widgets/common/confirmation_delete_dialog.dart';
import 'package:teton_meal_app/features/reminders/presentation/screens/add_reminder_screen.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  final ReminderService _reminderService = ReminderService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fWhiteBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildRemindersList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: AppColors.fIconAndLabelText.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.fTextH1,
                size: 20.sp,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              'Reminders',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.fTextH1,
                fontFamily: 'Mulish',
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddReminderPage(),
                ),
              );
            },
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: AppColors.fRedBright,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.fRedBright.withOpacity(0.3),
                    blurRadius: 8.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Icon(
                Icons.add,
                color: AppColors.fWhite,
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersList() {
    return StreamBuilder<List<ReminderModel>>(
      stream: _reminderService.getUserReminders(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorWidget();
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        }

        final reminders = snapshot.data ?? [];

        if (reminders.isEmpty) {
          return _buildEmptyWidget();
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          itemCount: reminders.length,
          itemBuilder: (context, index) {
            final reminder = reminders[index];
            return _buildReminderCard(reminder);
          },
        );
      },
    );
  }

  Widget _buildReminderCard(ReminderModel reminder) {
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
      onTap: () => _editReminder(reminder),
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
              onTap: () async {
                await _reminderService.toggleReminderStatus(
                  reminder.id,
                  !reminder.isActive,
                );
              },
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
              onTap: () => _showDeleteDialog(reminder),
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

  void _editReminder(ReminderModel reminder) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddReminderPage(reminder: reminder),
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

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.fRedBright,
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading reminders...',
            style: TextStyle(
              color: AppColors.fIconAndLabelText,
              fontSize: 14.sp,
              fontFamily: 'Mulish',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(20.w),
        padding: EdgeInsets.all(24.w),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.fRedBright,
              size: 48.sp,
            ),
            SizedBox(height: 16.h),
            Text(
              'Error Loading Reminders',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.fTextH1,
                fontFamily: 'Mulish',
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Unable to load reminders. Please try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.fIconAndLabelText,
                fontFamily: 'Mulish',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(20.w),
        padding: EdgeInsets.all(24.w),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.access_time,
              color: AppColors.fIconAndLabelText,
              size: 64.sp,
            ),
            SizedBox(height: 16.h),
            Text(
              'No Reminders',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.fTextH1,
                fontFamily: 'Mulish',
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'You haven\'t set any reminders yet.\nTap the + button to add your first reminder.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.fIconAndLabelText,
                fontFamily: 'Mulish',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(ReminderModel reminder) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDeleteDialog(
          title: 'Delete Reminder',
          message: 'Are you sure you want to delete',
          itemName: reminder.name,
          onDelete: () => _deleteReminder(reminder),
        );
      },
    );
  }

  Future<void> _deleteReminder(ReminderModel reminder) async {
    try {
      await _reminderService.deleteReminder(reminder.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Reminder "${reminder.name}" deleted successfully',
              style: TextStyle(
                color: AppColors.fWhite,
                fontFamily: 'Mulish',
              ),
            ),
            backgroundColor: AppColors.fRedBright,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            margin: EdgeInsets.all(16.w),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete reminder. Please try again.',
              style: TextStyle(
                color: AppColors.fWhite,
                fontFamily: 'Mulish',
              ),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            margin: EdgeInsets.all(16.w),
          ),
        );
      }
    }
  }
}
