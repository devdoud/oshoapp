import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:osho/features/shop/models/logistics_rate_model.dart';

class LogisticsRepository {
  final _supabase = Supabase.instance.client;

  Future<List<LogisticsRateModel>> fetchTiers() async {
    try {
      final response = await _supabase
          .from('logistics_tiers')
          .select()
          .order('zone')
          .order('sort_order');

      return (response as List)
          .map((json) =>
              LogisticsRateModel.fromJson(Map<String, dynamic>.from(json as Map)))
          .toList();
    } catch (e) {
      debugPrint('[LOGISTICS_REPOSITORY] fetchTiers error: $e');
      rethrow;
    }
  }
}
