import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color.fromARGB(255, 195, 39, 52);
  static const Color secondaryColor = Color.fromARGB(255, 253, 192, 18);

  // Background Colors
  static const Color backgroundColor = Color(0xFFF5F5F7);
  static const Color cardBackground = Colors.white;

  // Text Colors
  static const Color primaryText = Color(0xFF000000);
  static const Color secondaryText = Color(0xFF757575);
  static const Color tertiaryText = Color(0xFF9E9E9E);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE57373);
  static const Color warning = Color(0xFFFFB74D);

  // Utility Colors
  static const Color divider = Color(0xFFE0E0E0);
  static const Color grey = Color.fromARGB(255, 138, 138, 138);
  static const Color white = Color.fromARGB(255, 255, 255, 255);

  // State Colors
  static Color disabledButton = primaryColor.withOpacity(0.7);
  static Color shadowColor = primaryColor.withOpacity(0.3);
  static Color inputBorderColor = grey.withOpacity(0.3);
}
