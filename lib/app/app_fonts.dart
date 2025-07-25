import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teton_meal_app/app/app_theme.dart';

class AppFonts {
  static TextStyle h1 = TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.w800,
    fontFamily: 'Mulish',
    color: AppColors.fTextH1,
  );

  static TextStyle h2 = GoogleFonts.workSans(
    fontSize: 24.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.fTextH1,
    letterSpacing: -0.12,
  );

  static TextStyle bodyRegular = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w300,
    fontFamily: 'Mulish',
    color: AppColors.fTextH1,
  );

  static TextStyle bodyLight = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w300,
    fontFamily: 'Mulish',
    color: AppColors.fTextH1,
  );

  static TextStyle labelMedium = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    fontFamily: 'Mulish',
    color: AppColors.fIconAndLabelText,
  );

  static TextStyle labelSmall = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    fontFamily: 'Mulish',
    color: AppColors.fIconAndLabelText,
  );

  static TextStyle buttonLarge = TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    fontFamily: 'DMSans',
    color: AppColors.fWhite,
  );

  static TextStyle buttonMedium = TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    fontFamily: 'DMSans',
    color: AppColors.fWhite,
  );

  static TextStyle linkRegular = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    fontFamily: 'DMSans',
    color: AppColors.fRedBright,
  );

  static TextStyle linkSmall = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    fontFamily: 'DMSans',
    color: AppColors.fRed2,
  );

  static TextStyle linkSmallSemiBold = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    fontFamily: 'DMSans',
    color: AppColors.fRed2,
  );
}
