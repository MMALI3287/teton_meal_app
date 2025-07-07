import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../Styles/colors.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

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
                          title: '1. Acceptance of Terms',
                          content:
                              'By accessing and using the Teton Meal App, you accept and agree to be bound by the terms and provision of this agreement.',
                        ),
                        _buildSection(
                          title: '2. Use License',
                          content:
                              'Permission is granted to temporarily download one copy of the Teton Meal App for personal, non-commercial transitory viewing only.',
                        ),
                        _buildSection(
                          title: '3. Disclaimer',
                          content:
                              'The materials on Teton Meal App are provided on an \'as is\' basis. Teton makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.',
                        ),
                        _buildSection(
                          title: '4. Limitations',
                          content:
                              'In no event shall Teton or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials on Teton Meal App, even if Teton or an authorized representative has been notified orally or in writing of the possibility of such damage.',
                        ),
                        _buildSection(
                          title: '5. Revisions and Errata',
                          content:
                              'The materials appearing on Teton Meal App could include technical, typographical, or photographic errors. Teton does not warrant that any of the materials on its app are accurate, complete, or current.',
                        ),
                        _buildSection(
                          title: '6. Site Terms of Use Modifications',
                          content:
                              'Teton may revise these terms of service for its app at any time without notice. By using this app, you are agreeing to be bound by the then current version of these terms of service.',
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
        Expanded(
          child: Text(
            'Terms & Conditions',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.fTextH1,
              fontFamily: 'Mulish',
            ),
            overflow: TextOverflow.ellipsis,
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
