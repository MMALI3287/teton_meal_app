import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:teton_meal_app/data/models/user_model.dart';
import 'package:teton_meal_app/app/app_theme.dart';

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
              _buildProfileHeader(),
              SizedBox(height: 32.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildGeneralSection(),
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

  Widget _buildProfileHeader() {
    return Column(
      children: [
        // Profile picture
        Container(
          width: 80.w,
          height: 80.h,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.3),
                blurRadius: 8.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Center(
            child: Text(
              _getInitials(),
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        // Name
        Text(
          user?.displayName ?? 'User Name',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF383A3F), // F_Text_H1
            letterSpacing: -0.28,
          ),
        ),
        SizedBox(height: 4.h),
        // Email
        Text(
          user?.email ?? 'user@example.com',
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w300,
            color: const Color(0xFF383A3F), // F_Text_H1
            decoration: TextDecoration.underline,
          ),
        ),
        SizedBox(height: 8.h),
        // Role badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F5F7), // F_Linea_&_LabelBox
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            user?.role ?? 'User',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF7A869A), // F_Icon& Label_Text
              letterSpacing: -0.24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // F_White
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withOpacity(0.05),
            blurRadius: 4.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              'General',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF466D5E), // F_Green
                letterSpacing: -0.2,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            height: 1.h,
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            color: const Color(0xFFF4F5F7), // F_Linea_&_LabelBox
          ),
          SizedBox(height: 16.h),
          _buildProfileItem(
            icon: Icons.person_outline,
            title: 'Name',
            value: user?.displayName ?? 'User Name',
            onEdit: () {
              _showEditDialog('Name', user?.displayName ?? '');
            },
          ),
          _buildDivider(),
          _buildProfileItem(
            icon: Icons.email_outlined,
            title: 'Email',
            value: user?.email ?? 'user@example.com',
            onEdit: () {
              _showEditDialog('Email', user?.email ?? '');
            },
          ),
          _buildDivider(),
          _buildProfileItem(
            icon: Icons.account_circle_outlined,
            title: 'Account Type',
            value: user?.role ?? 'User',
            onEdit: () {
              _showEditDialog('Account Type', user?.role ?? '');
            },
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onEdit,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          Container(
            width: 18.w,
            height: 18.h,
            margin: EdgeInsets.only(left: 8.w, right: 12.w),
            child: Icon(
              icon,
              color: const Color(0xFF383A3F), // F_Text_H1
              size: 18.sp,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF383A3F), // F_Text_H1
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF7A869A), // F_Icon& Label_Text
                    letterSpacing: -0.24,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            child: Container(
              width: 18.w,
              height: 18.h,
              child: Icon(
                Icons.edit_outlined,
                color: const Color(0xFF7A869A), // F_Icon& Label_Text
                size: 18.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Divider(
        height: 1.h,
        thickness: 1,
        color: const Color(0xFFF4F5F7), // F_Linea_&_LabelBox
      ),
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

  String _getInitials() {
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      final names = user!.displayName!.split(' ');
      final initials =
          names.map((name) => name.isNotEmpty ? name[0] : '').join();
      return initials.length > 2 ? initials.substring(0, 2) : initials;
    }
    return 'U';
  }
}
