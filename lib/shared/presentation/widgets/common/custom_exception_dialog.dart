import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:teton_meal_app/app/app_theme.dart';

class CustomExceptionDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final String buttonText;
  final VoidCallback? onButtonPressed;

  const CustomExceptionDialog({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.error_outline,
    this.iconColor = Colors.red,
    this.buttonText = 'OK',
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 320.w,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppColors.fWhite,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20.r,
              offset: Offset(0, 10.h),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 60.w,
              height: 60.h,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 30.sp,
              ),
            ),
            SizedBox(height: 20.h),

            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.fTextH1,
                fontFamily: 'Mulish',
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),

            // Message
            Text(
              message,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.fIconAndLabelText,
                fontFamily: 'Mulish',
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),

            // Button
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                onButtonPressed?.call();
              },
              child: Container(
                width: double.infinity,
                height: 44.h,
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withOpacity(0.3),
                      blurRadius: 8.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.fWhite,
                      fontFamily: 'Mulish',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Static method to show error dialog
  static Future<void> showError({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onButtonPressed,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomExceptionDialog(
          title: title,
          message: message,
          icon: Icons.error_outline,
          iconColor: Colors.red,
          buttonText: buttonText,
          onButtonPressed: onButtonPressed,
        );
      },
    );
  }

  /// Static method to show warning dialog
  static Future<void> showWarning({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onButtonPressed,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomExceptionDialog(
          title: title,
          message: message,
          icon: Icons.warning_amber_rounded,
          iconColor: Colors.orange,
          buttonText: buttonText,
          onButtonPressed: onButtonPressed,
        );
      },
    );
  }

  /// Static method to show success dialog
  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onButtonPressed,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomExceptionDialog(
          title: title,
          message: message,
          icon: Icons.check_circle_outline,
          iconColor: Colors.green,
          buttonText: buttonText,
          onButtonPressed: onButtonPressed,
        );
      },
    );
  }

  /// Static method to show info dialog
  static Future<void> showInfo({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onButtonPressed,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomExceptionDialog(
          title: title,
          message: message,
          icon: Icons.info_outline,
          iconColor: Colors.blue,
          buttonText: buttonText,
          onButtonPressed: onButtonPressed,
        );
      },
    );
  }
}
