import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Styles/colors.dart';
import '../services/auth_service.dart';

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

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpassController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobile = TextEditingController();
  bool _isObscure = true;
  bool _isObscure2 = true;
  var role = "Diner";
  var _currentItemSelected = "Diner";
  var rool = ["Diner", "Planner", "Admin"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.cardBackground,
                  AppColors.backgroundColor,
                ],
              ),
            ),
          ),

          // Decorative design elements
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryColor.withOpacity(0.2),
                    AppColors.primaryColor.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: -100,
            left: -50,
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondaryColor.withOpacity(0.2),
                    AppColors.secondaryColor.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),

          SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),
                  // Logo or Icon (optional)
                  Center(
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.restaurant_menu,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Heading
                  Center(
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Subheading
                  Center(
                    child: Text(
                      'Join Teton Meals today',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Form
                  Form(
                    key: _formkey,
                    child: Column(
                      children: [
                        // Email field
                        buildTextField(
                          controller: emailController,
                          hint: 'Email',
                          icon: Icons.email_outlined,
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

                        const SizedBox(height: 20),

                        // Password field
                        buildTextField(
                          controller: passwordController,
                          hint: 'Password',
                          icon: Icons.lock_outline,
                          obscure: _isObscure,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey[500],
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

                        const SizedBox(height: 20),

                        // Confirm Password field
                        buildTextField(
                          controller: confirmpassController,
                          hint: 'Confirm Password',
                          icon: Icons.lock_outline,
                          obscure: _isObscure2,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscure2
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey[500],
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

                        const SizedBox(height: 20),

                        // Role selection
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.person_outline,
                                  color: AppColors.primaryColor),
                              const SizedBox(width: 15),
                              Expanded(
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    dropdownColor: Colors.white,
                                    items: rool.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        _currentItemSelected = newValue!;
                                        role = newValue;
                                      });
                                    },
                                    value: _currentItemSelected,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Register Button
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: () {
                              signUp(emailController.text,
                                  passwordController.text, role);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                              elevation: showProgress ? 0 : 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              shadowColor:
                                  AppColors.primaryColor.withOpacity(0.5),
                            ),
                            child: showProgress
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                      strokeWidth: 3,
                                    ),
                                  )
                                : const Text(
                                    "CREATE ACCOUNT",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (showProgress)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.secondaryColor),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Helper method to build consistent text fields
  Widget buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    required FormFieldValidator<String> validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: validator,
        style: TextStyle(fontSize: 16, color: Colors.grey[800]),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 16, color: Colors.grey[400]),
          prefixIcon: Icon(icon, color: AppColors.primaryColor),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
        ),
      ),
    );
  }

  void signUp(String email, String password, String role) async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        showProgress = true;
      });
      try {
        // Show registration in progress toast
        Fluttertoast.showToast(
          msg: "Creating employee account...",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.blue,
        );

        // Register new user
        final newUser = await _authService.register(email, password, role);

        // Success toast
        Fluttertoast.showToast(
          msg: "Employee account created successfully",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
        );

        setState(() {
          showProgress = false;
        });

        // Clear the form
        emailController.clear();
        passwordController.clear();
        confirmpassController.clear();
        setState(() {
          _currentItemSelected = "Diner";
          role = "Diner";
        });
      } catch (e) {
        // Error toast
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
      // Validation error toast
      Fluttertoast.showToast(
        msg: "Please fill all fields correctly",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.orange,
      );
    }
  }
}
