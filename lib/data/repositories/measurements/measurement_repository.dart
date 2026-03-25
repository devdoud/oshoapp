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
      throw 'Error saving measurement profile: $e';
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
      throw 'Error fetching measurements: $e';
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
      throw 'Error deleting profile: $e';
    }
  }
}
