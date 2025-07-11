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

  final List<int> _selectedWeekdays = [];

  int _selectedDay = 1;

  final List<String> _repeatOptions = ['daily', 'weekly', 'monthly'];

  final List<String> _weekdayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

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

      if (_isRepeating) {
        if (_repeatType == 'weekly') {
          final weekday = reminder.dateTime.weekday;
          _selectedWeekdays.clear();
          _selectedWeekdays.add(weekday);
        } else if (_repeatType == 'monthly') {
          _selectedDay = reminder.dateTime.day;
        }
      }
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
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppColors.fRedBright,
                onPrimary: AppColors.fWhite,
                surface: AppColors.fWhite,
                onSurface: AppColors.fTextH1,
              ),
            ),
            child: child!,
          ),
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

    if (_isRepeating && _repeatType == 'weekly' && _selectedWeekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one day for weekly reminders'),
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
            maxLines: 2,
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
                vertical: 12.h,
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
                _buildRepeatField(),
                SizedBox(height: 16.h),
                if (_repeatType == 'weekly') ...[
                  _buildWeekdaySelector(),
                  SizedBox(height: 16.h),
                  _buildTimeRow(),
                  SizedBox(height: 16.h),
                ] else if (_repeatType == 'monthly') ...[
                  _buildMonthlySelectors(),
                  SizedBox(height: 16.h),
                ],
              ],
              if (!_isRepeating) _buildDateTimeRow(),
              if (_isRepeating && _repeatType == 'daily') _buildTimeRow(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRepeatField() {
    return GestureDetector(
      onTap: () => _showRepeatPicker(context),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.fWhite,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.fIconAndLabelText.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _repeatType.substring(0, 1).toUpperCase() +
                  _repeatType.substring(1),
              style: TextStyle(
                color: AppColors.fTextH1,
                fontSize: 14.sp,
                fontFamily: 'Mulish',
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.fIconAndLabelText,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  void _showRepeatPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.fWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Repeat Option',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Mulish',
                    color: AppColors.fTextH1,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              ..._repeatOptions.map((option) => ListTile(
                    title: Text(
                      option.substring(0, 1).toUpperCase() +
                          option.substring(1),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontFamily: 'Mulish',
                        color: AppColors.fTextH1,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _repeatType = option;

                        _selectedWeekdays.clear();
                        _selectedDay = 1;
                      });
                      Navigator.pop(context);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeekdaySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Days',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.fTextH1,
            fontFamily: 'Mulish',
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 4.w,
          runSpacing: 4.h,
          children: List.generate(7, (index) {
            final dayNumber = index + 1;
            final isSelected = _selectedWeekdays.contains(dayNumber);

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedWeekdays.remove(dayNumber);
                  } else {
                    _selectedWeekdays.add(dayNumber);
                  }
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.fRedBright
                      : AppColors.fWhiteBackground,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.fRedBright
                        : AppColors.fIconAndLabelText.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  _weekdayNames[index].substring(0, 3),
                  style: TextStyle(
                    color: isSelected ? AppColors.fWhite : AppColors.fTextH1,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Mulish',
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMonthlySelectors() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Day of Month',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.fTextH1,
                  fontFamily: 'Mulish',
                ),
              ),
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: () => _showDayPicker(context),
                child: Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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
                        'Day $_selectedDay',
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
            ],
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Time',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.fTextH1,
                  fontFamily: 'Mulish',
                ),
              ),
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: _selectTime,
                child: Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
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
            ],
          ),
        ),
      ],
    );
  }

  void _showDayPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.fWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20.r),
          height: 400.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Select Day of Month',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Mulish',
                    color: AppColors.fTextH1,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    crossAxisSpacing: 8.w,
                    mainAxisSpacing: 8.h,
                    childAspectRatio: 1,
                  ),
                  itemCount: 31,
                  itemBuilder: (context, index) {
                    final day = index + 1;
                    final isSelected = _selectedDay == day;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDay = day;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.fRedBright
                              : AppColors.fWhiteBackground,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.fRedBright
                                : AppColors.fIconAndLabelText
                                    .withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            day.toString(),
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.fWhite
                                  : AppColors.fTextH1,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Mulish',
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeRow() {
    return GestureDetector(
      onTap: _selectTime,
      child: Container(
        width: double.infinity,
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
    );
  }

  Widget _buildDateTimeRow() {
    if (_isRepeating && _repeatType == 'daily') {
      return GestureDetector(
        onTap: _selectTime,
        child: Container(
          width: double.infinity,
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
      );
    }

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
