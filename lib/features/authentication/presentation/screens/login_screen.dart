import 'package:flutter/material.dart';
import 'package:teton_meal_app/app/app_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:teton_meal_app/features/authentication/presentation/screens/user_registration_screen.dart';
import 'package:teton_meal_app/features/authentication/presentation/widgets/login_form_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 64.h),
                    Center(
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: SizedBox(
                          height: 113.11.h,
                          width: 110.03.w,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.r),
                            child: Image.asset(
                              'assets/images/food-delivery.png',
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Welcome back',
                      style: AppFonts.h1,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'sign in to access your account',
                      textAlign: TextAlign.center,
                      style: AppFonts.bodyLight,
                    ),
                    SizedBox(height: 32.h),
                    const LoginFormWidget(),
                    SizedBox(height: 16.h),
                    // Registration link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: AppFonts.labelMedium,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UserRegister(),
                              ),
                            );
                          },
                          child: Text(
                            "Register here",
                            style: AppFonts.linkRegular,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 28.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
