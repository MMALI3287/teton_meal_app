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
    final buttonSize = size ?? 42.w;

    return GestureDetector(
      onTap: onPressed ?? () => Navigator.of(context).pop(),
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: AppColors.fTextH1,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 3.33,
              offset: Offset(0, 3.33),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Icon(
          Icons.arrow_back_ios_new,
          color: AppColors.fWhite,
          size: (buttonSize * 0.45).sp,
        ),
      ),
    );
  }
}
