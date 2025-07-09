import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:teton_meal_app/app/app_theme.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fWhiteBackground,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            children: [
              _buildHeader(context),
              SizedBox(height: 32.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: AppColors.fWhite,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSection(
                          title: 'Information We Collect',
                          content:
                              'We collect information you provide directly to us, such as when you create an account, update your profile, place an order, or contact us for support. This may include your name, email address, department, and dietary preferences.',
                        ),
                        _buildSection(
                          title: 'How We Use Your Information',
                          content:
                              'We use the information we collect to provide, maintain, and improve our services, including to process orders, send notifications about meal availability, and provide customer support.',
                        ),
                        _buildSection(
                          title: 'Information Sharing',
                          content:
                              'We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except as described in this privacy policy or as required by law.',
                        ),
                        _buildSection(
                          title: 'Data Security',
                          content:
                              'We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. However, no method of transmission over the internet is 100% secure.',
                        ),
                        _buildSection(
                          title: 'Data Retention',
                          content:
                              'We retain your personal information for as long as necessary to provide our services, comply with legal obligations, resolve disputes, and enforce our agreements.',
                        ),
                        _buildSection(
                          title: 'Your Rights',
                          content:
                              'You have the right to access, update, or delete your personal information. You may also opt out of certain communications from us. To exercise these rights, please contact us through the app.',
                        ),
                        _buildSection(
                          title: 'Changes to Privacy Policy',
                          content:
                              'We may update this privacy policy from time to time. We will notify you of any changes by posting the new privacy policy within the app. Your continued use of the app after such changes constitutes acceptance of the updated policy.',
                        ),
                        _buildSection(
                          title: 'Contact Us',
                          content:
                              'If you have any questions about this privacy policy or our data practices, please contact us through the app\'s support feature.',
                        ),
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: AppColors.fIconAndLabelText,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.fWhite,
              size: 20.sp,
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Text(
          'Privacy Policy',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.fTextH1,
            fontFamily: 'Mulish',
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.fTextH1,
              fontFamily: 'Mulish',
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            content,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.fIconAndLabelText,
              fontFamily: 'Mulish',
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
