import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:teton_meal_app/app/app_theme.dart';
import 'package:teton_meal_app/app/app_fonts.dart';
import 'package:teton_meal_app/shared/presentation/widgets/common/custom_exception_dialog.dart';
import 'package:teton_meal_app/data/services/auth_service.dart';
import 'package:teton_meal_app/features/authentication/presentation/screens/login_screen.dart';

class RegistrationFormWidget extends StatefulWidget {
  final String? profileImageUrl;
  final bool isAdminRegistration;

  const RegistrationFormWidget({
    super.key,
    this.profileImageUrl,
    this.isAdminRegistration = false,
  });

  @override
  State<RegistrationFormWidget> createState() => _RegistrationFormWidgetState();
}

class _RegistrationFormWidgetState extends State<RegistrationFormWidget> {
  bool showProgress = false;
  bool _isFormSubmitted = false;

  final _formkey = GlobalKey<FormState>();
  final _authService = AuthService();

  void _validateAndShowErrors() {
    setState(() {
      _isFormSubmitted = true;
    });

    _formkey.currentState!.validate();

    setState(() {});
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpassController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  bool _isObscure = true;
  bool _isObscure2 = true;
  bool _agreedToTerms = false;
  String? role;
  var rool = ["Diner", "Planner", "Admin"];
  String? department;
  var departmentOptions = ["Software", "Hardware", "Operations"];

  @override
  void dispose() {
    nameController.dispose();
    passwordController.dispose();
    confirmpassController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formkey,
      autovalidateMode: AutovalidateMode.disabled,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildTextField(
              controller: nameController,
              hint: 'Name :',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            _buildTextField(
              controller: emailController,
              hint: 'Email :',
              icon: Icons.email_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter email';
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
              controller: TextEditingController(
                  text: department ?? 'Select Department'),
              hint: 'Department :',
              icon: Icons.business_outlined,
              readOnly: true,
              onTap: () => _showDepartmentPicker(context),
              validator: (value) {
                if (department == null || department!.isEmpty) {
                  return 'Please select your department';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            _buildTextField(
              controller: passwordController,
              hint: 'Password :',
              icon: Icons.lock_outline,
              obscureText: _isObscure,
              suffixIcon: IconButton(
                icon: Icon(
                  _isObscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.fIconAndLabelText,
                  size: 20.sp,
                ),
                onPressed: () {
                  setState(() {
                    _isObscure = !_isObscure;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            _buildTextField(
              controller: confirmpassController,
              hint: 'Confirm Password :',
              icon: Icons.lock_outline,
              obscureText: _isObscure2,
              suffixIcon: IconButton(
                icon: Icon(
                  _isObscure2
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.fIconAndLabelText,
                  size: 20.sp,
                ),
                onPressed: () {
                  setState(() {
                    _isObscure2 = !_isObscure2;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm password';
                }
                if (value != passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            _buildTextField(
              controller: TextEditingController(text: role ?? 'Select Role'),
              hint: 'Account Type :',
              icon: Icons.person_outline,
              readOnly: true,
              onTap: () => _showRolePicker(context),
              validator: (value) {
                if (role == null || role!.isEmpty) {
                  return 'Please select your role';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 18.w,
                    height: 18.h,
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(top: 2.h),
                    child: Transform.scale(
                      scale: 0.8,
                      child: Checkbox(
                        value: _agreedToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreedToTerms = value!;
                          });
                        },
                        activeColor: AppColors.fRedBright,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Mulish',
                            color: AppColors.fTextH1,
                            height: 1.4,
                          ),
                          children: [
                            const TextSpan(
                                text: 'By checking the box you agree to our '),
                            TextSpan(
                              text: 'Terms',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.fRed2,
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Conditions',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.fRed2,
                              ),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Container(
              width: 300.w,
              height: 50.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.fTextH1.withValues(alpha: 0.25),
                    blurRadius: 4.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: showProgress
                    ? null
                    : () {
                        _validateAndShowErrors();

                        if (_formkey.currentState!.validate()) {
                          signUp(emailController.text, passwordController.text,
                              role);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.fRedBright,
                  foregroundColor: AppColors.fWhite,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 0,
                ),
                child: showProgress
                    ? SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: CircularProgressIndicator(
                          color: AppColors.fWhite,
                          strokeWidth: 2.w,
                        ),
                      )
                    : Text(
                        'Register',
                        style: AppFonts.buttonMedium,
                      ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  void signUp(String email, String password, String? roleParam) async {
    if (!_agreedToTerms) {
      CustomExceptionDialog.showWarning(
        context: context,
        title: "Agreement Required",
        message: "Please agree to terms and conditions",
      );
      return;
    }

    if (roleParam == null || department == null) {
      CustomExceptionDialog.showWarning(
        context: context,
        title: "Selection Required",
        message: "Please select both department and role",
      );
      return;
    }

    setState(() {
      showProgress = true;
    });
    try {
      if (widget.isAdminRegistration) {
        await _authService.adminRegister(
          email,
          password,
          roleParam,
          name: nameController.text.trim(),
          department: department!,
        );
      } else {
        await _authService.register(
          email,
          password,
          roleParam,
          name: nameController.text.trim(),
          department: department!,
          profileImageUrl: widget.profileImageUrl,
        );
      }

      CustomExceptionDialog.showSuccess(
        context: context,
        title: "Success",
        message: widget.isAdminRegistration
            ? "Admin account created successfully! You can now log in."
            : "Account created successfully! Please wait for admin approval before logging in.",
      );

      setState(() {
        showProgress = false;
      });

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      CustomExceptionDialog.showError(
        context: context,
        title: "Registration Failed",
        message: e.toString().replaceAll('Exception: ', ''),
      );

      setState(() {
        showProgress = false;
      });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
    bool obscureText = false,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    final fieldKey = GlobalKey<FormFieldState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 50.h,
          width: 345.w,
          decoration: BoxDecoration(
            color: AppColors.fWhite,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.fTextH1.withValues(alpha: 0.05),
                blurRadius: 4.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: TextFormField(
            key: fieldKey,
            controller: controller,
            obscureText: obscureText,
            readOnly: readOnly,
            onTap: onTap,
            validator: validator,
            autovalidateMode: AutovalidateMode.disabled,
            style: TextStyle(
              fontSize: 14.sp,
              fontFamily: 'Mulish',
              color: AppColors.fTextH1,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: AppColors.fIconAndLabelText,
                fontSize: 14.sp,
                fontFamily: 'Mulish',
                fontWeight: FontWeight.w400,
              ),
              suffixIcon: suffixIcon ??
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Icon(
                      icon,
                      color: AppColors.fIconAndLabelText,
                      size: 20.sp,
                    ),
                  ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide.none,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide.none,
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
              filled: true,
              fillColor: AppColors.fWhite,
              errorStyle: const TextStyle(
                height: 0,
                fontSize: 0,
                color: Colors.transparent,
              ),
            ),
          ),
        ),
        Builder(
          builder: (context) {
            if (_isFormSubmitted && validator != null) {
              final errorText = validator(controller.text);
              if (errorText != null) {
                return Padding(
                  padding: EdgeInsets.only(left: 16.w, top: 4.h),
                  child: Text(
                    errorText,
                    style: TextStyle(
                      color: AppColors.fRedBright,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Mulish',
                    ),
                  ),
                );
              }
            }
            return SizedBox(height: 4.h);
          },
        ),
      ],
    );
  }

  void _showRolePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.fWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Select Role',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Mulish',
                    color: AppColors.fTextH1,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              ...rool.map((roleOption) => ListTile(
                    title: Text(
                      roleOption,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontFamily: 'Mulish',
                        color: AppColors.fTextH1,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        role = roleOption;
                      });
                      Navigator.pop(context);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }

  void _showDepartmentPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.fWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Select Department',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Mulish',
                    color: AppColors.fTextH1,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              ...departmentOptions.map((dept) => ListTile(
                    title: Text(
                      dept,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontFamily: 'Mulish',
                        color: AppColors.fTextH1,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        department = dept;
                      });
                      Navigator.pop(context);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }
}
