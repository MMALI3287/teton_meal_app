import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:teton_meal_app/data/models/user_model.dart';
import 'package:teton_meal_app/app/app_theme.dart';

class UserProfileCard extends StatelessWidget {
  final UserModel? user;
  final VoidCallback? onEditName;
  final VoidCallback? onEditEmail;

  const UserProfileCard({
    super.key,
    required this.user,
    this.onEditName,
    this.onEditEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildProfileHeader(),
        SizedBox(height: 32.h),
        _buildGeneralSection(),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Container(
          width: 80.w,
          height: 80.h,
          decoration: BoxDecoration(
            color: AppColors.fRedBright,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.fRedBright.withValues(alpha: 0.3),
                blurRadius: 8.r,
                offset: Offset(0, 4.h),
              ),
            ],
            image: user?.profileImageUrl != null &&
                    user!.profileImageUrl!.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(user!.profileImageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: user?.profileImageUrl == null || user!.profileImageUrl!.isEmpty
              ? Center(
                  child: Text(
                    _getInitials(),
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.fWhite,
                    ),
                  ),
                )
              : null,
        ),
        SizedBox(height: 8.h),
        Text(
          user?.displayName ?? 'User Name',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.fTextH1,
            letterSpacing: -0.28,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          user?.email ?? 'user@example.com',
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w300,
            color: AppColors.fTextH1,
            decoration: TextDecoration.underline,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: AppColors.fWhiteBackground,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            user?.role ?? 'User',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.fTextH2,
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
        color: AppColors.fWhite,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.fRedBright.withValues(alpha: 0.05),
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
                color: AppColors.fGreen,
                letterSpacing: -0.2,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            height: 1.h,
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            color: AppColors.fWhiteBackground,
          ),
          SizedBox(height: 16.h),
          _buildProfileItem(
            icon: Icons.person_outline,
            title: 'Name',
            value: user?.displayName ?? 'User Name',
            onEdit: onEditName,
          ),
          _buildDivider(),
          _buildProfileItem(
            icon: Icons.email_outlined,
            title: 'Email',
            value: user?.email ?? 'user@example.com',
            onEdit: onEditEmail,
          ),
          _buildDivider(),
          _buildProfileItem(
            icon: Icons.business_outlined,
            title: 'Department',
            value: user?.department ?? 'Not specified',
            onEdit: null,
          ),
          _buildDivider(),
          _buildProfileItem(
            icon: Icons.account_circle_outlined,
            title: 'Account Type',
            value: user?.role ?? 'User',
            onEdit: null,
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
    VoidCallback? onEdit,
  }) {
    return GestureDetector(
      onTap: onEdit,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        color: AppColors.fTransparent,
        child: Row(
          children: [
            Container(
              width: 18.w,
              height: 18.h,
              margin: EdgeInsets.only(left: 8.w, right: 12.w),
              child: Icon(
                icon,
                color: AppColors.fTextH1,
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
                      color: AppColors.fTextH1,
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.fTextH2,
                      letterSpacing: -0.24,
                    ),
                  ),
                ],
              ),
            ),
            if (onEdit != null)
              Container(
                padding: EdgeInsets.all(8.w),
                child: Icon(
                  Icons.edit_outlined,
                  color: AppColors.fTextH2,
                  size: 18.sp,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Divider(
        height: 1.h,
        thickness: 1,
        color: AppColors.fWhiteBackground,
      ),
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
