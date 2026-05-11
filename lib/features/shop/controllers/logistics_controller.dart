import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:osho/data/repositories/shop/logistics_repository.dart';
import 'package:osho/features/shop/models/logistics_rate_model.dart';
import 'package:osho/utils/helpers/logistics_calculator.dart';

class LogisticsController extends GetxController {
  static LogisticsController get instance => Get.find();

  final RxList<LogisticsRateModel> tiers = <LogisticsRateModel>[].obs;
  final isLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRates();
  }

  Future<void> fetchRates() async {
    try {
      final data = await LogisticsRepository().fetchTiers();
      tiers.assignAll(data);
      isLoaded.value = true;
      // Register the dynamic resolver so OLogisticsCalculator uses remote rates
      OLogisticsCalculator.setDynamicResolver(rateForZone);
    } catch (e) {
      // Silently fall back to hardcoded rates — app stays functional offline
      debugPrint('[LOGISTICS] Remote fetch failed, using hardcoded fallback: $e');
    }
  }

  /// Returns a [LogisticsRate] built from Supabase data for [zone] + [itemCount].
  /// Returns null when no remote tiers are loaded yet.
  LogisticsRate? rateForZone(String zone, int itemCount) {
    if (tiers.isEmpty) return null;

    final zoneTiers = tiers
        .where((t) => t.zone == zone)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    if (zoneTiers.isEmpty) return null;

    final tier = zoneTiers.firstWhere(
      (t) => itemCount <= t.maxItems,
      orElse: () => zoneTiers.last,
    );

    return LogisticsRate(
      zone: tier.zoneLabel,
      fee: tier.fee,
      estimate: tier.estimate,
      weightLabel: tier.weightLabel,
      sourceLabel: tier.sourceLabel,
    );
  }
}
