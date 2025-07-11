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
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: AppColors.fWhite,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4.r,
            offset: Offset(0, 4.h),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date header - exact match to Figma
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Text(
              _formatDate(date),
              style: TextStyle(
                color: AppColors.fYellow,
                fontSize: 12.sp,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Total Orders row - exact match to Figma
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Orders',
                  style: TextStyle(
                    color: AppColors.fTextH2,
                    fontSize: 12.sp,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  totalVotes.toString(),
                  style: TextStyle(
                    color: AppColors.fRed2,
                    fontSize: 16.sp,
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Divider after Total Orders - exact match to Figma
          Container(
            height: 1.h,
            color: AppColors.fLineaAndLabelBox,
          ),

          SizedBox(height: 16.h),

          // Menu items list with exact Figma styling and dividers
          ...options.asMap().entries.map((entry) {
            int index = entry.key;
            String option = entry.value;
            int orderCount = votes[option]?.length ?? 0;

            return Column(
              children: [
                _buildOrderItem(option, orderCount),
                if (index <
                    options.length - 1) // Add divider except for last item
                  Container(
                    height: 1.h,
                    color: AppColors.fLineaAndLabelBox,
                    margin: EdgeInsets.only(top: 12.h, bottom: 12.h),
                  ),
              ],
            );
          }),

          SizedBox(height: 20.h),

          // Action buttons with icons - exact match to Figma
          Padding(
            padding: EdgeInsets.all(8.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // View button with eye icon
                _buildActionButton(
                  text: 'View',
                  icon: Icons.visibility_outlined,
                  color: AppColors.fBlue,
                  backgroundColor: AppColors.fLineaAndLabelBox,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PollVotesPage(pollData: pollData),
                      ),
                    );
                  },
                ),

                // Edit or Delete button with appropriate icon
                _buildActionButton(
                  text: isActive ? 'Edit' : 'Delete',
                  icon: isActive ? Icons.edit_outlined : Icons.delete_outline,
                  color: isActive ? AppColors.fYellow : AppColors.fRedBright,
                  backgroundColor: AppColors.fLineaAndLabelBox,
                  onTap: isActive
                      ? () {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                EditPollDialog(pollData: pollData),
                          );
                        }
                      : () => _deletePoll(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(String option, int orderCount) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          // Bullet point - exact match to Figma (black solid circle)
          Container(
            width: 4.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.fTextH1,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12.w),

          // Menu item name
          Expanded(
            child: Text(
              option,
              style: TextStyle(
                color: AppColors.fTextH2,
                fontSize: 14.sp,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Order count in gray rounded background - exact match to Figma
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppColors.fLineaAndLabelBox,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              '$orderCount order${orderCount != 1 ? 's' : ''}',
              style: TextStyle(
                color: AppColors.fIconAndLabelText,
                fontSize: 10.sp,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 12.sp,
            ),
            SizedBox(width: 6.w),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 10.sp,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
