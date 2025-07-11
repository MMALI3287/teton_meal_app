import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:teton_meal_app/app/app_theme.dart';
import 'package:teton_meal_app/app/app_fonts.dart';
import 'package:teton_meal_app/features/authentication/presentation/widgets/registration_form_widget.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fWhiteBackground,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 42.w,
                      height: 42.h,
                      decoration: BoxDecoration(
                        color: AppColors.fRedBright,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.fWhite,
                        size: 18.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Text(
                    'Create Admin Account',
                    style: AppFonts.h2,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: const RegistrationFormWidget(
                  isAdminRegistration: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
