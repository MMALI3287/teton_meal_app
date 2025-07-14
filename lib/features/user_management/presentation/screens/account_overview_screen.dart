import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:teton_meal_app/data/models/user_model.dart';
import 'package:teton_meal_app/data/services/auth_service.dart';
import 'package:teton_meal_app/app/app_theme.dart';
import 'package:teton_meal_app/features/user_management/presentation/widgets/user_profile_card.dart';
import 'package:teton_meal_app/shared/presentation/widgets/common/standard_back_button.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  UserModel? user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final authService = AuthService();
      user = authService.currentUser;

      if (user == null) {
        await Future.delayed(const Duration(milliseconds: 100));
        user = authService.currentUser;
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.fWhiteBackground,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.fRedBright,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.fWhiteBackground,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              SizedBox(height: 16.h),
              _buildHeader(),
              SizedBox(height: 24.h),
              Expanded(
                child: SingleChildScrollView(
                  child: UserProfileCard(
                    user: user,
                    onEditName: () =>
                        _showEditDialog('Name', user?.displayName ?? ''),
                    onEditEmail: () =>
                        _showEditDialog('Email', user?.email ?? ''),
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
    return Row(
      children: [
        const StandardBackButton(),
        Expanded(
          child: Center(
            child: Text(
              'Profile',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.fTextH1,
                letterSpacing: -0.12,
              ),
            ),
          ),
        ),
        SizedBox(width: 40.w),
      ],
    );
  }

  void _showEditDialog(String field, String currentValue) {
    final TextEditingController controller =
        TextEditingController(text: currentValue);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.fTransparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.fWhite,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit $field',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.fTextH1,
                        fontFamily: 'Mulish',
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 32.w,
                        height: 32.h,
                        decoration: BoxDecoration(
                          color: AppColors.fLineaAndLabelBox,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.close,
                          color: AppColors.fIconAndLabelText,
                          size: 18.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.fLineaAndLabelBox,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.fIconAndLabelText.withValues(alpha: 0.2),
                      width: 1.w,
                    ),
                  ),
                  child: TextFormField(
                    controller: controller,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.fTextH1,
                      fontFamily: 'Mulish',
                    ),
                    decoration: InputDecoration(
                      labelText: field,
                      labelStyle: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.fIconAndLabelText,
                        fontFamily: 'Mulish',
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 16.h,
                      ),
                    ),
                    autofocus: true,
                  ),
                ),
                SizedBox(height: 32.h),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: AppColors.fLineaAndLabelBox,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Center(
                            child: Text(
                              'Cancel',
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
                        onTap: () async {
                          if (user != null &&
                              controller.text.trim().isNotEmpty) {
                            try {
                              if (field == 'Name') {
                                await AuthService().updateUserProfile(
                                  uid: user!.uid,
                                  displayName: controller.text.trim(),
                                );
                              } else if (field == 'Email') {
                                await AuthService().updateUserProfile(
                                  uid: user!.uid,
                                  email: controller.text.trim(),
                                );
                              }

                              await _loadUserData();

                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('$field updated successfully'),
                                  backgroundColor: AppColors.saveGreen,
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.all(16.w),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                              );
                            } catch (e) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Failed to update $field: ${e.toString()}'),
                                  backgroundColor: AppColors.fRedBright,
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.all(16.w),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                              );
                            }
                          } else {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    const Text('Please enter a valid value'),
                                backgroundColor: AppColors.fRedBright,
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.all(16.w),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                            );
                          }
                        },
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
                              'Save Changes',
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
                SizedBox(height: 16.h),
              ],
            ),
          ),
        );
      },
    );
  }
}
