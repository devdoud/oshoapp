import 'package:osho/utils/formatters/formatter.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Model class representing user data
class UserModel {
  final String id;
  final String email;
  String firstName;
  String lastName;
  final String username;
  String phone;
  String profilePicture;
  String role; // Added for Tailor/Guest management

  /// Constructor for UserModel
  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.phone,
    required this.profilePicture,
    this.role = 'customer',
  });

  /// Helper function to get the full name
  String get fullName => '$firstName $lastName';

  /// Helper function to format phone Number
  String get formattedPhoneNo => OFormatter.formatPhoneNumber(phone);

  /// static function to split full name into firstname and lastname
  static List<String> nameParts(fullName) => fullName.split(" ");

  /// static function to generate a username from first and last name
  static String generateUsername(fullName) {
    List<String> nameParts = fullName.split(" ");
    String firstName = nameParts[0].toLowerCase();
    String lastName = nameParts.length > 1 ? nameParts[1].toLowerCase() : '';

    String camelCaseUsername = "$firstName$lastName";
    String usernameWithPrefix = "osho_$camelCaseUsername";
    return usernameWithPrefix;
  }

  /// static function to create empty user model
  static UserModel empty() {
    return UserModel(
      id: '',
      email: '',
      firstName: '',
      lastName: '',
      username: '',
      phone: '',
      profilePicture: '',
      role: 'customer',
    );
  }

  /// Convert UserModel to JSON (Matches public.profiles table in Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': '$firstName $lastName',
      'username': username,
      'phone': phone,
      'avatar_url': profilePicture,
      'role': role,
    };
  }

  /// Create UserModel from JSON (From public.profiles table)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Split full_name if available
    String fullName = json['full_name'] ?? '';
    List<String> parts = fullName.split(' ');
    String fName = parts.isNotEmpty ? parts[0] : '';
    String lName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: fName,
      lastName: lName,
      username: json['username'] ?? '',
      phone: json['phone'] ?? '',
      profilePicture: json['avatar_url'] ?? '',
      role: json['role'] ?? 'customer',
    );
  }

  /// Create UserModel from Supabase User (From auth.users metadata)
  factory UserModel.fromSupabaseUser(supabase.User user) {
    final data = user.userMetadata ?? {};
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      firstName: data['first_name'] ?? '',
      lastName: data['last_name'] ?? '',
      username: data['username'] ?? '',
      phone: user.phone ?? data['phone'] ?? '',
      profilePicture: data['avatar_url'] ?? '',
      role: data['role'] ?? 'customer',
    );
  }
}
