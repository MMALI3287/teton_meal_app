import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teton_meal_app/app/app_theme.dart';
import 'package:teton_meal_app/shared/presentation/widgets/common/confirmation_delete_dialog.dart';
import 'package:teton_meal_app/shared/presentation/widgets/common/standard_back_button.dart';

class UserDetailPage extends StatelessWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const UserDetailPage({
    super.key,
    required this.userId,
    required this.userData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fWhiteBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    _buildUserAvatar(),
                    SizedBox(height: 20.h),
                    _buildUserInfo(),
                    SizedBox(height: 20.h),
                    _buildActionButtons(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        children: [
          const StandardBackButton(),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              'User Request Details',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.fTextH1,
                fontFamily: 'Mulish',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar() {
    final name = userData['displayName'] ?? userData['name'] ?? 'Unknown User';

    return Column(
      children: [
        Container(
          width: 100.w,
          height: 100.h,
          decoration: BoxDecoration(
            color: AppColors.fNameBoxPink,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.fRedBright.withValues(alpha: 0.2),
                blurRadius: 20.r,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: TextStyle(
                fontSize: 40.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.fRedBright,
                fontFamily: 'Mulish',
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          name,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.fTextH1,
            fontFamily: 'Mulish',
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: _getRoleColor(userData['role'] ?? 'Diner')
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Text(
            userData['role'] ?? 'Diner',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: _getRoleColor(userData['role'] ?? 'Diner'),
              fontFamily: 'Mulish',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.fWhite,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.fTextH1.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Request Information',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.fTextH1,
              fontFamily: 'Mulish',
            ),
          ),
          SizedBox(height: 16.h),
          _buildInfoRow(
              Icons.email_outlined, 'Email', userData['email'] ?? 'No email'),
          SizedBox(height: 12.h),
          _buildInfoRow(Icons.business_outlined, 'Department',
              userData['department'] ?? 'No department'),
          SizedBox(height: 12.h),
          _buildInfoRow(
              Icons.person_outline, 'Role', userData['role'] ?? 'Diner'),
          SizedBox(height: 12.h),
          _buildInfoRow(
            Icons.schedule_outlined,
            'Requested',
            _formatDate(userData['createdAt'] as Timestamp?),
          ),
          SizedBox(height: 12.h),
          _buildInfoRow(
            Icons.verified_outlined,
            'Status',
            userData['isVerified'] == true
                ? 'Verified'
                : 'Pending Verification',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32.w,
          height: 32.h,
          decoration: BoxDecoration(
            color: AppColors.fIconAndLabelText.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            color: AppColors.fIconAndLabelText,
            size: 16.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.fIconAndLabelText,
                  fontFamily: 'Mulish',
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.fTextH1,
                  fontFamily: 'Mulish',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (userData['isVerified'] == true) {
      return Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.fWhite,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.fTextH1.withValues(alpha: 0.05),
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: AppColors.saveGreen,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'This user has already been verified',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.saveGreen,
                  fontFamily: 'Mulish',
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context,
            'Reject',
            AppColors.fWhite,
            AppColors.fRedBright,
            Icons.close,
            () => _showRejectDialog(context),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _buildActionButton(
            context,
            'Approve',
            AppColors.fWhite,
            AppColors.saveGreen,
            Icons.check,
            () => _approveUser(context),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String text,
    Color textColor,
    Color backgroundColor,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withValues(alpha: 0.3),
              blurRadius: 8.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: textColor,
              size: 18.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              text,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
                fontFamily: 'Mulish',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _approveUser(BuildContext context) async {
    final confirmed = await _showApprovalDialog(context);

    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'isVerified': true});

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.fWhite),
                SizedBox(width: 8.w),
                Text('User approved successfully'),
              ],
            ),
            backgroundColor: AppColors.saveGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: AppColors.fWhite),
                SizedBox(width: 8.w),
                Text('Error approving user: $e'),
              ],
            ),
            backgroundColor: AppColors.fRedBright,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    }
  }

  Future<bool> _showApprovalDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              backgroundColor: AppColors.fTransparent,
              child: Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: AppColors.fWhite,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.fTextH1.withValues(alpha: 0.1),
                      blurRadius: 20.r,
                      offset: Offset(0, 8.h),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 60.w,
                      height: 60.h,
                      decoration: BoxDecoration(
                        color: AppColors.saveGreen.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle_outlined,
                        color: AppColors.saveGreen,
                        size: 32.sp,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'Approve User Request',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.fTextH1,
                        fontFamily: 'Mulish',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.fIconAndLabelText,
                          fontFamily: 'Mulish',
                          height: 1.4,
                        ),
                        children: [
                          const TextSpan(
                              text: 'Are you sure you want to approve '),
                          TextSpan(
                            text: '"${userData['name'] ?? 'Unknown User'}"',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.fTextH1,
                            ),
                          ),
                          const TextSpan(
                              text:
                                  '?\n\nThis will grant them access to the app.'),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.h),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(false),
                            child: Container(
                              height: 48.h,
                              decoration: BoxDecoration(
                                color: AppColors.fIconAndLabelText
                                    .withValues(alpha: 0.1),
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
                            onTap: () => Navigator.of(context).pop(true),
                            child: Container(
                              height: 48.h,
                              decoration: BoxDecoration(
                                color: AppColors.saveGreen,
                                borderRadius: BorderRadius.circular(12.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.saveGreen
                                        .withValues(alpha: 0.3),
                                    blurRadius: 8.r,
                                    offset: Offset(0, 4.h),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  'Approve',
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
                  ],
                ),
              ),
            );
          },
        ) ??
        false;
  }

  void _showRejectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDeleteDialog(
          title: 'Reject User Request',
          message: 'Are you sure you want to reject this user request for ',
          itemName: userData['name'] ?? 'Unknown User',
          onDelete: () => _rejectUser(context),
        );
      },
    );
  }

  void _rejectUser(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();

      if (context.mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.delete, color: AppColors.fWhite),
                SizedBox(width: 8.w),
                Text('User request rejected'),
              ],
            ),
            backgroundColor: AppColors.fRedBright,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: AppColors.fWhite),
                SizedBox(width: 8.w),
                Text('Error rejecting user: $e'),
              ],
            ),
            backgroundColor: AppColors.fRedBright,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return AppColors.fRedBright;
      case 'planner':
        return AppColors.fYellow;
      case 'diner':
      default:
        return AppColors.fIconAndLabelText;
    }
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown';

    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
