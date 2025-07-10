import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:teton_meal_app/app/app_theme.dart';
import 'package:teton_meal_app/data/services/auth_service.dart';
import 'package:teton_meal_app/shared/presentation/widgets/form_components/date_selector_widget.dart';
import 'package:teton_meal_app/features/menu_management/presentation/widgets/add_menu_item_button.dart';
import 'package:teton_meal_app/shared/presentation/widgets/form_components/end_time_selector_widget.dart';
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

      // Validate user ID is not empty
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

      // Use a transaction to ensure data consistency
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // First, deactivate any existing active polls for today
        final today = DateFormat('dd/MM/yyyy').format(_selectedDate);
        final existingActivePolls = await FirebaseFirestore.instance
            .collection('polls')
            .where('date', isEqualTo: today)
            .where('isActive', isEqualTo: true)
            .get();

        // Deactivate existing polls
        for (final doc in existingActivePolls.docs) {
          transaction.update(doc.reference, {'isActive': false});
        }

        // Create the new poll
        final newPollRef = FirebaseFirestore.instance.collection('polls').doc();

        // Initialize votes with empty arrays for each option
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
            'uid': user.uid, // This should now be validated to not be empty
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
      print('Error creating menu: $e'); // For debugging
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
      body: Container(
        width: 393.w,
        height: 805.h,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
        child: Column(
          children: [
            _buildHeader(),
            SizedBox(height: 24.h),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDateSelector(),
                    SizedBox(height: 20.h),
                    _buildAddItemButton(),
                    SizedBox(height: 20.h),
                    _buildSelectedItemsList(),
                    SizedBox(height: 20.h),
                    _buildEndTimeSelector(),
                    SizedBox(height: 40.h),
                    _buildActionButtons(),
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
      width: double.infinity,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 32.w,
              height: 32.h,
              decoration: BoxDecoration(
                color: AppColors.fYellow,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.close,
                color: AppColors.fWhite,
                size: 18.sp,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Create New Menu',
                style: TextStyle(
                  color: AppColors.fTextH1,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(width: 32.w), // Balance the close button
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return DateSelectorComponent(
      selectedDate: _selectedDate,
      onDateChanged: (date) {
        setState(() {
          _selectedDate = date;
        });
      },
    );
  }

  Widget _buildAddItemButton() {
    return AddItemButtonComponent(
      onPressed: _selectItems,
      isEnabled: !_isLoading,
    );
  }

  Widget _buildSelectedItemsList() {
    if (_selectedItems.isEmpty) {
      return Container();
    }

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
          constraints: BoxConstraints(maxHeight: 140.h),
          decoration: BoxDecoration(
            color: AppColors.fWhite,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.fTextH2.withOpacity(0.5)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.all(12.w),
            itemCount: _selectedItems.length,
            separatorBuilder: (context, index) => SizedBox(height: 8.h),
            itemBuilder: (context, index) {
              final item = _selectedItems[index];
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.saveGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: AppColors.saveGreen.withOpacity(0.3),
                  ),
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
                    Icon(
                      Icons.check_circle,
                      color: AppColors.saveGreen,
                      size: 16.sp,
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
    return EndTimeSelectorComponent(
      selectedTime: _selectedTime,
      onTimeChanged: (time) {
        setState(() {
          _selectedTime = time;
        });
      },
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.only(top: 16.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 52.h,
              child: OutlinedButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.fTextH2, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColors.fTextH2,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Container(
              height: 52.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: _selectedItems.isNotEmpty && !_isLoading
                    ? [
                        BoxShadow(
                          color: AppColors.fRedBright.withOpacity(0.3),
                          blurRadius: 8.r,
                          offset: Offset(0, 4.h),
                        ),
                      ]
                    : [],
              ),
              child: ElevatedButton(
                onPressed:
                    _isLoading || _selectedItems.isEmpty ? null : _createMenu,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.fRedBright,
                  foregroundColor: AppColors.fWhite,
                  disabledBackgroundColor: AppColors.fRedBright,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
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
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
