import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:teton_meal_app/data/models/user_model.dart';
import 'package:teton_meal_app/data/services/auth_service.dart';
import 'package:teton_meal_app/app/app_theme.dart';
import 'package:teton_meal_app/features/user_management/presentation/widgets/user_profile_card.dart';

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
      user = AuthService().currentUser;
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
        backgroundColor: Color(0xFFF9F9F9), // F_WhiteBackground
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryColor,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // F_WhiteBackground
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
                    onEditAccountType: () =>
                        _showEditDialog('Account Type', user?.role ?? ''),
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
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.inputBorderColor.withOpacity(0.5),
              ),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.primaryText,
              size: 20.sp,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              'Profile',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF383A3F), // F_Text_H1
                letterSpacing: -0.12,
              ),
            ),
          ),
        ),
        SizedBox(width: 40.w), // Balance the back button
      ],
    );
  }

  void _showEditDialog(String field, String currentValue) {
    final TextEditingController controller =
        TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text('Edit $field'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: field,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.tertiaryText),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Here you would typically update the user data
                // For now, we'll just close the dialog
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$field updated successfully'),
                    backgroundColor: AppColors.primaryColor,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
