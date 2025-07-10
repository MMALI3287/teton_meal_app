import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:teton_meal_app/app/app_theme.dart';
import 'package:teton_meal_app/shared/presentation/widgets/common/confirmation_delete_dialog.dart';
import 'package:teton_meal_app/features/menu_management/presentation/screens/poll_votes_detail_screen.dart';
import 'package:teton_meal_app/shared/presentation/widgets/common/edit_poll_dialog.dart';

class MenuPollCard extends StatelessWidget {
  final QueryDocumentSnapshot pollData;

  const MenuPollCard({super.key, required this.pollData});

  Future<void> _deletePoll(BuildContext context) async {
    final data = pollData.data() as Map<String, dynamic>;
    final String pollDate = data['date'] ?? 'Unknown Date';

    showDialog(
      context: context,
      builder: (context) => CustomDeleteDialog(
        title: 'Delete Menu Poll',
        message: 'Are you sure you want to delete the menu poll for ',
        itemName: pollDate,
        onDelete: () async {
          try {
            await FirebaseFirestore.instance
                .collection('polls')
                .doc(pollData.id)
                .delete();

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Menu deleted successfully',
                    style: TextStyle(color: AppColors.fWhite),
                  ),
                  backgroundColor: AppColors.fGreen,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Error deleting menu: $e',
                    style: const TextStyle(color: AppColors.fWhite),
                  ),
                  backgroundColor: AppColors.fRed2,
                ),
              );
            }
          }
        },
      ),
    );
  }

  String _getDayWithSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return '${day}th';
    }
    switch (day % 10) {
      case 1:
        return '${day}st';
      case 2:
        return '${day}nd';
      case 3:
        return '${day}rd';
      default:
        return '${day}th';
    }
  }

  String _formatDate(String dateString) {
    try {
      final parts = dateString.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);

        final monthNames = [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December'
        ];

        String dayWithSuffix = _getDayWithSuffix(day);
        String monthName = monthNames[month - 1];

        return '$dayWithSuffix $monthName, $year';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error formatting date: $e');
      }
    }
    return dateString;
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = pollData['isActive'] ?? false;
    final data = pollData.data() as Map<String, dynamic>;
    final String date = data['date'] ?? 'No Date';
    final List<String> options = List<String>.from(data['options'] ?? []);
    final Map<String, dynamic> votes = data['votes'] ?? {};

    int totalVotes = 0;
    for (var entry in votes.entries) {
      totalVotes += (entry.value as List?)?.length ?? 0;
    }

    return Container(
      width: 348.01.w,
      margin: EdgeInsets.only(bottom: 7.89.h),
      padding: EdgeInsets.symmetric(horizontal: 15.77.w, vertical: 7.89.h),
      decoration: ShapeDecoration(
        color: AppColors.fWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.79.r),
        ),
        shadows: [
          BoxShadow(
            color: AppColors.fRedBright,
            blurRadius: 3.94.r,
            offset: Offset(0, 3.94.h),
            spreadRadius: 0,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section with date and total orders
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 7.89.h),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(date),
                      style: TextStyle(
                        color: AppColors.fYellow,
                        fontSize: 11.83.sp,
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.35,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 7.89.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Orders',
                      style: TextStyle(
                        color: AppColors.fTextH2,
                        fontSize: 11.83.sp,
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w700,
                        height: 2,
                        letterSpacing: -0.28,
                      ),
                    ),
                    Text(
                      totalVotes.toString(),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: AppColors.fRed2,
                        fontSize: 15.77.sp,
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w500,
                        height: 1.50,
                        letterSpacing: -0.28,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Divider
          Container(
            width: double.infinity,
            height: 0.99.h,
            decoration: const BoxDecoration(
              color: AppColors.fLineaAndLabelBox,
            ),
          ),
          // Menu options with order counts
          ...options.map(
              (option) => _buildOrderItem(option, votes[option]?.length ?? 0)),
          // Action buttons
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(7.89.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.fLineaAndLabelBox,
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.fRedBright,
                        blurRadius: 2.r,
                        offset: Offset(0, 1.h),
                      ),
                    ],
                  ),
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PollVotesPage(pollData: pollData),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.visibility_outlined,
                      color: AppColors.fBlue,
                      size: 12.sp,
                    ),
                    label: Text(
                      'View',
                      style: TextStyle(
                        color: AppColors.fBlue,
                        fontSize: 9.86.sp,
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w500,
                        height: 2,
                        letterSpacing: -0.24,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.fTransparent,
                      elevation: 0,
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      minimumSize: Size(0, 32.h),
                    ),
                  ),
                ),
                isActive
                    ? Container(
                        decoration: BoxDecoration(
                          color: AppColors.fLineaAndLabelBox,
                          borderRadius: BorderRadius.circular(8.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.fRedBright,
                              blurRadius: 2.r,
                              offset: Offset(0, 1.h),
                            ),
                          ],
                        ),
                        child: TextButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  EditPollDialog(pollData: pollData),
                            );
                          },
                          icon: Icon(
                            Icons.edit_outlined,
                            color: AppColors.fYellow,
                            size: 12.sp,
                          ),
                          label: Text(
                            'Edit',
                            style: TextStyle(
                              color: AppColors.fYellow,
                              fontSize: 9.86.sp,
                              fontFamily: 'DM Sans',
                              fontWeight: FontWeight.w500,
                              height: 2,
                              letterSpacing: -0.24,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.fTransparent,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 4.h),
                            minimumSize: Size(0, 32.h),
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: AppColors.fLineaAndLabelBox,
                          borderRadius: BorderRadius.circular(8.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.fRedBright,
                              blurRadius: 2.r,
                              offset: Offset(0, 1.h),
                            ),
                          ],
                        ),
                        child: TextButton.icon(
                          onPressed: () => _deletePoll(context),
                          icon: Icon(
                            Icons.delete_outline,
                            color: AppColors.fRedBright,
                            size: 12.sp,
                          ),
                          label: Text(
                            'Delete',
                            style: TextStyle(
                              color: AppColors.fRedBright,
                              fontSize: 9.86.sp,
                              fontFamily: 'DM Sans',
                              fontWeight: FontWeight.w500,
                              height: 2,
                              letterSpacing: -0.24,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.fTransparent,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 4.h),
                            minimumSize: Size(0, 32.h),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(String option, int orderCount) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 15.77.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 3.94.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 3.94.w,
                  height: 3.94.h,
                  decoration: const ShapeDecoration(
                    color: AppColors.fTextH1,
                    shape: OvalBorder(),
                  ),
                ),
                SizedBox(width: 11.83.w),
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      color: AppColors.fTextH2,
                      fontSize: 13.80.sp,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w500,
                      height: 1.43,
                      letterSpacing: -0.20,
                    ),
                  ),
                ),
                SizedBox(width: 11.83.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.fLineaAndLabelBox,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.fRedBright,
                        blurRadius: 2.r,
                        offset: Offset(0, 1.h),
                      ),
                    ],
                  ),
                  child: Text(
                    '$orderCount order${orderCount != 1 ? 's' : ''}',
                    style: TextStyle(
                      color: AppColors.fIconAndLabelText,
                      fontSize: 9.86.sp,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w500,
                      height: 2,
                      letterSpacing: -0.24,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 11.83.h),
          Container(
            width: double.infinity,
            height: 0.99.h,
            decoration: const BoxDecoration(
              color: AppColors.fLineaAndLabelBox,
            ),
          ),
        ],
      ),
    );
  }
}
