import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teton_meal_app/Screens/Navbar.dart';
import 'package:teton_meal_app/Screens/Register.dart';
import 'package:teton_meal_app/Styles/colors.dart';
import 'package:teton_meal_app/services/auth_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _authService = AuthService();

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
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [          Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
          ),          Positioned(
            top: -screenSize.height * 0.08,
            right: -screenSize.width * 0.05,
            child: Container(
              height: screenSize.width * 0.3,
              width: screenSize.width * 0.3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0xFFFF4E6A).withOpacity(0.1),
                    Color(0xFFFF4E6A).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: screenSize.height * 0.15,
            left: -screenSize.width * 0.15,
            child: Container(
              height: screenSize.width * 0.2,
              width: screenSize.width * 0.2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFF6B81).withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -screenSize.height * 0.05,
            right: -screenSize.width * 0.1,
            child: Container(
              height: screenSize.width * 0.25,
              width: screenSize.width * 0.25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0xFFFF4E6A).withOpacity(0.15),
                    Color(0xFFFF4E6A).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),          ...List.generate(4, (index) {
            return Positioned(
              top: screenSize.height * (0.25 + index * 0.15),
              left: screenSize.width * (0.1 + index * 0.2),
              child: Opacity(
                opacity: 0.05 + (index * 0.02),
                child: Container(
                  height: 5,
                  width: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index % 2 == 0
                        ? Color(0xFFFF4E6A)
                        : Color(0xFFFF6B81),
                  ),
                ),
              ),
            );
          }),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [                    const SizedBox(height: 40),
                    Center(
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFFF6B81),
                                Color(0xFFFF4E6A),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                                spreadRadius: 0,
                              ),
                            ],
                          ),                          child: const Icon(
                            Icons.restaurant_menu,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      ),
                    ),                    const SizedBox(height: 30),
                    const Text(
                      'Welcome back',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'sign in to access your account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: emailController,
                            icon: Icons.email_outlined,
                            hint: 'Email',
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
                          ),                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: passwordController,
                            icon: Icons.lock_outline,
                            hint: 'Password',
                            obscure: !_isPasswordVisible,
                            suffixIcon: IconButton(
                              icon: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (Widget child,
                                    Animation<double> animation) {
                                  return ScaleTransition(
                                      scale: animation, child: child);
                                },
                                child: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  key: ValueKey(_isPasswordVisible),                                  color: Colors.grey[400],
                                  size: 20,
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
                          ),                          const SizedBox(height: 12),
                          // Remember me and Forgot password row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Remember me checkbox
                              Row(
                                children: [                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberMe = value ?? false;
                                        });
                                      },                                    activeColor: Color(0xFFFF4E6A),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Remember me',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),

                              // Forgot password link
                              GestureDetector(
                                onTap: () {
                                  // Handle forgot password
                                },
                                child: Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                    color: Color(0xFFFF4E6A),                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),                          const SizedBox(height: 24),
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
                            child: Container(                              width: double.infinity,
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Color(0xFFFF4E6A).withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Color(0xFFFF4E6A),
                                  disabledBackgroundColor:
                                      Color(0xFFFF4E6A).withOpacity(0.7),                                  elevation: 0,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                          strokeWidth: 2.5,
                                        ),
                                      )                                    : Text(
                                        "Sign In",
                                        style: TextStyle(                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ),                          const SizedBox(height: 30),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.grey.withOpacity(0.1),
                                        Colors.grey.withOpacity(0.3),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.grey.withOpacity(0.3),
                                        Colors.grey.withOpacity(0.1),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Text(
                            'TETON MEAL APP',
                            style: TextStyle(
                              letterSpacing: 2,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
      },              child: Container(        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,          style: TextStyle(fontSize: 14, color: Colors.grey[800]),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),            // Icon moved to the right side
            suffixIcon: hint == 'Password'
                ? suffixIcon
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      icon,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                  ),border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.2),
                width: 1.0,
              ),
            ),            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            fillColor: Colors.white,
            filled: true,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.3),
                width: 1.0,
              ),
            ),
            errorStyle: TextStyle(
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

      Fluttertoast.showToast(
        msg: "Welcome to Teton Meal App!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      Fluttertoast.showToast(
        msg: "Unable to sign in: ${e.toString()}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
}
