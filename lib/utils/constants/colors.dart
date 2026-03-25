import 'package:flutter/material.dart';

class OColors {
  OColors._();

  // App Basic Colors
  static const  Color primary = Color(0xFF181818);
  static const  Color secondary = Color(0xFFFFCC00);
  static const  Color grey1 = Color(0xFFf2f2f2);
  static const Color grey2 = Color(0xFF5E5E5E);
  static const Color white = Color(0xFFFFFFFF);

  // Gradient Color
  static const Gradient linerGradient = LinearGradient(
      begin: Alignment(0.0, 0.0),
      end: Alignment(0.707, -0.707),
      colors: [
        Color(0xFFFFCC00),
        Color(0xFFf2f2f2),
        Color(0xFF5E5E5E),
      ]
  );

  // Text Colors
  static const Color textprimary = Color(0xFF181818);

  // Background Colors
  static const Color primaryBackground = Color(0xFF181818);

  // Button Colors
  static const Color buttonPrimary = Color(0xFF181818);
  static const Color buttonDisabled = Color(0xFFf2f2f2);

  // Border Colors
  static const Color borderPrimary = Color(0xFF000000);
  static const Color borderSecondary = Color(0xFFf2f2f2);

  // Error and Vallidation Colors
  static const Color error = Color(0xFFF50000);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Colors.orange;
  static const Color info = Color(0xFF181818);

  // Text Field Colors
  static const Color textFieldBackground = Color(0xFFf2f2f2);

  // Neutrals Shades
  static const Color grey = Color(0xFF5E5E5E);
}