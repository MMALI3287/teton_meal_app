import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../Styles/colors.dart';
import '../../services/auth_service.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  _RegisterState();

  bool showProgress = false;
  bool visible = false;

  final _formkey = GlobalKey<FormState>();
  final _authService = AuthService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpassController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  bool _isObscure = true;
  bool _isObscure2 = true;
  bool _agreedToTerms = false;
  var role = "Diner";
  var _currentItemSelected = "Diner";
  var rool = ["Diner", "Planner", "Admin"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fWhiteBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Top navigation bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.fTextH1,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Add User',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.fTextH1,
                      letterSpacing: -0.12,
                    ),
                  ),
                ],
              ),
            ),
            // Profile picture section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.fWhite,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: AppColors.fIconAndLabelText,
                  size: 32,
                ),
              ),
            ),
            // Form container
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.fWhiteBackground,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(24),
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formkey,
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        // Name field
                        _buildInputField(
                          controller: nameController,
                          label: 'Name :',
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Name cannot be empty";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        // Email field
                        _buildInputField(
                          controller: emailController,
                          label: 'Email :',
                          icon: Icons.mail_outline,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Email cannot be empty";
                            }
                            if (!RegExp(
                                    "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                                .hasMatch(value)) {
                              return "Please enter a valid email";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        // Department field
                        _buildInputField(
                          controller: departmentController,
                          label: 'Department :',
                          icon: Icons.business_outlined,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Department cannot be empty";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        // Password field
                        _buildInputField(
                          controller: passwordController,
                          label: 'Password :',
                          icon: Icons.lock_outline,
                          obscureText: _isObscure,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.fIconAndLabelText,
                              size: 18,
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscure = !_isObscure;
                              });
                            },
                          ),
                          validator: (value) {
                            RegExp regex = RegExp(r'^.{6,}$');
                            if (value!.isEmpty) {
                              return "Password cannot be empty";
                            }
                            if (!regex.hasMatch(value)) {
                              return "Please enter valid password (Min. 6 characters)";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        // Confirm Password field
                        _buildInputField(
                          controller: confirmpassController,
                          label: 'Confirm Password :',
                          icon: Icons.lock_outline,
                          obscureText: _isObscure2,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscure2
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.fIconAndLabelText,
                              size: 18,
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscure2 = !_isObscure2;
                              });
                            },
                          ),
                          validator: (value) {
                            if (confirmpassController.text !=
                                passwordController.text) {
                              return "Passwords do not match";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        // Account Type dropdown
                        _buildDropdownField(),
                        const SizedBox(height: 20),
                        // Terms and conditions checkbox
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              margin: const EdgeInsets.only(top: 2),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.fIconAndLabelText,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: _agreedToTerms
                                  ? const Icon(
                                      Icons.check,
                                      size: 8,
                                      color: AppColors.fRedBright,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _agreedToTerms = !_agreedToTerms;
                                  });
                                },
                                child: RichText(
                                  text: const TextSpan(
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: AppColors.fTextH1,
                                      fontFamily: 'Mulish',
                                    ),
                                    children: [
                                      TextSpan(
                                          text:
                                              'By checking the box you agree to our '),
                                      TextSpan(
                                        text: 'Terms',
                                        style:
                                            TextStyle(color: AppColors.fRed2),
                                      ),
                                      TextSpan(text: ' and '),
                                      TextSpan(
                                        text: 'Conditions',
                                        style:
                                            TextStyle(color: AppColors.fRed2),
                                      ),
                                      TextSpan(text: '.'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Register button
                        Container(
                          width: 300,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.fRedBright,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 4,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                signUp(emailController.text,
                                    passwordController.text, role);
                              },
                              child: Center(
                                child: showProgress
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Register',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.fWhite,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    required FormFieldValidator<String> validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: AppColors.fTextH1,
            fontFamily: 'Mulish',
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: AppColors.fWhite,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            validator: validator,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.fTextH1,
              fontFamily: 'Mulish',
            ),
            decoration: InputDecoration(
              prefixIcon: Container(
                width: 40,
                padding: const EdgeInsets.all(12),
                child: Icon(
                  icon,
                  color: AppColors.fIconAndLabelText,
                  size: 18,
                ),
              ),
              suffixIcon: suffixIcon,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.fRedBright,
                  width: 1,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.fRed2,
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.fRed2,
                  width: 1,
                ),
              ),
              filled: true,
              fillColor: AppColors.fWhite,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              hintStyle: const TextStyle(
                fontSize: 14,
                color: AppColors.fIconAndLabelText,
                fontFamily: 'Mulish',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Account Type :',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: AppColors.fTextH1,
            fontFamily: 'Mulish',
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: AppColors.fWhite,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: _currentItemSelected,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.fIconAndLabelText,
              size: 20,
            ),
            decoration: InputDecoration(
              prefixIcon: Container(
                width: 40,
                padding: const EdgeInsets.all(12),
                child: const Icon(
                  Icons.account_circle_outlined,
                  color: AppColors.fIconAndLabelText,
                  size: 18,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.fRedBright,
                  width: 1,
                ),
              ),
              filled: true,
              fillColor: AppColors.fWhite,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.fTextH1,
              fontFamily: 'Mulish',
            ),
            dropdownColor: AppColors.fWhite,
            items: rool.map((String dropDownStringItem) {
              return DropdownMenuItem<String>(
                value: dropDownStringItem,
                child: Text(
                  dropDownStringItem,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.fTextH1,
                    fontFamily: 'Mulish',
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? newValueSelected) {
              setState(() {
                _currentItemSelected = newValueSelected!;
                role = newValueSelected;
              });
            },
          ),
        ),
      ],
    );
  }

  void signUp(String email, String password, String role) async {
    if (_formkey.currentState!.validate()) {
      if (!_agreedToTerms) {
        Fluttertoast.showToast(
          msg: "Please agree to terms and conditions",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.orange,
        );
        return;
      }

      setState(() {
        showProgress = true;
      });
      try {
        Fluttertoast.showToast(
          msg: "Creating employee account...",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.blue,
        );

        await _authService.register(email, password, role);

        // TODO: Save additional user data (name, department) to Firestore
        // This would typically be done in the AuthService or here after registration

        Fluttertoast.showToast(
          msg: "Employee account created successfully",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
        );

        setState(() {
          showProgress = false;
        });

        // Clear all form fields
        nameController.clear();
        emailController.clear();
        departmentController.clear();
        passwordController.clear();
        confirmpassController.clear();
        setState(() {
          _currentItemSelected = "Diner";
          role = "Diner";
          _agreedToTerms = false;
        });
      } catch (e) {
        Fluttertoast.showToast(
          msg: "Registration failed: ${e.toString()}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
        );

        setState(() {
          showProgress = false;
        });
      }
    } else {
      Fluttertoast.showToast(
        msg: "Please fill all fields correctly",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.orange,
      );
    }
  }
}
