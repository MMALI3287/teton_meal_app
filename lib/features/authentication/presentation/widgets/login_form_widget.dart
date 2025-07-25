import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:teton_meal_app/app/app_theme.dart';
import 'package:teton_meal_app/app/app_fonts.dart';
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
  bool _isFormSubmitted = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _authService = AuthService();

  void _validateAndShowErrors() {
    setState(() {
      _isFormSubmitted = true;
    });

    _formKey.currentState!.validate();

    setState(() {});
  }

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
      autovalidateMode: AutovalidateMode.disabled,
      child: SizedBox(
        width: 300.w,
        child: Column(
          children: [
            Theme(
              data: Theme.of(context).copyWith(
                inputDecorationTheme: const InputDecorationTheme(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
              ),
              child: _buildTextField(
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
            ),
            SizedBox(height: 16.h),
            Theme(
              data: Theme.of(context).copyWith(
                inputDecorationTheme: const InputDecorationTheme(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
              ),
              child: _buildTextField(
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
                      color: AppColors.fIconAndLabelText,
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
            ),
            SizedBox(height: 16.h),
            Container(
              width: 296.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Transform.scale(
                        scale: 0.8,
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            // Only override what's necessary
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                          ),
                          child: Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            activeColor: AppColors.fIconAndLabelText,
                            checkColor: Colors.white,
                            fillColor: WidgetStateProperty.resolveWith<Color>(
                                (states) {
                              if (states.contains(WidgetState.selected)) {
                                return AppColors.fIconAndLabelText;
                              }
                              return Colors.transparent;
                            }),
                            side: WidgetStateBorderSide.resolveWith((states) {
                              if (states.contains(WidgetState.selected)) {
                                return BorderSide(
                                    color: AppColors.fIconAndLabelText,
                                    width: 2);
                              }
                              return BorderSide(color: Colors.grey, width: 2);
                            }),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3.r),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        'Remember me',
                        style: AppFonts.labelSmall,
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'Forget password?',
                      style: AppFonts.linkRegular,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 72.h),
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
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.fTextH1.withValues(alpha: 0.25),
                      blurRadius: 4.r,
                      offset: Offset(0, 4.h),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.fWhite,
                    backgroundColor: AppColors.fRedBright,
                    disabledBackgroundColor: AppColors.fRedBright,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20.h,
                          width: 20.w,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(AppColors.fWhite),
                            strokeWidth: 2.5.w,
                          ),
                        )
                      : Text(
                          "Sign In",
                          style: AppFonts.buttonMedium,
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
    final fieldKey = GlobalKey<FormFieldState>();

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 50.h,
            width: 300.w,
            decoration: BoxDecoration(
              color: AppColors.fLineaAndLabelBox,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: TextFormField(
              key: fieldKey,
              controller: controller,
              obscureText: obscure,
              validator: validator,
              autovalidateMode: AutovalidateMode.disabled,
              style: TextStyle(fontSize: 14.sp, color: AppColors.fTextH1),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                    fontSize: 14.sp, color: AppColors.fIconAndLabelText),
                suffixIcon: hint == 'Password'
                    ? suffixIcon
                    : Container(
                        padding: EdgeInsets.all(13.w),
                        child: Icon(
                          icon,
                          color: AppColors.fIconAndLabelText,
                          size: 20.sp,
                        ),
                      ),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15.h, horizontal: 22.w),
                fillColor: AppColors.fTransparent,
                filled: true,
                focusedBorder: InputBorder.none,
                errorStyle: const TextStyle(
                  height: 0,
                  fontSize: 0,
                  color: AppColors.fTransparent,
                ),
              ),
              cursorColor: AppColors.fRedBright,
            ),
          ),
          Builder(
            builder: (context) {
              if (_isFormSubmitted) {
                final errorText = validator(controller.text);
                if (errorText != null) {
                  return Padding(
                    padding: EdgeInsets.only(left: 12.w, top: 4.h),
                    child: Text(
                      errorText,
                      style: TextStyle(
                        color: AppColors.fRedBright,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
              }
              return SizedBox(height: 4.h);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    _validateAndShowErrors();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.signIn(
        emailController.text,
        passwordController.text,
      );

      if (mounted) {
        final userName = user?.displayName ?? 'User';

        await CustomExceptionDialog.showWelcome(
          context: context,
          userName: userName,
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
                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
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
      }
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
