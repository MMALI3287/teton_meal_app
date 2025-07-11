import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:teton_meal_app/app/app_theme.dart';
import 'package:teton_meal_app/data/services/menu_item_service.dart';
import 'package:teton_meal_app/data/models/menu_item_model.dart';
import 'package:teton_meal_app/features/menu_management/presentation/screens/add_menu_item_screen.dart';
import 'package:teton_meal_app/shared/presentation/widgets/common/standard_back_button.dart';

class SelectItemPage extends StatefulWidget {
  final List<MenuItem> initialSelectedItems;

  const SelectItemPage({
    super.key,
    this.initialSelectedItems = const [],
  });

  @override
  State<SelectItemPage> createState() => _SelectItemPageState();
}

class _SelectItemPageState extends State<SelectItemPage> {
  List<MenuItem> _selectedItems = [];
  List<MenuItem> _availableItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedItems = List.from(widget.initialSelectedItems);
    _loadMenuItems();
  }

  Future<void> _loadMenuItems() async {
    try {
      final items = await MenuItemService.getAllMenuItems();
      setState(() {
        _availableItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading items: $e'),
            backgroundColor: AppColors.fRed2,
          ),
        );
      }
    }
  }

  void _toggleItemSelection(MenuItem item) {
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
      } else {
        _selectedItems.add(item);
      }
    });
  }

  Future<void> _addNewItem() async {
    final newItem = await Navigator.push<MenuItem>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddNewItemPage(),
      ),
    );

    if (newItem != null) {
      setState(() {
        _availableItems.insert(0, newItem);
        _selectedItems.add(newItem);
      });
    }
  }

  void _saveSelection() {
    Navigator.pop(context, _selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fWhiteBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Container(
              height: 1.h,
              width: double.infinity,
              color: const Color(0xFFF4F5F7),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.fRedBright,
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 35.w),
                      child: Column(
                        children: [
                          Expanded(child: _buildItemsList()),
                          _buildActionButtons(),
                          SizedBox(height: 16.h),
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
      height: 64.h,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: [
          const StandardBackButton(),
          Expanded(
            child: Center(
              child: Text(
                'Select Item',
                style: TextStyle(
                  color: AppColors.fTextH1,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
          SizedBox(width: 20.w),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    if (_availableItems.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu_outlined,
            size: 64.sp,
            color: AppColors.fIconAndLabelText,
          ),
          SizedBox(height: 16.h),
          Text(
            'No items available',
            style: TextStyle(
              color: AppColors.fTextH2,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start by adding your first menu item',
            style: TextStyle(
              color: AppColors.fIconAndLabelText,
              fontSize: 14.sp,
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(top: 16.h),
      itemCount: _availableItems.length,
      itemBuilder: (context, index) {
        final item = _availableItems[index];
        final isSelected = _selectedItems.contains(item);

        return Container(
          margin: EdgeInsets.only(bottom: 16.h),
          child: Material(
            color: AppColors.fTransparent,
            child: InkWell(
              onTap: () => _toggleItemSelection(item),
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F5F7),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 16.w,
                      height: 16.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.fRedBright
                              : AppColors.fIconAndLabelText,
                          width: 2,
                        ),
                        color: isSelected
                            ? AppColors.fRedBright
                            : AppColors.fTransparent,
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              color: AppColors.fWhite,
                              size: 10.sp,
                            )
                          : null,
                    ),
                    SizedBox(width: 8.w),
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
                              letterSpacing: -0.24,
                            ),
                          ),
                          if (item.subItem != null && item.subItem!.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: 5.h),
                              child: Text(
                                'With ${item.subItem}',
                                style: TextStyle(
                                  color: AppColors.fIconAndLabelText,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: -0.24,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.r),
                            ),
                            child: Container(
                              padding: EdgeInsets.all(24.w),
                              decoration: BoxDecoration(
                                color: AppColors.fWhite,
                                borderRadius: BorderRadius.circular(24.r),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 56.w,
                                    height: 56.h,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFFF5F5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.delete_outline,
                                      color: AppColors.fRedBright,
                                      size: 24.sp,
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    'Delete Menu Item',
                                    style: TextStyle(
                                      color: AppColors.fTextH1,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      style: TextStyle(
                                        color: AppColors.fIconAndLabelText,
                                        fontSize: 14.sp,
                                        height: 1.5,
                                      ),
                                      children: [
                                        const TextSpan(
                                            text:
                                                'Are you sure you want to delete '),
                                        TextSpan(
                                          text: item.name,
                                          style: TextStyle(
                                            color: AppColors.fTextH1,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const TextSpan(text: '?'),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 24.h),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          height: 48.h,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: const Color(0xFFE5E7EB),
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12.r),
                                          ),
                                          child: TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            style: TextButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                              ),
                                            ),
                                            child: Text(
                                              'Cancel',
                                              style: TextStyle(
                                                color: AppColors.fTextH1,
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: Container(
                                          height: 48.h,
                                          decoration: BoxDecoration(
                                            color: AppColors.fRedBright,
                                            borderRadius:
                                                BorderRadius.circular(12.r),
                                          ),
                                          child: TextButton(
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              try {
                                                final success =
                                                    await MenuItemService
                                                        .deleteMenuItem(
                                                            item.id);
                                                if (success) {
                                                  setState(() {
                                                    _availableItems
                                                        .remove(item);
                                                    _selectedItems.remove(item);
                                                  });
                                                } else {
                                                  throw Exception(
                                                      'Failed to delete item');
                                                }
                                              } catch (e) {
                                                if (mounted) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          'Error deleting item: $e'),
                                                      backgroundColor:
                                                          AppColors.fRed2,
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                            style: TextButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                              ),
                                            ),
                                            child: Text(
                                              'Delete',
                                              style: TextStyle(
                                                color: AppColors.fWhite,
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w600,
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
                          ),
                        );
                      },
                      child: Container(
                        width: 14.w,
                        height: 16.h,
                        decoration: const BoxDecoration(
                          color: AppColors.fTransparent,
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          color: AppColors.fIconAndLabelText,
                          size: 16.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 38.h,
              decoration: BoxDecoration(
                color: AppColors.fRedBright,
                borderRadius: BorderRadius.circular(10.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    offset: const Offset(0, 4),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Material(
                color: AppColors.fTransparent,
                child: InkWell(
                  onTap: _addNewItem,
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
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
                          'Add New Item',
                          style: TextStyle(
                            color: AppColors.fWhite,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.172,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 9.w),
          Expanded(
            child: Container(
              height: 38.h,
              decoration: BoxDecoration(
                color: AppColors.saveGreen,
                borderRadius: BorderRadius.circular(10.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    offset: const Offset(0, 4),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Material(
                color: AppColors.fTransparent,
                child: InkWell(
                  onTap: _selectedItems.isNotEmpty ? _saveSelection : null,
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bookmark_outlined,
                          color: AppColors.fWhite,
                          size: 15.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Save',
                          style: TextStyle(
                            color: AppColors.fWhite,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.172,
                          ),
                        ),
                      ],
                    ),
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
