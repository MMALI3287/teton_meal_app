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
              Icon(Icons.logout, color: AppColors.fRed2),
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
                style: TextStyle(color: AppColors.fIconAndLabelText),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.fRed2,
                foregroundColor: AppColors.fWhite,
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
              SizedBox(height: 12.h),
              _buildHeader(),
              SizedBox(height: 8.h),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.fWhite,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24.r),
                      topRight: Radius.circular(24.r),
                      bottomLeft: Radius.circular(8.r),
                      bottomRight: Radius.circular(24.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.fTextH1.withValues(alpha: 0.05),
                        blurRadius: 4.r,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 8.h),
                        _buildGeneralSection(),
                        SizedBox(height: 8.h),
                        _buildSecurityPrivacySection(),
                        SizedBox(height: 8.h),
                        _buildHelpSupportSection(),
                        SizedBox(height: 8.h),
                        _buildLogoutSection(),
                        SizedBox(height: 24.h),
                      ],
                    ),
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
        Expanded(
          child: Text(
            'Settings',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.fTextH1,
              letterSpacing: -0.12,
              fontFamily: 'Work Sans',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralSection() {
    return _buildSection(
      title: 'General',
      titleColor: AppColors.fGreen,
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
          icon: Icons.schedule_outlined,
          title: 'Reminders',
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
      titleColor: AppColors.fBlue,
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
      titleColor: AppColors.fYellow,
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
      titleColor: AppColors.fRed2,
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
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.fWhite,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: titleColor,
                letterSpacing: -0.2,
                fontFamily: 'DM Sans',
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            height: 1.h,
            margin: EdgeInsets.symmetric(horizontal: 24.w),
            color: AppColors.fLineaAndLabelBox,
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Column(
              children: items,
            ),
          ),
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
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20.w,
                    height: 20.h,
                    alignment: Alignment.center,
                    child: Icon(
                      icon,
                      color: AppColors.fTextH1,
                      size: 14.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.fTextH1,
                        letterSpacing: -0.2,
                        fontFamily: 'DM Sans',
                      ),
                    ),
                  ),
                  if (showArrow)
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.fIconAndLabelText,
                      size: 10.sp,
                    ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 1.h,
            color: AppColors.fLineaAndLabelBox,
          ),
        ],
      ),
    );
  }
}
