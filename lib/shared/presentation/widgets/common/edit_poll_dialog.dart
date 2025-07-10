import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:teton_meal_app/app/app_theme.dart';
import 'package:teton_meal_app/data/services/menu_item_service.dart';
import 'package:teton_meal_app/data/models/menu_item_model.dart';
import 'package:teton_meal_app/features/menu_management/presentation/screens/select_menu_item_screen.dart';

class EditPollDialog extends StatefulWidget {
  final QueryDocumentSnapshot pollData;

  const EditPollDialog({super.key, required this.pollData});

  @override
  EditPollDialogState createState() => EditPollDialogState();
}

class EditPollDialogState extends State<EditPollDialog> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  List<MenuItem> _selectedItems = [];
  List<MenuItem> _availableItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _loadAvailableItems();
  }

  void _initializeData() {
    final data = widget.pollData.data() as Map<String, dynamic>;

    // Parse date
    final dateString = data['date'] ?? '';
    try {
      final parts = dateString.split('/');
      if (parts.length == 3) {
        _selectedDate = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      } else {
        _selectedDate = DateTime.now();
      }
    } catch (e) {
      _selectedDate = DateTime.now();
    }

    // Parse time
    final endTimeMillis = data['endTimeMillis'] as int?;
    if (endTimeMillis != null) {
      final endTime = DateTime.fromMillisecondsSinceEpoch(endTimeMillis);
      _selectedTime = TimeOfDay(hour: endTime.hour, minute: endTime.minute);
    } else {
      _selectedTime = const TimeOfDay(hour: 10, minute: 0);
    }

    // Parse selected items
    final options = data['options'] as List? ?? [];
    _selectedItems = options.map((option) {
      final optionStr = option.toString();
      String name = optionStr;
      String? subItem;

      // Parse items with sub-items
      if (optionStr.contains('(With ') && optionStr.endsWith(')')) {
        final parts = optionStr.split('(With ');
        if (parts.length == 2) {
          name = parts[0].trim();
          subItem = parts[1].replaceAll(')', '').trim();
        }
      }

      return MenuItem(
        id: '',
        name: name,
        subItem: subItem,
        createdAt: DateTime.now(),
      );
    }).toList();
  }

  Future<void> _loadAvailableItems() async {
    final items = await MenuItemService.getAllMenuItems();
    setState(() {
      _availableItems = items;
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
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
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _addNewItem() {
    _selectItems();
  }

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

  void _removeItem(int index) {
    setState(() {
      _selectedItems.removeAt(index);
    });
  }

  Future<void> _updatePoll() async {
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
      final formattedDate = DateFormat('dd/MM/yy - EEEE').format(_selectedDate);

      final endTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final menuOptions =
          _selectedItems.map((item) => item.toString()).toList();

      await FirebaseFirestore.instance
          .collection('polls')
          .doc(widget.pollData.id)
          .update({
        'question': '$formattedDate - Food menu',
        'options': menuOptions,
        'date': DateFormat('dd/MM/yyyy').format(_selectedDate),
        'endTimeMillis': endTime.millisecondsSinceEpoch,
        'selectedItems': _selectedItems.map((item) => item.toMap()).toList(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Menu updated successfully!'),
            backgroundColor: AppColors.saveGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating menu: $e'),
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
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
        child: Column(
          children: [
            _buildHeader(),
            SizedBox(height: 32.h),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDateSelector(),
                    SizedBox(height: 24.h),
                    _buildItemsList(),
                    SizedBox(height: 16.h),
                    _buildAddItemButton(),
                    SizedBox(height: 24.h),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.fIconAndLabelText.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.edit,
              color: AppColors.fIconAndLabelText,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            'Edit Menu',
            style: TextStyle(
              color: AppColors.fTextH1,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Mulish',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.fIconAndLabelText.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.calendar_today_outlined,
                color: AppColors.fIconAndLabelText,
                size: 18.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                DateFormat('dd/M/yyyy EEEE').format(_selectedDate),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.fTextH1,
                  fontFamily: 'Mulish',
                ),
              ),
            ),
            Icon(
              Icons.edit,
              color: AppColors.fIconAndLabelText,
              size: 18.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Generate item entries dynamically based on selected items
        for (int i = 0; i < _selectedItems.length; i++) _buildItemEntry(i),
      ],
    );
  }

  Widget _buildItemEntry(int index) {
    final item = _selectedItems[index];
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Item Name ${index + 1}',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.fTextH1,
              fontFamily: 'Mulish',
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.fIconAndLabelText.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.restaurant_menu,
                    color: AppColors.fIconAndLabelText,
                    size: 16.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<MenuItem>(
                      value: _availableItems.any((availableItem) =>
                              availableItem.name == item.name &&
                              availableItem.subItem == item.subItem)
                          ? _availableItems.firstWhere((availableItem) =>
                              availableItem.name == item.name &&
                              availableItem.subItem == item.subItem)
                          : null,
                      hint: Text(
                        item.subItem != null
                            ? '${item.name} (With ${item.subItem})'
                            : item.name,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.fTextH1,
                          fontFamily: 'Mulish',
                        ),
                      ),
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.fIconAndLabelText,
                        size: 20.sp,
                      ),
                      items: _availableItems.map((MenuItem menuItem) {
                        return DropdownMenuItem<MenuItem>(
                          value: menuItem,
                          child: Text(
                            menuItem.subItem != null
                                ? '${menuItem.name} (With ${menuItem.subItem})'
                                : menuItem.name,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.fTextH1,
                              fontFamily: 'Mulish',
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (MenuItem? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedItems[index] = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () => _removeItem(index),
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    child: Icon(
                      Icons.delete_outline,
                      color: AppColors.fRed2,
                      size: 18.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddItemButton() {
    return Container(
      width: double.infinity,
      height: 48.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.fNameBoxPink.withOpacity(0.3),
            blurRadius: 8.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _addNewItem,
        icon: Container(
          width: 24.w,
          height: 24.h,
          decoration: BoxDecoration(
            color: AppColors.fWhite.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            Icons.add,
            color: AppColors.fWhite,
            size: 16.sp,
          ),
        ),
        label: Text(
          'Add Item',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.fWhite,
            fontFamily: 'Mulish',
            letterSpacing: 0.3,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.fNameBoxPink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        ),
      ),
    );
  }

  Widget _buildEndTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'End Time',
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
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.fNameBoxPink,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Icon(
                    Icons.access_time,
                    color: AppColors.fRedBright,
                    size: 18.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Text(
                    _selectedTime.format(context),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.fTextH1,
                      fontFamily: 'Mulish',
                    ),
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
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.fIconAndLabelText,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                fontFamily: 'Mulish',
              ),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          flex: 2,
          child: Container(
            height: 48.h,
            child: ElevatedButton.icon(
              onPressed:
                  _isLoading || _selectedItems.isEmpty ? null : _updatePoll,
              icon: Icon(
                Icons.save,
                size: 18.sp,
                color: AppColors.fWhite,
              ),
              label: Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.fWhite,
                  fontFamily: 'Mulish',
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.saveGreen,
                disabledBackgroundColor:
                    AppColors.fIconAndLabelText.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
