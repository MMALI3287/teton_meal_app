import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:teton_meal_app/features/authentication/presentation/screens/login_screen.dart';
import 'package:teton_meal_app/features/user_management/presentation/screens/account_overview_screen.dart';
import 'package:teton_meal_app/features/user_management/presentation/screens/users_list_screen.dart';
import 'package:teton_meal_app/features/user_management/presentation/screens/app_about_screen.dart';
import 'package:teton_meal_app/features/user_management/presentation/screens/terms_conditions_screen.dart';
import 'package:teton_meal_app/features/user_management/presentation/screens/privacy_policy_screen.dart';
import 'package:teton_meal_app/features/reminders/presentation/screens/reminders_list_screen.dart';
import 'package:teton_meal_app/data/models/user_model.dart';
import 'package:teton_meal_app/data/services/auth_service.dart';
import 'package:teton_meal_app/app/app_theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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

  Future<void> _logout(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await AuthService().signOut();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: ${e.toString()}')),
      );
    }
  }

  Future<void> _showLogoutDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: AppColors.error),
              SizedBox(width: 10.w),
              const Text('Sign Out'),
            ],
          ),
          content:
              const Text('Are you sure you want to sign out of your account?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.tertiaryText),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryColor,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
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
                  child: Column(
                    children: [
                      _buildGeneralSection(),
                      SizedBox(height: 16.h),
                      _buildSecurityPrivacySection(),
                      SizedBox(height: 16.h),
                      _buildHelpSupportSection(),
                      SizedBox(height: 16.h),
                      _buildLogoutSection(),
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
              'Settings',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF383A3F), // F_Text_H1
              ),
            ),
          ),
        ),
        SizedBox(width: 40.w), // Balance the back button
      ],
    );
  }

  Widget _buildGeneralSection() {
    return _buildSection(
      title: 'General',
      titleColor: const Color(0xFF466D5E), // F_Green
      items: [
        _buildSectionItem(
          icon: Icons.person_outline,
          title: 'Account',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AccountPage()),
            );
          },
        ),
        _buildSectionItem(
          icon: Icons.people_outline,
          title: 'Users',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UsersPage(),
              ),
            );
          },
        ),
        _buildSectionItem(
          icon: Icons.access_time,
          title: 'Reminder',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RemindersPage(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSecurityPrivacySection() {
    return _buildSection(
      title: 'Security & Privacy',
      titleColor: const Color(0xFF7495DE), // F_Blue
      items: [
        _buildSectionItem(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PrivacyPolicyPage(),
              ),
            );
          },
        ),
        _buildSectionItem(
          icon: Icons.description_outlined,
          title: 'Terms & Condition',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TermsConditionsPage(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHelpSupportSection() {
    return _buildSection(
      title: 'Help & Support',
      titleColor: const Color(0xFFEF9F27), // F_Yellow
      items: [
        _buildSectionItem(
          icon: Icons.info_outline,
          title: 'About Us',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AboutPage(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLogoutSection() {
    return _buildSection(
      title: 'Logout',
      titleColor: const Color(0xFFFF7686), // F_Red_2
      items: [
        _buildSectionItem(
          icon: Icons.logout,
          title: 'Sign Out',
          onTap: _showLogoutDialog,
          showArrow: true,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required Color titleColor,
    required List<Widget> items,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // F_White
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withOpacity(0.07),
            blurRadius: 4.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 12.h),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: titleColor,
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
          SizedBox(height: 8.h),
          ...items,
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  Widget _buildSectionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool showArrow = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Row(
          children: [
            Container(
              width: 16.w,
              height: 16.h,
              margin: EdgeInsets.only(left: 8.w, right: 16.w),
              child: Icon(
                icon,
                color: const Color(0xFF383A3F), // F_Text_H1
                size: 16.sp,
              ),
            ),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF383A3F), // F_Text_H1
                  letterSpacing: -0.2,
                ),
              ),
            ),
            if (showArrow)
              Icon(
                Icons.chevron_right,
                color: const Color(0xFF7A869A), // F_Icon& Label_Text
                size: 16.sp,
              ),
          ],
        ),
      ),
    );
  }
}
