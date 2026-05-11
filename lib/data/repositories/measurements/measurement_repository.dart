import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../features/personalization/models/measurement_profile_model.dart';

class MeasurementRepository extends GetxController {
  static MeasurementRepository get instance => Get.find();

  final _supabase = Supabase.instance.client;

  /// Save or Update a Measurement Profile
  Future<void> saveMeasurementProfile(MeasurementProfileModel profile) async {
    try {
      if (profile.id != null && profile.id!.isNotEmpty) {
        // Update
        await _supabase
            .from('measurement_profiles')
            .update(profile.toJson())
            .eq('id', profile.id!);
      } else {
        // Insert
        // Ensure user_id is set to current user if not provided (though model requires it)
        final userId = _supabase.auth.currentUser?.id;
        if (userId != null && profile.userId.isEmpty) {
          profile.userId = userId;
        }

        await _supabase.from('measurement_profiles').insert(profile.toJson());
      }
    } catch (e) {
      debugPrint('[MEASUREMENT_REPOSITORY][SAVE] $e');
      rethrow;
    }
  }

  /// Fetch User's Measurement Profiles
  Future<List<MeasurementProfileModel>> fetchUserMeasurements() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from('measurement_profiles')
          .select()
          .eq('user_id', userId);

      final data = List<Map<String, dynamic>>.from(response);
      return data
          .map((json) => MeasurementProfileModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('[MEASUREMENT_REPOSITORY][FETCH] $e');
      rethrow;
    }
  }

  /// Get Primary Profile
  Future<MeasurementProfileModel?> getPrimaryProfile() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('measurement_profiles')
          .select()
          .eq('user_id', userId)
          .eq('is_primary', true)
          .maybeSingle();

      if (response == null) return null;
      return MeasurementProfileModel.fromJson(response);
    } catch (e) {
      // It's okay if no primary profile exists
      return null;
    }
  }

  /// Delete Profile
  Future<void> deleteProfile(String id) async {
    try {
      await _supabase.from('measurement_profiles').delete().eq('id', id);
    } catch (e) {
      debugPrint('[MEASUREMENT_REPOSITORY][DELETE] $e');
      rethrow;
    }
  }

  /// Set a profile as primary (clears is_primary on all others first)
  Future<void> setPrimaryProfile(String profileId, String userId) async {
    try {
      await _supabase
          .from('measurement_profiles')
          .update({'is_primary': false})
          .eq('user_id', userId);
      await _supabase
          .from('measurement_profiles')
          .update({'is_primary': true})
          .eq('id', profileId);
    } catch (e) {
      debugPrint('[MEASUREMENT_REPOSITORY][SET_PRIMARY] $e');
      rethrow;
    }
  }
}
