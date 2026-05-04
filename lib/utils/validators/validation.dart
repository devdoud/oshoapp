import 'package:flutter/material.dart';

class OValidator {

  static String? validateEmptyText(String? fieldName, String? value) {
    if(value == null || value.isEmpty) {
      return '$fieldName is required.';
    }

    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    // Regular expression for email validation
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if(!emailRegExp.hasMatch(value)) {
      return 'Invalid email address.';
    }

    return null ;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    // Check for minimum password length
    if(value.length < 6) {
      return 'Password must be at least 6 charater long.';
    }

    // Check for uppercase letters
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter.';
    }

    // Check for numbers
    if(!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    // Check for special caracters
    if(!value.contains(RegExp(r'[!@#$&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }

    return null ;
  }

  static String? validatePhoneNumber(String? value) {
    if( value == null || value.isEmpty ) {
      return 'Phone Number is required';
    }

    // Regular Expression for international phone number (E.164 format: +1 to +999 followed by 7-14 digits)
    final phoneRegExp = RegExp(r'^\+?\d{7,15}$');

    if (!phoneRegExp.hasMatch(value)) {
      return 'Invalid phone number format (7-15 digits required, optionally starting with +)';
    }

    return null;
  }

}