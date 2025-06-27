import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../../Styles/colors.dart';
import '../../../../services/menu_item_service.dart';
import '../models/menu_item.dart';

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
  String _newItemName = '';
  String _newItemSubItem = '';

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
    if (_newItemName.isNotEmpty) {
      final newItem = MenuItem(
        id: '',
        name: _newItemName,
        subItem: _newItemSubItem.isNotEmpty ? _newItemSubItem : null,
        createdAt: DateTime.now(),
      );

      setState(() {
        _selectedItems.add(newItem);
        _newItemName = '';
        _newItemSubItem = '';
      });
    }
  }

  void _removeItem(int index) {
    setState(() {
      _selectedItems.removeAt(index);
    });
  }

  void _addFromList(MenuItem item) {
    if (!_selectedItems.any((selected) =>
        selected.name == item.name && selected.subItem == item.subItem)) {
      setState(() {
        _selectedItems.add(item);
      });
    }
  }

  Future<void> _updatePoll() async {
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one item'),
          backgroundColor: AppColors.error,
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
            backgroundColor: AppColors.error,
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
      backgroundColor: AppColors.backgroundColor,
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
                    _buildAddItemSection(),
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
                color: AppColors.secondaryColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.close,
                color: AppColors.white,
                size: 18.sp,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Edit Menu',
                style: TextStyle(
                  color: AppColors.primaryText,
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
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        width: double.infinity,
        height: 64.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.inputBorderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor.withOpacity(0.1),
              blurRadius: 4.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: AppColors.fLineaAndLabelBox,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: AppColors.inputBorderColor.withOpacity(0.5),
                ),
              ),
              child: Icon(
                Icons.calendar_today_outlined,
                color: AppColors.fIconAndLabelText,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('dd/MM/yyyy EEEE').format(_selectedDate),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.edit,
              color: AppColors.tertiaryText,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddItemSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Item Name Input
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.inputBorderColor, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Item Name',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryText,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.inputBorderColor),
                ),
                child: TextField(
                  onChanged: (value) => _newItemName = value,
                  decoration: InputDecoration(
                    hintText: 'Type here to add new item',
                    hintStyle: TextStyle(
                      color: AppColors.tertiaryText,
                      fontSize: 14.sp,
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    suffixIcon: Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.tertiaryText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        // Add Item Button
        Container(
          width: double.infinity,
          height: 48.h,
          child: ElevatedButton.icon(
            onPressed: _newItemName.isNotEmpty ? _addNewItem : null,
            icon: Icon(Icons.add, size: 18.sp),
            label: Text(
              'Add Item',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: AppColors.white,
              disabledBackgroundColor: AppColors.disabledButton,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        // Sub Item Input
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.inputBorderColor, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sub Item',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryText,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.inputBorderColor),
                ),
                child: TextField(
                  onChanged: (value) => _newItemSubItem = value,
                  decoration: InputDecoration(
                    hintText: 'Optional',
                    hintStyle: TextStyle(
                      color: AppColors.tertiaryText,
                      fontSize: 14.sp,
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        // Add from list section
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.inputBorderColor, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add from list',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryText,
                ),
              ),
              SizedBox(height: 8.h),
              DropdownButtonFormField<MenuItem>(
                decoration: InputDecoration(
                  hintText: 'Fish',
                  hintStyle: TextStyle(
                    color: AppColors.tertiaryText,
                    fontSize: 14.sp,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: AppColors.inputBorderColor),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                ),
                items: _availableItems.map((item) {
                  return DropdownMenuItem<MenuItem>(
                    value: item,
                    child: Text(item.toString()),
                  );
                }).toList(),
                onChanged: (MenuItem? item) {
                  if (item != null) {
                    _addFromList(item);
                  }
                },
              ),
            ],
          ),
        ),
      ],
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
                color: AppColors.primaryText,
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
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12.r),
            border:
                Border.all(color: AppColors.inputBorderColor.withOpacity(0.5)),
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
                      decoration: BoxDecoration(
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
                              color: AppColors.primaryText,
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
                                  color: AppColors.secondaryText,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _removeItem(index),
                      child: Icon(
                        Icons.close,
                        color: AppColors.error,
                        size: 16.sp,
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
      onTap: _selectTime,
      child: Container(
        width: double.infinity,
        height: 70.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.inputBorderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor.withOpacity(0.1),
              blurRadius: 4.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: AppColors.fNameBoxPink,
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Icon(
                Icons.access_time,
                color: AppColors.fRedBright,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'End Time',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryText,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _selectedTime.format(context),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.tertiaryText,
              size: 20.sp,
            ),
          ],
        ),
      ),
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
                  side:
                      BorderSide(color: AppColors.inputBorderColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 12.sp,
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
                          color: AppColors.primaryColor.withOpacity(0.3),
                          blurRadius: 8.r,
                          offset: Offset(0, 4.h),
                        ),
                      ]
                    : [],
              ),
              child: ElevatedButton(
                onPressed:
                    _isLoading || _selectedItems.isEmpty ? null : _updatePoll,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.saveGreen,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: AppColors.disabledButton,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.white,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save, size: 18.sp),
                          SizedBox(width: 8.w),
                          Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
