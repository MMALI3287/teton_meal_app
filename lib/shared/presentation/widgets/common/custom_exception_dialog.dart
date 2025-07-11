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
  final bool showButton;

  const CustomExceptionDialog({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.error_outline,
    this.iconColor = AppColors.fRedBright,
    this.buttonText = 'OK',
    this.onButtonPressed,
    this.showButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.fTransparent,
      child: Container(
        width: 320.w,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppColors.fWhite,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.fTextH1.withValues(alpha: 0.1),
              blurRadius: 20.r,
              offset: Offset(0, 10.h),
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
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 30.sp,
              ),
            ),
            SizedBox(height: 20.h),
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
            if (showButton)
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
                        color: iconColor.withValues(alpha: 0.3),
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
          iconColor: AppColors.fRedBright,
          buttonText: buttonText,
          onButtonPressed: onButtonPressed,
        );
      },
    );
  }

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
          iconColor: AppColors.fYellow,
          buttonText: buttonText,
          onButtonPressed: onButtonPressed,
        );
      },
    );
  }

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
          iconColor: AppColors.saveGreen,
          buttonText: buttonText,
          onButtonPressed: onButtonPressed,
        );
      },
    );
  }

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
          iconColor: AppColors.fCyan,
          buttonText: buttonText,
          onButtonPressed: onButtonPressed,
        );
      },
    );
  }

  static Future<void> showWelcome({
    required BuildContext context,
    required String userName,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 1), () {
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
        });

        return AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.elasticOut,
          child: CustomExceptionDialog(
            title: 'Welcome $userName!',
            message: 'Welcome to Teton Meal App!',
            icon: Icons.check_circle_outline,
            iconColor: AppColors.saveGreen,
            buttonText: 'Continue',
            onButtonPressed: null,
            showButton: false,
          ),
        );
      },
    );
  }
}
