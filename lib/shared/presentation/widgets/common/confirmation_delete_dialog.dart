import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:teton_meal_app/app/app_theme.dart';

class CustomDeleteDialog extends StatelessWidget {
  final String title;
  final String message;
  final String itemName;
  final VoidCallback onDelete;

  const CustomDeleteDialog({
    super.key,
    required this.title,
    required this.message,
    required this.itemName,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
            // Warning Icon
            Container(
              width: 60.w,
              height: 60.h,
              decoration: BoxDecoration(
                color: AppColors.fRedBright.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_outlined,
                color: AppColors.fRedBright,
                size: 32.sp,
              ),
            ),
            SizedBox(height: 20.h),

            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.fTextH1,
                fontFamily: 'Mulish',
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),

            // Message
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
                  TextSpan(text: message),
                  TextSpan(
                    text: ' "$itemName"',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.fTextH1,
                    ),
                  ),
                  const TextSpan(text: '?\n\nThis action cannot be undone.'),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // Buttons
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: 48.h,
                      decoration: BoxDecoration(
                        color:
                            AppColors.fIconAndLabelText.withValues(alpha: 0.1),
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

                // Delete Button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      onDelete();
                    },
                    child: Container(
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: AppColors.fRedBright,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.fRedBright.withValues(alpha: 0.3),
                            blurRadius: 8.r,
                            offset: Offset(0, 4.h),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Delete',
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
  }
}
