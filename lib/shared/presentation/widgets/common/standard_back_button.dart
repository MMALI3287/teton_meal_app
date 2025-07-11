import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:teton_meal_app/app/app_theme.dart';

class StandardBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double? size;

  const StandardBackButton({
    super.key,
    this.onPressed,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final buttonSize = size ?? 40.w;

    return GestureDetector(
      onTap: onPressed ?? () => Navigator.of(context).pop(),
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: AppColors.textH1(context),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          Icons.arrow_back_ios_new,
          color: AppColors.white(context),
          size: (buttonSize * 0.45).sp,
        ),
      ),
    );
  }
}
