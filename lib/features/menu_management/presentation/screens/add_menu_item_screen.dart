import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:teton_meal_app/app/app_theme.dart';
import 'package:teton_meal_app/data/services/menu_item_service.dart';

class AddNewItemPage extends StatefulWidget {
  const AddNewItemPage({super.key});

  @override
  State<AddNewItemPage> createState() => _AddNewItemPageState();
}

class _AddNewItemPageState extends State<AddNewItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  final _subItemController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _itemNameController.dispose();
    _subItemController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final savedItem = await MenuItemService.addMenuItem(
        _itemNameController.text.trim(),
        _subItemController.text.trim().isNotEmpty
            ? _subItemController.text.trim()
            : null,
      );

      if (savedItem != null && mounted) {
        Navigator.pop(context, savedItem);
      } else {
        throw Exception('Failed to save item');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving item: $e'),
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
        child: Column(
          children: [
            _buildHeader(),
            Container(
              height: 1.h,
              width: double.infinity,
              color: AppColors.fWhiteBackground,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 35.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.h),
                      _buildItemNameField(),
                      SizedBox(height: 12.h),
                      _buildSubItemField(),
                      const Spacer(),
                      _buildActionButtons(),
                      SizedBox(height: 16.h),
                    ],
                  ),
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
          Expanded(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.restaurant,
                    color: AppColors.fYellow,
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Add New Item',
                    style: TextStyle(
                      color: AppColors.fTextH1,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Item Name',
          style: TextStyle(
            color: AppColors.fTextH1,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.2,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          height: 47.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.fWhiteBackground,
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 12.w, right: 18.w),
                child: Icon(
                  Icons.fastfood_outlined,
                  color: AppColors.fIconAndLabelText,
                  size: 16.sp,
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: _itemNameController,
                  style: TextStyle(
                    color: AppColors.fTextH1,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.24,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Type item name here to add',
                    hintStyle: TextStyle(
                      color: AppColors.fIconAndLabelText,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.24,
                    ),
                    filled: false,
                    fillColor: AppColors.fTransparent,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an item name';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 12.w),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubItemField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sub Item',
          style: TextStyle(
            color: AppColors.fTextH1,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.2,
          ),
        ),
        SizedBox(height: 14.h),
        Container(
          height: 44.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.fWhiteBackground,
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: TextFormField(
            controller: _subItemController,
            style: TextStyle(
              color: AppColors.fTextH1,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.2,
            ),
            decoration: const InputDecoration(
              hintText: 'Optional',
              hintStyle: TextStyle(
                color: AppColors.fIconAndLabelText,
                fontSize: 14,
                letterSpacing: -0.2,
              ),
              filled: false,
              fillColor: AppColors.fTransparent,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
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
                color: AppColors.fWhite,
                borderRadius: BorderRadius.circular(10.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.fTextH1.withValues(alpha: 0.25),
                    offset: const Offset(0, 4),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Material(
                color: AppColors.fTransparent,
                child: InkWell(
                  onTap: _isLoading ? null : () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Center(
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColors.fRedBright,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.172,
                        ),
                      ),
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
                    color: AppColors.fTextH1.withValues(alpha: 0.25),
                    offset: const Offset(0, 4),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Material(
                color: AppColors.fTransparent,
                child: InkWell(
                  onTap: _isLoading ? null : _saveItem,
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: _isLoading
                        ? Center(
                            child: SizedBox(
                              width: 16.w,
                              height: 16.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.fWhite,
                                ),
                              ),
                            ),
                          )
                        : Row(
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
