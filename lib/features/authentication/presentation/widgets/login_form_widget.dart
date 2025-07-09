import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:teton_meal_app/app/app_theme.dart';
import 'package:teton_meal_app/data/services/auth_service.dart';
import 'package:teton_meal_app/shared/presentation/widgets/common/app_navigation_bar.dart';
import 'package:teton_meal_app/shared/presentation/widgets/common/custom_exception_dialog.dart';

class LoginFormWidget extends StatefulWidget {
  const LoginFormWidget({super.key});

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _authService = AuthService();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SizedBox(
        width: 300.w,
        child: Column(
          children: [
            _buildTextField(
              controller: emailController,
              icon: Icons.email_outlined,
              hint: 'Enter your email',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            _buildTextField(
              controller: passwordController,
              icon: Icons.lock_outline,
              hint: 'Password',
              obscure: !_isPasswordVisible,
              suffixIcon: IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                    key: ValueKey(_isPasswordVisible),
                    color: AppColors.tertiaryText,
                    size: 20.sp,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 8.w,
                    ),
                    SizedBox(
                      width: 12.w,
                      height: 12.h,
                      child: Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                        activeColor: AppColors.fIconAndLabelText,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3.r),
                        ),
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      'Remember me',
                      style: TextStyle(
                        color: AppColors.fIconAndLabelText,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Mulish',
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Forgot password?',
                        style: TextStyle(
                          color: AppColors.fRed2,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Mulish',
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                  ],
                ),
              ],
            ),
            SizedBox(height: 104.h),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.9 + (0.1 * value),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Container(
                width: 300.w,
                height: 50.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.2),
                      blurRadius: 10.r,
                      offset: Offset(0, 4.h),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.white,
                    backgroundColor: AppColors.primaryColor,
                    disabledBackgroundColor: AppColors.disabledButton,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20.h,
                          width: 20.w,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(AppColors.white),
                            strokeWidth: 2.5.w,
                          ),
                        )
                      : Text(
                          "Sign In",
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontFamily: 'DMSans',
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool obscure = false,
    Widget? suffixIcon,
    required FormFieldValidator<String> validator,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 4.r,
              offset: Offset(0, 2.h),
              spreadRadius: 0,
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          style: TextStyle(fontSize: 14.sp, color: AppColors.primaryText),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                TextStyle(fontSize: 14.sp, color: AppColors.tertiaryText),
            suffixIcon: hint == 'Password'
                ? suffixIcon
                : Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Icon(
                      icon,
                      color: AppColors.tertiaryText,
                      size: 20.sp,
                    ),
                  ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: AppColors.inputBorderColor,
                width: 1.w,
              ),
            ),
            contentPadding:
                EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
            fillColor: AppColors.white,
            filled: true,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: AppColors.inputBorderColor,
                width: 1.w,
              ),
            ),
            errorStyle: const TextStyle(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          cursorColor: AppColors.primaryColor,
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signIn(
        emailController.text,
        passwordController.text,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const Navbar(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              var begin = const Offset(0.0, 1.0);
              var end = Offset.zero;
              var curve = Curves.easeOutQuint;
              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 700),
          ),
        );
      }

      CustomExceptionDialog.showSuccess(
        context: context,
        title: 'Welcome!',
        message: 'Welcome to Teton Meal App!',
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      String title = 'Sign In Failed';
      String message = '';

      final errorMessage = e.toString();
      if (errorMessage.contains('user-not-found')) {
        title = 'User Not Found';
        message =
            'No account found with this email address. Please check your email or register for a new account.';
      } else if (errorMessage.contains('incorrect-credentials')) {
        title = 'Incorrect Password';
        message = 'The password you entered is incorrect. Please try again.';
      } else if (errorMessage.contains('account-not-verified')) {
        title = 'Account Not Verified';
        message = 'Please contact the administrator to activate your account.';
      } else {
        message = 'Unable to sign in. Please try again later.';
      }

      CustomExceptionDialog.showError(
        context: context,
        title: title,
        message: message,
      );
    }
  }
}
