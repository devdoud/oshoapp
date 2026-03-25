import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../features/personalization/models/address_model.dart';

class AddressRepository extends GetxController {
  static AddressRepository get instance => Get.find();

  final _supabase = Supabase.instance.client;

  Future<List<AddressModel>> fetchUserAddresses() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from('addresses')
          .select()
          .eq('user_id', userId)
          .order('is_default', ascending: false)
          .order('created_at', ascending: false);

      final data = List<Map<String, dynamic>>.from(response);
      return data.map((json) => AddressModel.fromJson(json)).toList();
    } catch (e) {
      throw 'Error fetching addresses: $e';
    }
  }

  Future<AddressModel?> fetchDefaultAddress() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('addresses')
          .select()
          .eq('user_id', userId)
          .eq('is_default', true)
          .maybeSingle();

      if (response == null) return null;
      return AddressModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<AddressModel> createAddress(AddressModel address) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw 'Vous devez etre connecte pour ajouter une adresse.';
      }

      if (address.userId.isEmpty) {
        address.userId = userId;
      }

      final response = await _supabase
          .from('addresses')
          .insert(address.toJson())
          .select()
          .single();

      return AddressModel.fromJson(response);
    } catch (e) {
      throw 'Error creating address: $e';
    }
  }

  Future<AddressModel> updateAddress(AddressModel address) async {
    try {
      if (address.id == null) {
        throw 'Address id is required to update.';
      }

      final response = await _supabase
          .from('addresses')
          .update(address.toJson())
          .eq('id', address.id!)
          .select()
          .single();

      return AddressModel.fromJson(response);
    } catch (e) {
      throw 'Error updating address: $e';
    }
  }

  Future<void> deleteAddress(String id) async {
    try {
      await _supabase.from('addresses').delete().eq('id', id);
    } catch (e) {
      throw 'Error deleting address: $e';
    }
  }

  Future<void> setDefaultAddress(String addressId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw 'Vous devez etre connecte pour modifier une adresse.';
      }

      await _supabase
          .from('addresses')
          .update({'is_default': false})
          .eq('user_id', userId);

      await _supabase
          .from('addresses')
          .update({'is_default': true})
          .eq('id', addressId);
    } catch (e) {
      throw 'Error setting default address: $e';
    }
  }
}
