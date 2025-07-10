import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:teton_meal_app/app/app_theme.dart';
import 'package:teton_meal_app/data/models/reminder_model.dart';

class ReminderFormWidget extends StatefulWidget {
  final ReminderModel? initialReminder;
  final Function(String name, String? details, DateTime dateTime,
      bool isRepeating, String? repeatType)? onSave;
  final bool isLoading;

  const ReminderFormWidget({
    super.key,
    this.initialReminder,
    this.onSave,
    this.isLoading = false,
  });

  @override
  State<ReminderFormWidget> createState() => _ReminderFormWidgetState();
}

class _ReminderFormWidgetState extends State<ReminderFormWidget> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isRepeating = false;
  String _repeatType = 'daily';

  final List<String> _repeatOptions = ['daily', 'weekly', 'monthly'];

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    if (widget.initialReminder != null) {
      final reminder = widget.initialReminder!;
      _nameController.text = reminder.name;
      _detailsController.text = reminder.details ?? '';
      _selectedDate = reminder.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(reminder.dateTime);
      _isRepeating = reminder.isRepeating;
      _repeatType = reminder.repeatType ?? 'daily';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.fRedBright,
              onPrimary: AppColors.fWhite,
              surface: AppColors.fWhite,
              onSurface: AppColors.fTextH1,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.fRedBright,
              onPrimary: AppColors.fWhite,
              surface: AppColors.fWhite,
              onSurface: AppColors.fTextH1,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _handleSave() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a reminder name'),
          backgroundColor: AppColors.fRedBright,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final DateTime reminderDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    widget.onSave?.call(
      _nameController.text.trim(),
      _detailsController.text.trim().isEmpty
          ? null
          : _detailsController.text.trim(),
      reminderDateTime,
      _isRepeating,
      _isRepeating ? _repeatType : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),
          _buildNameField(),
          SizedBox(height: 24.h),
          _buildDetailsField(),
          SizedBox(height: 24.h),
          _buildTimeSection(),
          SizedBox(height: 32.h),
          _buildSetButton(),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Label Name',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.fTextH1,
            fontFamily: 'Mulish',
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            color: AppColors.fWhite,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.fIconAndLabelText.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Reminder Name',
              hintStyle: TextStyle(
                color: AppColors.fIconAndLabelText,
                fontSize: 14.sp,
                fontFamily: 'Mulish',
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
            ),
            style: TextStyle(
              color: AppColors.fTextH1,
              fontSize: 14.sp,
              fontFamily: 'Mulish',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Details (Optional)',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.fTextH1,
            fontFamily: 'Mulish',
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            color: AppColors.fWhite,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.fIconAndLabelText.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: TextField(
            controller: _detailsController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Add additional details...',
              hintStyle: TextStyle(
                color: AppColors.fIconAndLabelText,
                fontSize: 14.sp,
                fontFamily: 'Mulish',
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
            ),
            style: TextStyle(
              color: AppColors.fTextH1,
              fontSize: 14.sp,
              fontFamily: 'Mulish',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time & Date',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.fTextH1,
            fontFamily: 'Mulish',
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.fWhite,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.fIconAndLabelText.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Repeat',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.fTextH1,
                      fontFamily: 'Mulish',
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isRepeating = !_isRepeating;
                      });
                    },
                    child: Container(
                      width: 48.w,
                      height: 28.h,
                      decoration: BoxDecoration(
                        color: _isRepeating
                            ? AppColors.fTextH1
                            : AppColors.fIconAndLabelText
                                .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: AnimatedAlign(
                        alignment: _isRepeating
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
                                color: AppColors.fTextH1.withValues(alpha: 0.1),
                                blurRadius: 2.r,
                                offset: Offset(0, 1.h),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              if (_isRepeating) ...[
                _buildRepeatDropdown(),
                SizedBox(height: 16.h),
              ],
              _buildDateTimeRow(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRepeatDropdown() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.fWhite,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.fIconAndLabelText.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _repeatType,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.fIconAndLabelText,
            size: 20.sp,
          ),
          style: TextStyle(
            color: AppColors.fTextH1,
            fontSize: 14.sp,
            fontFamily: 'Mulish',
          ),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _repeatType = newValue;
              });
            }
          },
          items: _repeatOptions.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value.substring(0, 1).toUpperCase() + value.substring(1),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDateTimeRow() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _selectDate,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
              decoration: BoxDecoration(
                color: AppColors.fWhiteBackground,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: AppColors.fIconAndLabelText.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.fIconAndLabelText,
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    DateFormat('MMM dd, yyyy').format(_selectedDate),
                    style: TextStyle(
                      color: AppColors.fTextH1,
                      fontSize: 14.sp,
                      fontFamily: 'Mulish',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: GestureDetector(
            onTap: _selectTime,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
              decoration: BoxDecoration(
                color: AppColors.fWhiteBackground,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: AppColors.fIconAndLabelText.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: AppColors.fIconAndLabelText,
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    _selectedTime.format(context),
                    style: TextStyle(
                      color: AppColors.fTextH1,
                      fontSize: 14.sp,
                      fontFamily: 'Mulish',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSetButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.isLoading ? null : _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.fRedBright,
          foregroundColor: AppColors.fWhite,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
        child: widget.isLoading
            ? SizedBox(
                height: 20.h,
                width: 20.w,
                child: CircularProgressIndicator(
                  color: AppColors.fWhite,
                  strokeWidth: 2,
                ),
              )
            : Text(
                widget.initialReminder != null
                    ? 'Update Reminder'
                    : 'Set Reminder',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Mulish',
                ),
              ),
      ),
    );
  }
}
