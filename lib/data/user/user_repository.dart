import 'package:get/get.dart';
import 'package:osho/features/personalization/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository class for user-related data operations.
class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final _supabase = Supabase.instance.client;

  /// Fetch user details from the 'profiles' table (Public Schema)
  /// This is the "Senior" way: fetching from a synchronized public table.
  Future<UserModel> fetchUserDetails() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return UserModel.empty();

      // We fetch from the 'profiles' table which is managed by our SQL Trigger
      final response = await _supabase
          .from('profiles')
          .select('*')
          .eq('id', user.id)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      // Fallback to Auth metadata if table fetch fails (migration period)
      final user = _supabase.auth.currentUser;
      if (user != null) return UserModel.fromSupabaseUser(user);
      
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Function to update user data in Supabase (Public profiles table)
  Future<void> updateUserDetails(UserModel updatedUser) async {
    try {
      await _supabase.from('profiles').update(updatedUser.toJson()).eq('id', updatedUser.id);
      
      // Also sync with Auth Metadata for consistency
      await _supabase.auth.updateUser(UserAttributes(data: {
        'first_name': updatedUser.firstName,
        'last_name': updatedUser.lastName,
        'username': updatedUser.username,
        'phone': updatedUser.phone,
        'avatar_url': updatedUser.profilePicture,
        'role': updatedUser.role,
      }));
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Update any specific field in the profiles table
  Future<void> updateSingleField(Map<String, dynamic> json) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase.from('profiles').update(json).eq('id', userId);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
