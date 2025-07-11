import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:teton_meal_app/app/app_theme.dart';
import 'package:teton_meal_app/data/services/auth_service.dart';
import 'package:teton_meal_app/data/models/menu_item_model.dart';
import 'package:teton_meal_app/features/menu_management/presentation/screens/select_menu_item_screen.dart';

class CreateNewMenuPage extends StatefulWidget {
  const CreateNewMenuPage({super.key});

  @override
  State<CreateNewMenuPage> createState() => _CreateNewMenuPageState();
}

class _CreateNewMenuPageState extends State<CreateNewMenuPage> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  List<MenuItem> _selectedItems = [];
  bool _isLoading = false;

  Future<void> _selectItems() async {
    final selectedItems = await Navigator.push<List<MenuItem>>(
      context,
      MaterialPageRoute(
        builder: (context) => SelectItemPage(
          initialSelectedItems: _selectedItems,
        ),
      ),
    );

    if (selectedItems != null) {
      setState(() {
        _selectedItems = selectedItems;
      });
    }
  }

  Future<void> _handleCancel() async {
    if (_selectedItems.isNotEmpty) {
      final shouldCancel = await _showConfirmationDialog(
        title: 'Cancel Menu Creation',
        message:
            'You have ${_selectedItems.length} item(s) selected. Are you sure you want to cancel?',
        confirmText: 'Yes, Cancel',
        cancelText: 'Keep Editing',
      );

      if (shouldCancel == true) {
        Navigator.pop(context);
      }
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _handleCreateMenu() async {
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one item'),
          backgroundColor: AppColors.fRed2,
        ),
      );
      return;
    }

    final shouldCreate = await _showConfirmationDialog(
      title: 'Create Menu',
      message:
          'Create menu with ${_selectedItems.length} item(s) for ${DateFormat('dd/MM/yyyy').format(_selectedDate)}?',
      confirmText: 'Create Menu',
      cancelText: 'Cancel',
    );

    if (shouldCreate == true) {
      _createMenu();
    }
  }

  Future<bool?> _showConfirmationDialog({
    required String title,
    required String message,
    required String confirmText,
    required String cancelText,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        IconData iconData;
        Color iconColor;
        Color buttonColor;

        if (title.contains('Cancel')) {
          iconData = Icons.warning_outlined;
          iconColor = AppColors.fYellow;
          buttonColor = AppColors.fRedBright;
        } else if (title.contains('Remove')) {
          iconData = Icons.delete_outline;
          iconColor = AppColors.fRedBright;
          buttonColor = AppColors.fRedBright;
        } else {
          iconData = Icons.restaurant_menu_outlined;
          iconColor = AppColors.saveGreen;
          buttonColor = AppColors.saveGreen;
        }

        return Dialog(
          backgroundColor: AppColors.fTransparent,
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.fWhite,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.fTextH1.withValues(alpha: 0.1),
                  blurRadius: 20.r,
                  offset: Offset(0, 8.h),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconData,
                    color: iconColor,
                    size: 32.sp,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.fTextH1,
                    fontFamily: 'Mulish',
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.fIconAndLabelText,
                    fontFamily: 'Mulish',
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.h),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(false),
                        child: Container(
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: AppColors.fIconAndLabelText
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Center(
                            child: Text(
                              cancelText,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.fIconAndLabelText,
                                fontFamily: 'Mulish',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(true),
                        child: Container(
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: buttonColor,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: buttonColor.withValues(alpha: 0.3),
                                blurRadius: 8.r,
                                offset: Offset(0, 4.h),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              confirmText,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.fWhite,
                                fontFamily: 'Mulish',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _removeItem(int index) async {
    final shouldRemove = await _showConfirmationDialog(
      title: 'Remove Item',
      message: 'Remove "${_selectedItems[index].name}" from the menu?',
      confirmText: 'Remove',
      cancelText: 'Cancel',
    );

    if (shouldRemove == true) {
      setState(() {
        _selectedItems.removeAt(index);
      });
    }
  }

  Future<void> _createMenu() async {
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one item'),
          backgroundColor: AppColors.fRed2,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = AuthService().currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      if (user.uid.isEmpty) {
        throw Exception('User ID is invalid');
      }

      final String creatorName = user.displayName ?? user.email;
      final String formattedDate =
          DateFormat('dd/MM/yy - EEEE').format(_selectedDate);

      final endTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final menuOptions =
          _selectedItems.map((item) => item.toString()).toList();

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final today = DateFormat('dd/MM/yyyy').format(_selectedDate);
        final existingActivePolls = await FirebaseFirestore.instance
            .collection('polls')
            .where('date', isEqualTo: today)
            .where('isActive', isEqualTo: true)
            .get();

        for (final doc in existingActivePolls.docs) {
          transaction.update(doc.reference, {'isActive': false});
        }

        final newPollRef = FirebaseFirestore.instance.collection('polls').doc();

        final Map<String, List<String>> initialVotes = {};
        for (String option in menuOptions) {
          initialVotes[option] = [];
        }

        transaction.set(newPollRef, {
          'question': '$formattedDate - Food menu',
          'options': menuOptions,
          'votes': initialVotes,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'createdBy': {
            'uid': user.uid,
            'name': creatorName,
          },
          'date': today,
          'endTimeMillis': endTime.millisecondsSinceEpoch,
          'selectedItems': _selectedItems.map((item) => item.toMap()).toList(),
        });
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Menu created successfully! ${menuOptions.length} items added.'),
            backgroundColor: AppColors.saveGreen,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating menu: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating menu: $e'),
            backgroundColor: AppColors.fRed2,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fWhiteBackground,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.fWhite,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(42.r),
              topRight: Radius.circular(42.r),
            ),
          ),
          child: Column(
            children: [
              _buildHeader(),
              Container(
                height: 1.h,
                color: AppColors.fLineaAndLabelBox,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 35.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.h),
                      _buildDateSelector(),
                      SizedBox(height: 24.h),
                      _buildAddItemButton(),
                      Container(
                        height: 1.h,
                        width: double.infinity,
                        color: AppColors.fLineaAndLabelBox,
                        margin: EdgeInsets.symmetric(vertical: 24.h),
                      ),
                      if (_selectedItems.isNotEmpty) ...[
                        _buildSelectedItemsList(),
                        SizedBox(height: 16.h),
                      ],
                      _buildEndTimeSelector(),
                      SizedBox(height: 40.h),
                      _buildActionButtons(),
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 64.h,
      padding: EdgeInsets.symmetric(horizontal: 35.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _handleCancel,
            child: Container(
              width: 21.w,
              height: 20.h,
              child: Icon(
                Icons.close,
                color: AppColors.fYellow,
                size: 20.sp,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.restaurant,
                color: AppColors.fYellow,
                size: 18.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Create New Menu',
                style: TextStyle(
                  color: AppColors.fTextH1,
                  fontSize: 16.sp,
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          SizedBox(width: 21.w),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      height: 44.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: AppColors.fLineaAndLabelBox,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 18.sp,
            color: AppColors.fIconAndLabelText,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              DateFormat('dd/M/yyyy EEEE').format(_selectedDate),
              style: TextStyle(
                color: AppColors.fTextH1,
                fontSize: 14.sp,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w500,
                letterSpacing: -0.42,
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                setState(() {
                  _selectedDate = picked;
                });
              }
            },
            child: Icon(
              Icons.edit_outlined,
              size: 16.sp,
              color: AppColors.fIconAndLabelText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddItemButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _selectItems,
      child: Container(
        height: 36.h,
        decoration: BoxDecoration(
          color: AppColors.fYellow,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 4.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle,
              color: AppColors.fWhite,
              size: 16.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              'Add Item',
              style: TextStyle(
                color: AppColors.fWhite,
                fontSize: 14.sp,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w500,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedItemsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: AppColors.saveGreen,
              size: 16.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              'Selected Items (${_selectedItems.length})',
              style: TextStyle(
                color: AppColors.fTextH1,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.fLineaAndLabelBox,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(12.w),
            itemCount: _selectedItems.length,
            separatorBuilder: (context, index) => SizedBox(height: 8.h),
            itemBuilder: (context, index) {
              final item = _selectedItems[index];
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.fWhite,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 2.r,
                      offset: Offset(0, 1.h),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6.w,
                      height: 6.h,
                      decoration: const BoxDecoration(
                        color: AppColors.saveGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: TextStyle(
                              color: AppColors.fTextH1,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (item.subItem != null && item.subItem!.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: 2.h),
                              child: Text(
                                'With ${item.subItem}',
                                style: TextStyle(
                                  color: AppColors.fTextH2,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _removeItem(index),
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        child: Icon(
                          Icons.delete_outline,
                          color: AppColors.fRedBright,
                          size: 16.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEndTimeSelector() {
    return GestureDetector(
      onTap: () => _selectTime(context),
      child: Container(
        height: 55.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.fLineaAndLabelBox,
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time_outlined,
              size: 20.sp,
              color: AppColors.fIconAndLabelText,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'End Time',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w500,
                      color: AppColors.fIconAndLabelText,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    _selectedTime.format(context),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w500,
                      color: AppColors.fTextH1,
                      letterSpacing: -0.24,
                    ),
                  ),
                ],
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

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48.h,
            child: OutlinedButton(
              onPressed: _isLoading ? null : _handleCancel,
              style: OutlinedButton.styleFrom(
                side:
                    BorderSide(color: AppColors.fIconAndLabelText, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r),
                ),
                backgroundColor: AppColors.fWhite,
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.fIconAndLabelText,
                  fontSize: 14.sp,
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Container(
            height: 48.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.r),
              boxShadow: _selectedItems.isNotEmpty && !_isLoading
                  ? [
                      BoxShadow(
                        color: AppColors.fYellow.withValues(alpha: 0.3),
                        blurRadius: 8.r,
                        offset: Offset(0, 4.h),
                      ),
                    ]
                  : [],
            ),
            child: ElevatedButton(
              onPressed: _isLoading || _selectedItems.isEmpty
                  ? null
                  : _handleCreateMenu,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.fYellow,
                foregroundColor: AppColors.fWhite,
                disabledBackgroundColor: AppColors.fIconAndLabelText,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.fWhite,
                        ),
                      ),
                    )
                  : Text(
                      'Create Menu',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.2,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
