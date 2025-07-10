import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:teton_meal_app/app/app_theme.dart';
import 'package:teton_meal_app/data/services/menu_item_service.dart';
import 'package:teton_meal_app/shared/presentation/widgets/common/confirmation_delete_dialog.dart';
import 'package:teton_meal_app/data/models/menu_item_model.dart';
import 'package:teton_meal_app/features/menu_management/presentation/screens/add_menu_item_screen.dart';

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
      body: Container(
        width: 393.w,
        height: 805.h,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
        child: Column(
          children: [
            _buildHeader(),
            SizedBox(height: 24.h),
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.fRedBright,
                  ),
                ),
              )
            else
              Expanded(
                child: Column(
                  children: [
                    Expanded(child: _buildItemsList()),
                    SizedBox(height: 16.h),
                    _buildActionButtons(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
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
                'Select Item',
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
      itemCount: _availableItems.length,
      itemBuilder: (context, index) {
        final item = _availableItems[index];
        final isSelected = _selectedItems.contains(item);

        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          child: Material(
            color: AppColors.fTransparent,
            child: InkWell(
              onTap: () => _toggleItemSelection(item),
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.fWhite,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color:
                        isSelected ? AppColors.fRedBright : AppColors.fTextH2,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20.w,
                      height: 20.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.fRedBright
                              : AppColors.fTextH2,
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
                              size: 12.sp,
                            )
                          : null,
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: TextStyle(
                              color: AppColors.fTextH1,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (item.subItem != null && item.subItem!.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: 4.h),
                              child: Text(
                                'With ${item.subItem}',
                                style: TextStyle(
                                  color: AppColors.fTextH2,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => CustomDeleteDialog(
                            title: 'Delete Menu Item',
                            message: 'Are you sure you want to delete ',
                            itemName: item.name,
                            onDelete: () async {
                              try {
                                final success =
                                    await MenuItemService.deleteMenuItem(
                                        item.id);
                                if (success) {
                                  setState(() {
                                    _availableItems.remove(item);
                                    _selectedItems.remove(item);
                                  });
                                } else {
                                  throw Exception('Failed to delete item');
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error deleting item: $e'),
                                      backgroundColor: AppColors.fRed2,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.delete_outline,
                        color: AppColors.fIconAndLabelText,
                        size: 20.sp,
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
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48.h,
            child: OutlinedButton(
              onPressed: _addNewItem,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.fRedBright),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add,
                    color: AppColors.fRedBright,
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Text(
                      'Add New Item',
                      style: TextStyle(
                        color: AppColors.fRedBright,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: SizedBox(
            height: 48.h,
            child: ElevatedButton(
              onPressed: _selectedItems.isNotEmpty ? _saveSelection : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.saveGreen,
                foregroundColor: AppColors.fWhite,
                disabledBackgroundColor: AppColors.fRedBright,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bookmark_outlined,
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
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
}
