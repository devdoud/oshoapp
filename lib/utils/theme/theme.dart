import 'package:flutter/material.dart';
import 'package:osho/utils/theme/custom_themes/appbar_theme.dart';
import 'package:osho/utils/theme/custom_themes/bottom_sheet_theme.dart';
import 'package:osho/utils/theme/custom_themes/checkbox_theme.dart';
import 'package:osho/utils/theme/custom_themes/elevated_button_theme.dart';
import 'package:osho/utils/theme/custom_themes/outline_button_theme.dart';
import 'package:osho/utils/theme/custom_themes/text_field_theme.dart';
import 'package:osho/utils/theme/custom_themes/text_theme.dart';

class OshoTheme {
  OshoTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'DMSans',
    brightness: Brightness.light,
    primaryColor: Color(0xff181818),
    scaffoldBackgroundColor: Colors.white,
    textTheme: OTextTheme.lightTextTheme,
    elevatedButtonTheme: OElevatedButtonTheme.lightElevatedButtonTheme,
    appBarTheme: OAppBarTheme.lightAppBarTheme,
    checkboxTheme: OCheckboxTheme.lightCheckboxTheme,
    bottomSheetTheme: OBottomSheetTheme.lightBottomSheetTheme,
    inputDecorationTheme: OTextFormFieldTheme.lightInputDecorationtheme,
    outlinedButtonTheme: OOutlinebuttonTheme.lightOutlinedButtonTheme
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'DMSans',
    brightness: Brightness.dark,
    primaryColor: Color(0xff181818),
    scaffoldBackgroundColor: Colors.black,
    textTheme: OTextTheme.darkTextTheme,
    elevatedButtonTheme: OElevatedButtonTheme.darkElevatedButtonTheme,
      appBarTheme: OAppBarTheme.darkAppBarTheme,
      checkboxTheme: OCheckboxTheme.darkCheckboxTheme,
      bottomSheetTheme: OBottomSheetTheme.darkBottomSheetTheme,
      inputDecorationTheme: OTextFormFieldTheme.darkInputDecorationtheme,
      outlinedButtonTheme: OOutlinebuttonTheme.darkOutlinedButtonTheme
  );
}