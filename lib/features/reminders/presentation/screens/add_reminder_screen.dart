import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:teton_meal_app/app/app_theme.dart';
import 'package:teton_meal_app/data/services/reminder_service.dart';
import 'package:teton_meal_app/data/models/reminder_model.dart';
import 'package:teton_meal_app/features/reminders/presentation/widgets/reminder_form_widget.dart';
import 'package:teton_meal_app/shared/presentation/widgets/common/standard_back_button.dart';

class AddReminderPage extends StatefulWidget {
  final ReminderModel? reminder;

  const AddReminderPage({super.key, this.reminder});

  @override
  State<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  final ReminderService _reminderService = ReminderService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fWhiteBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ReminderFormWidget(
                initialReminder: widget.reminder,
                isLoading: _isLoading,
                onSave: _handleSave,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _isEditMode => widget.reminder != null;

  Future<void> _handleSave(String name, String? details, DateTime dateTime,
      bool isRepeating, String? repeatType) async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_isEditMode) {
        final updatedReminder = ReminderModel(
          id: widget.reminder!.id,
          name: name,
          details: details,
          dateTime: dateTime,
          isActive: widget.reminder!.isActive,
          isRepeating: isRepeating,
          repeatType: repeatType,
          userId: widget.reminder!.userId,
          createdAt: widget.reminder!.createdAt,
          updatedAt: DateTime.now(),
        );

        await _reminderService.updateReminder(updatedReminder);
      } else {
        await _reminderService.createReminder(
          name: name,
          details: details,
          dateTime: dateTime,
          isRepeating: isRepeating,
          repeatType: repeatType,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? 'Reminder updated successfully'
                  : 'Reminder created successfully',
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
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save reminder: ${e.toString()}'),
          backgroundColor: AppColors.fRedBright,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        children: [
          const StandardBackButton(),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              _isEditMode ? 'Edit Reminder' : 'Add New Reminder',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.fTextH1,
                fontFamily: 'Mulish',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
