import 'package:flutter/material.dart';
import 'package:osho/utils/constants/colors.dart';

class OTextFormFieldTheme {
  OTextFormFieldTheme._();

  static InputDecorationTheme lightInputDecorationtheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: OColors.grey,
    suffixIconColor: OColors.grey,
    filled: true,
    fillColor: const Color(0xFFF3EFE8),
    labelStyle: const TextStyle().copyWith(fontSize: 14, color: Color(0xFF6A6258)),
    hintStyle: const TextStyle().copyWith(fontSize: 14, color: Color(0xFF9A9288)),
    errorStyle: const TextStyle().copyWith(fontStyle: FontStyle.normal),
    floatingLabelStyle: const TextStyle().copyWith(color: OColors.primary.withOpacity(0.8)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    border: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide.none,
    ),
    enabledBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(width: 1, color: Color(0xFFE6DED3))
    ),
    focusedBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(width: 1.4, color: OColors.primary)
    ),
    errorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(width: 1, color: Colors.red)
    ),
    focusedErrorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(width: 2, color: Colors.orange)
    ),
  );


  static InputDecorationTheme darkInputDecorationtheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: Colors.white70,
    suffixIconColor: Colors.white70,
    filled: true,
    fillColor: const Color(0xFF171A1F),
    labelStyle: const TextStyle().copyWith(fontSize: 14, color: Color(0xFFB8C0CC)),
    hintStyle: const TextStyle().copyWith(fontSize: 14, color: Color(0xFF6F7782)),
    errorStyle: const TextStyle().copyWith(fontStyle: FontStyle.normal),
    floatingLabelStyle: const TextStyle().copyWith(color: Colors.white),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    border: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide.none,
    ),
    enabledBorder: const OutlineInputBorder().copyWith(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(width: 1, color: Color(0xFF262C35))
    ),
    focusedBorder: const OutlineInputBorder().copyWith(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(width: 1.4, color: Color(0xFFE6EAF0))
    ),
    errorBorder: const OutlineInputBorder().copyWith(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(width: 1, color: Colors.red)
    ),
    focusedErrorBorder: const OutlineInputBorder().copyWith(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(width: 2, color: Colors.orange)
    ),
  );
}
