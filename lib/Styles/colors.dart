import 'package:flutter/material.dart';

class AppColors {
  static const Color fWhiteBackground = Color(0xFFF9F9F9);
  static const Color fWhite = Color(0xFFFFFFFF);
  static const Color fTextH1 = Color(0xFF383A3F);
  static const Color fTextH2 = Color(0xFF585F6A);
  static const Color fWhiteIcon = Color(0xFF949597);
  static const Color fLineaAndLabelBox = Color(0xFFF4F5F7);
  static const Color fIconAndLabelText = Color(0xFF7A869A);
  static const Color fYellow = Color(0xFFEF9F27);
  static const Color fBlue = Color(0xFF7495DE);
  static const Color fRedBright = Color(0xFFFF3951);
  static const Color fRed2 = Color(0xFFFF7686);
  static const Color fGreen = Color(0xFF466D5E);
  static const Color fCyan = Color(0xFF60C3C3);
  static const Color saveGreen = Color(0xFF36B37E);
  static const Color fNameBoxGreen = Color(0xFFB8C7B4);
  static const Color fNameBoxYellow = Color(0xFFEDCFA1);
  static const Color fNameBoxPink = Color(0xFFE4CBCE);
  static const Color fRedProgressbar = Color(0xFFFBB1BA);

  static const Color primaryColor = fRedBright;
  static const Color secondaryColor = fYellow;
  static const Color backgroundColor = fWhiteBackground;
  static const Color cardBackground = fWhite;

  static const Color primaryText = fTextH1;
  static const Color secondaryText = fTextH2;
  static const Color tertiaryText = fIconAndLabelText;

  static const Color success = fGreen;
  static const Color error = fRed2;
  static const Color warning = fNameBoxYellow;

  static const Color divider = fLineaAndLabelBox;
  static const Color grey = fTextH2;
  static const Color white = fWhite;

  static Color disabledButton = primaryColor.withOpacity(0.7);
  static Color shadowColor = primaryColor.withOpacity(0.3);
  static Color inputBorderColor = grey.withOpacity(0.3);
}
