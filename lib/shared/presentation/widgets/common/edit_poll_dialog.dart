import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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

  late DateTime _initialDate;
  late TimeOfDay _initialTime;
  late List<MenuItem> _initialSelectedItems;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _loadAvailableItems();
  }

  void _initializeData() {
    final data = widget.pollData.data() as Map<String, dynamic>;

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

    final endTimeMillis = data['endTimeMillis'] as int?;
    if (endTimeMillis != null) {
      final endTime = DateTime.fromMillisecondsSinceEpoch(endTimeMillis);
      _selectedTime = TimeOfDay(hour: endTime.hour, minute: endTime.minute);
    } else {
      _selectedTime = const TimeOfDay(hour: 10, minute: 0);
    }

    final options = data['options'] as List? ?? [];
    _selectedItems = options.map((option) {
      final optionStr = option.toString();
      String name = optionStr;
      String? subItem;

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

    _initialDate = _selectedDate;
    _initialTime = _selectedTime;
    _initialSelectedItems = List<MenuItem>.from(_selectedItems);
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
    _showDeleteConfirmation(index);
  }

  Future<void> _showDeleteConfirmation(int index) async {
    final item = _selectedItems[index];
    final itemName = item.subItem != null
        ? '${item.name} (With ${item.subItem})'
        : item.name;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.fTransparent,
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.fWhite,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.fRed2.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(50.r),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: AppColors.fRed2,
                    size: 32.sp,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Delete Item',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.fTextH1,
                    fontFamily: 'DM Sans',
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Are you sure you want to delete "$itemName"? This will remove all votes for this item and allow those users to vote again.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.fTextH2,
                    fontFamily: 'DM Sans',
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44.h,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.fLineaAndLabelBox,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.fTextH1,
                              fontFamily: 'DM Sans',
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Container(
                        height: 44.h,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _confirmRemoveItem(index);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.fRed2,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.fWhite,
                              fontFamily: 'DM Sans',
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

  void _confirmRemoveItem(int index) {
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

      final pollDoc = await FirebaseFirestore.instance
          .collection('polls')
          .doc(widget.pollData.id)
          .get();

      final currentData = pollDoc.data() as Map<String, dynamic>;
      final currentOptions = List<String>.from(currentData['options'] ?? []);
      final currentVotes =
          Map<String, dynamic>.from(currentData['votes'] ?? {});

      final removedOptions = currentOptions
          .where((option) => !menuOptions.contains(option))
          .toList();

      final updatedVotes = Map<String, dynamic>.from(currentVotes);
      for (final removedOption in removedOptions) {
        updatedVotes.remove(removedOption);
        if (kDebugMode) {
          print('Removed votes for deleted option: $removedOption');
        }
      }

      for (final option in menuOptions) {
        if (!updatedVotes.containsKey(option)) {
          updatedVotes[option] = [];
        }
      }

      await FirebaseFirestore.instance
          .collection('polls')
          .doc(widget.pollData.id)
          .update({
        'question': '$formattedDate - Food menu',
        'options': menuOptions,
        'votes': updatedVotes,
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
    return Dialog(
      backgroundColor: AppColors.fTransparent,
      insetPadding: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.fWhite,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.r),
            topRight: Radius.circular(30.r),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.w),
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
                        SizedBox(height: 24.h),
                        _buildItemsList(),
                        SizedBox(height: 16.h),
                        _buildAddItemButton(),
                        SizedBox(height: 32.h),
                        Container(
                          height: 1.h,
                          color: AppColors.fLineaAndLabelBox,
                        ),
                        SizedBox(height: 32.h),
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
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 72.h,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 19.w,
              height: 18.h,
              child: Image.asset(
                'assets/images/clock.png',
                width: 19.w,
                height: 18.h,
                color: AppColors.fYellow,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'Edit Menu',
              style: TextStyle(
                color: AppColors.fTextH1,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'DM Sans',
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        width: double.infinity,
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
              color: AppColors.fTextH1,
              size: 18.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                DateFormat('dd/M/yyyy EEEE').format(_selectedDate),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.fTextH1,
                  fontFamily: 'DM Sans',
                  letterSpacing: -0.42,
                ),
              ),
            ),
            Icon(
              Icons.edit,
              color: AppColors.fTextH1,
              size: 16.sp,
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
        for (int i = 0; i < _selectedItems.length; i++) _buildItemEntry(i),
      ],
    );
  }

  Widget _buildItemEntry(int index) {
    final item = _selectedItems[index];
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Item Name ${index + 1}',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.fTextH1,
              fontFamily: 'DM Sans',
              letterSpacing: -0.2,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            height: 46.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: AppColors.fLineaAndLabelBox,
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.restaurant_menu,
                  color: AppColors.fTextH2,
                  size: 16.sp,
                ),
                SizedBox(width: 18.w),
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
                          fontSize: 13.8.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.fTextH2,
                          fontFamily: 'DM Sans',
                          letterSpacing: -0.197,
                        ),
                      ),
                      icon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.fTextH1,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          GestureDetector(
                            onTap: () => _removeItem(index),
                            child: Icon(
                              Icons.delete_outline,
                              color: AppColors.fTextH1,
                              size: 14.sp,
                            ),
                          ),
                        ],
                      ),
                      items: _availableItems.map((MenuItem menuItem) {
                        return DropdownMenuItem<MenuItem>(
                          value: menuItem,
                          child: Text(
                            menuItem.subItem != null
                                ? '${menuItem.name} (With ${menuItem.subItem})'
                                : menuItem.name,
                            style: TextStyle(
                              fontSize: 13.8.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.fTextH2,
                              fontFamily: 'DM Sans',
                              letterSpacing: -0.197,
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
      height: 36.h,
      child: ElevatedButton(
        onPressed: _addNewItem,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.fYellow,
          elevation: 4,
          shadowColor: AppColors.fTextH1.withValues(alpha: 0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              color: AppColors.fWhite,
              size: 16.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              'Add Item',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.fWhite,
                fontFamily: 'DM Sans',
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEndTimeSelector() {
    return GestureDetector(
      onTap: _selectTime,
      child: Container(
        width: double.infinity,
        height: 47.h,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: BoxDecoration(
          color: AppColors.fLineaAndLabelBox,
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Row(
          children: [
            Container(
              width: 29.w,
              height: 36.h,
              child: Image.asset(
                'assets/images/clock.png',
                width: 29.w,
                height: 36.h,
                fit: BoxFit.contain,
              ),
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
                      fontWeight: FontWeight.w500,
                      color: AppColors.fIconAndLabelText,
                      fontFamily: 'DM Sans',
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    _selectedTime.format(context),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.fTextH1,
                      fontFamily: 'DM Sans',
                      letterSpacing: -0.24,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.fTextH1,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 38.h,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleCancel,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.fWhite,
                elevation: 4,
                shadowColor: AppColors.fTextH1.withValues(alpha: 0.25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.fRedBright,
                  fontFamily: 'DM Sans',
                  letterSpacing: -0.172,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Container(
            height: 38.h,
            child: ElevatedButton(
              onPressed: _isLoading || _selectedItems.isEmpty
                  ? null
                  : _handleSaveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.saveGreen,
                disabledBackgroundColor:
                    AppColors.fIconAndLabelText.withValues(alpha: 0.3),
                elevation: 4,
                shadowColor: AppColors.fTextH1.withValues(alpha: 0.25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.save,
                    size: 15.sp,
                    color: AppColors.fWhite,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.fWhite,
                      fontFamily: 'DM Sans',
                      letterSpacing: -0.172,
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

  bool _hasChanges() {
    if (_selectedDate != _initialDate) return true;

    if (_selectedTime.hour != _initialTime.hour ||
        _selectedTime.minute != _initialTime.minute) return true;

    if (_selectedItems.length != _initialSelectedItems.length) return true;

    for (int i = 0; i < _selectedItems.length; i++) {
      final current = _selectedItems[i];
      final initial = _initialSelectedItems[i];
      if (current.name != initial.name || current.subItem != initial.subItem) {
        return true;
      }
    }

    return false;
  }

  void _handleCancel() {
    if (!_hasChanges()) {
      Navigator.pop(context);
      return;
    }

    _showCancelConfirmationDialog();
  }

  void _handleSaveChanges() {
    if (!_hasChanges()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No changes detected'),
          backgroundColor: AppColors.fIconAndLabelText,
        ),
      );
      return;
    }

    _showSaveConfirmationDialog();
  }

  Future<void> _showSaveConfirmationDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
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
                    color: AppColors.saveGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.save_outlined,
                    color: AppColors.saveGreen,
                    size: 32.sp,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.fTextH1,
                    fontFamily: 'DM Sans',
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),
                Text(
                  'Are you sure you want to save these changes to the menu?',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.fIconAndLabelText,
                    fontFamily: 'DM Sans',
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
                              'Cancel',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.fIconAndLabelText,
                                fontFamily: 'DM Sans',
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
                            color: AppColors.saveGreen,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.saveGreen.withValues(alpha: 0.3),
                                blurRadius: 8.r,
                                offset: Offset(0, 4.h),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Save',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.fWhite,
                                fontFamily: 'DM Sans',
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

    if (confirmed == true) {
      _updatePoll();
    }
  }

  Future<void> _showCancelConfirmationDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
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
                    color: AppColors.fYellow.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_outlined,
                    color: AppColors.fYellow,
                    size: 32.sp,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'Unsaved Changes',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.fTextH1,
                    fontFamily: 'DM Sans',
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),
                Text(
                  'You have unsaved changes. Are you sure you want to discard them?',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.fIconAndLabelText,
                    fontFamily: 'DM Sans',
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
                              'Keep Editing',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.fIconAndLabelText,
                                fontFamily: 'DM Sans',
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
                            color: AppColors.fRedBright,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.fRedBright.withValues(alpha: 0.3),
                                blurRadius: 8.r,
                                offset: Offset(0, 4.h),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Discard',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.fWhite,
                                fontFamily: 'DM Sans',
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

    if (confirmed == true) {
      Navigator.pop(context);
    }
  }
}
