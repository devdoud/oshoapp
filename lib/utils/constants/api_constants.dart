import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class APIConstants {
  static String get oBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? "https://osho-api-1.onrender.com/api/v1";
  static String get oSecretAPIKey => dotenv.env['API_SECRET_KEY'] ?? "";

  // Supabase Constants
  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? "YOUR_SUPABASE_URL";
  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ?? "YOUR_SUPABASE_ANON_KEY";
}
