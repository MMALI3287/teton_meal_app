import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:teton_meal_app/app/app_theme.dart';
import 'package:teton_meal_app/data/services/reminder_service.dart';
import 'package:teton_meal_app/data/models/reminder_model.dart';

class AddReminderPage extends StatefulWidget {
  final ReminderModel? reminder; // For editing existing reminder

  const AddReminderPage({super.key, this.reminder});

  @override
  State<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final ReminderService _reminderService = ReminderService();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isRepeating = false;
  String _repeatType = 'daily';
  bool _isLoading = false;

  final List<String> _repeatOptions = ['daily', 'weekly', 'monthly'];

  @override
  void initState() {
    super.initState();
    _initializeForEditing();
  }

  void _initializeForEditing() {
    if (widget.reminder != null) {
      final reminder = widget.reminder!;
      _nameController.text = reminder.name;
      _detailsController.text = reminder.details ?? '';
      _selectedDate = reminder.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(reminder.dateTime);
      _isRepeating = reminder.isRepeating;
      _repeatType = reminder.repeatType ?? 'daily';
    }
  }

  bool get _isEditMode => widget.reminder != null;

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

  Future<void> _saveReminder() async {
    if (_nameController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter a reminder name');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final DateTime reminderDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      if (_isEditMode) {
        // Update existing reminder
        final updatedReminder = ReminderModel(
          id: widget.reminder!.id,
          name: _nameController.text.trim(),
          details: _detailsController.text.trim().isEmpty
              ? null
              : _detailsController.text.trim(),
          dateTime: reminderDateTime,
          isActive: widget.reminder!.isActive,
          isRepeating: _isRepeating,
          repeatType: _isRepeating ? _repeatType : null,
          userId: widget.reminder!.userId,
          createdAt: widget.reminder!.createdAt,
          updatedAt: DateTime.now(),
        );

        await _reminderService.updateReminder(updatedReminder);
      } else {
        // Create new reminder
        await _reminderService.createReminder(
          name: _nameController.text.trim(),
          details: _detailsController.text.trim().isEmpty
              ? null
              : _detailsController.text.trim(),
          dateTime: reminderDateTime,
          isRepeating: _isRepeating,
          repeatType: _isRepeating ? _repeatType : null,
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
      _showErrorSnackBar('Failed to create reminder: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fWhiteBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
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
              ),
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
              color: AppColors.fIconAndLabelText.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Reminder Name',
              hintStyle: TextStyle(
                color: AppColors.fIconAndLabelText.withOpacity(0.6),
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
          'Label Details',
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
              color: AppColors.fIconAndLabelText.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: TextField(
            controller: _detailsController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Type Details Here (Optional)',
              hintStyle: TextStyle(
                color: AppColors.fIconAndLabelText.withOpacity(0.6),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Set Time',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.fTextH1,
                fontFamily: 'Mulish',
              ),
            ),
            Row(
              children: [
                Text(
                  _isRepeating ? 'Repeat on' : 'Repeat off',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFEF9F27), // Orange color from Figma
                    fontFamily: 'Mulish',
                  ),
                ),
                SizedBox(width: 8.w),
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
                          : AppColors.fIconAndLabelText.withOpacity(0.3),
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
              ],
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
          color: AppColors.fIconAndLabelText.withOpacity(0.2),
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
          child: _buildDateButton(),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _buildTimeButton(),
        ),
      ],
    );
  }

  Widget _buildDateButton() {
    String displayText;
    if (_isRepeating) {
      switch (_repeatType) {
        case 'daily':
          displayText = 'Everyday';
          break;
        case 'weekly':
          displayText = DateFormat('EEEE').format(_selectedDate);
          break;
        case 'monthly':
          displayText =
              'Every ${_selectedDate.day}${_getOrdinalSuffix(_selectedDate.day)}';
          break;
        default:
          displayText = DateFormat('dd/MM/yyyy').format(_selectedDate);
      }
    } else {
      displayText = DateFormat('dd/MM/yyyy').format(_selectedDate);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.fTextH1,
            fontFamily: 'Mulish',
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: AppColors.fWhite,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.fIconAndLabelText.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              displayText,
              style: TextStyle(
                color: AppColors.fIconAndLabelText,
                fontSize: 14.sp,
                fontFamily: 'Mulish',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeButton() {
    return Column(
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
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: _selectTime,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: AppColors.fWhite,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.fIconAndLabelText.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              _selectedTime.format(context),
              style: TextStyle(
                color: AppColors.fIconAndLabelText,
                fontSize: 14.sp,
                fontFamily: 'Mulish',
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
        onPressed: _isLoading ? null : _saveReminder,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEF9F27), // Orange color from Figma
          foregroundColor: AppColors.fWhite,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? SizedBox(
                height: 20.h,
                width: 20.w,
                child: CircularProgressIndicator(
                  color: AppColors.fWhite,
                  strokeWidth: 2,
                ),
              )
            : Text(
                _isEditMode ? 'Update' : 'Set',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Mulish',
                ),
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
