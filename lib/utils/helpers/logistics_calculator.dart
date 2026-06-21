import 'package:get/get.dart';
import 'package:osho/utils/constants/sizes.dart';
import 'package:osho/utils/helpers/tax_service.dart';

class LogisticsRate {
  const LogisticsRate({
    required this.zone,
    required this.fee,
    required this.estimate,
    required this.weightLabel,
    required this.sourceLabel,
  });

  final String zone;
  final double fee;
  final String estimate;
  final String weightLabel;
  final String sourceLabel;
}

class _ShippingTier {
  const _ShippingTier({
    required this.maxItems,
    required this.weightLabel,
    required this.fee,
  });

  final int maxItems;
  final String weightLabel;
  final double fee;
}

class OLogisticsCalculator {
  OLogisticsCalculator._();

  static const double estimatedKgPerItem = 0.8;

  static LogisticsRate get localRate => quoteForCountry('Benin');
  static LogisticsRate get africaRate => quoteForCountry('Senegal');
  static LogisticsRate get europeRate => quoteForCountry('France');
  static LogisticsRate get northAmericaRate => quoteForCountry('United States');
  static LogisticsRate get internationalRate => quoteForCountry('Japan');

  static LogisticsRate rateForCountry(String? country, {int itemCount = 1}) {
    return quoteForCountry(country, itemCount: itemCount);
  }

  static LogisticsRate? Function(String zone, int itemCount)? _dynamicResolver;

  static void setDynamicResolver(
      LogisticsRate? Function(String zone, int itemCount)? resolver) {
    _dynamicResolver = resolver;
  }

  static LogisticsRate quoteForCountry(String? country, {int itemCount = 1}) {
    final safeCount = itemCount < 1 ? 1 : itemCount;
    final zone = _zoneForCountry(country?.trim() ?? '');

    final dynamic = _dynamicResolver?.call(zone, safeCount);
    if (dynamic != null) return dynamic;

    final tier = _tierFor(zone, safeCount);
    return LogisticsRate(
      zone: _zoneLabel(zone),
      fee: tier.fee,
      estimate: _estimateFor(zone),
      weightLabel: tier.weightLabel,
      sourceLabel: _sourceFor(zone),
    );
  }

  /// Returns the number formatted with space thousands separator: 100 000
  static String formatAmount(double amount) {
    final str = amount.truncate().toString();
    final buf = StringBuffer();
    final len = str.length;
    for (var i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) buf.write(' ');
      buf.write(str[i]);
    }
    return buf.toString();
  }

  /// Returns formatted amount with FCFA suffix: 100 000 FCFA
  static String formatFee(double amount) => '${formatAmount(amount)} FCFA';

  static const double _xofPerUsd = 615.0;

  /// Formate un montant selon la locale active :
  /// - EN : affiche en dollars  -> "$73"
  /// - FR : affiche en FCFA     -> "45 000 FCFA"
  static String formatFeeLocalized(double fcfaAmount, {double? usdOverride}) {
    if (Get.locale?.languageCode == 'en') {
      final usd = usdOverride ?? (fcfaAmount / _xofPerUsd);
      final rounded = usd.round();
      return '\$$rounded';
    }
    return formatFee(fcfaAmount);
  }

  static String countryHint(LogisticsRate rate) {
    return '${rate.zone} - ${formatFee(rate.fee)} - ${rate.weightLabel}';
  }

  static _ShippingTier _tierFor(String zone, int itemCount) {
    final tiers = switch (zone) {
      'benin' => _beninTiers,
      'africa' => _africaTiers,
      'europe' => _europeTiers,
      'north_america' => _northAmericaTiers,
      _ => _worldTiers,
    };

    return tiers.firstWhere(
      (tier) => itemCount <= tier.maxItems,
      orElse: () => tiers.last,
    );
  }

  // ── Zone lookup via ISO code (reuse TaxService for matching) ───────────────

  static String _zoneForCountry(String country) {
    if (country.isEmpty) return 'benin';

    final tax = TaxService.forCountry(country);

    // Pays non reconnu -> international
    if (tax.iso2.isEmpty) return 'world';

    // Benin
    if (tax.iso2 == 'BJ') return 'benin';

    // Amerique du Nord
    if (_northAmericaISO2.contains(tax.iso2)) return 'north_america';

    // Europe
    if (_europeISO2.contains(tax.iso2)) return 'europe';

    // Afrique
    if (_africaISO2.contains(tax.iso2)) return 'africa';

    return 'world';
  }

  // ISO 3166-1 alpha-2 par zone de livraison
  static const _northAmericaISO2 = {'US', 'CA', 'MX'};

  static const _europeISO2 = {
    'FR', 'GB', 'DE', 'IT', 'ES', 'BE', 'NL', 'PT', 'CH',
    'SE', 'NO', 'DK', 'LU', 'IE', 'AT', 'FI', 'PL', 'CZ',
    'HU', 'RO', 'GR', 'HR', 'SK', 'SI', 'BG', 'EE', 'LV',
    'LT', 'CY', 'MT',
  };

  static const _africaISO2 = {
    // UEMOA
    'CI', 'SN', 'TG', 'BF', 'ML', 'NE', 'GW',
    // CEMAC
    'CM', 'GA', 'CG', 'CD', 'TD', 'CF', 'GQ',
    // Autres
    'NG', 'GH', 'KE', 'ZA', 'ET', 'TZ', 'UG', 'MZ', 'ZM', 'ZW',
    'MA', 'TN', 'EG', 'DZ', 'GN', 'SL', 'LR', 'MR', 'MW', 'RW',
    'BI', 'SO', 'SD', 'SS', 'AO', 'NA', 'BW', 'LS', 'SZ', 'MG',
    'MU', 'SC', 'CV', 'GM', 'DJ', 'ER', 'KM', 'ST',
  };

  static String _zoneLabel(String zone) {
    return switch (zone) {
      'benin' => 'Benin',
      'africa' => 'Afrique',
      'europe' => 'Europe',
      'north_america' => 'US / Canada',
      _ => 'International',
    };
  }

  static String _estimateFor(String zone) {
    return switch (zone) {
      'benin' => 'J a J+3',
      'africa' => '5 a 10 jours',
      'europe' => '5 a 8 jours',
      'north_america' => '3 a 8 jours',
      _ => '3 a 10 jours',
    };
  }

  static String _sourceFor(String zone) {
    return switch (zone) {
      'benin' => 'La Poste du Benin - envois express nationaux',
      'africa' => 'Benchmark postal 2026 zone B / Afrique',
      'europe' => 'Benchmark Colissimo international Europe 2026',
      'north_america' => 'Benchmark Colissimo international Monde 2026',
      _ => 'Benchmark Colissimo international Monde 2026',
    };
  }

  static const _beninTiers = [
    _ShippingTier(maxItems: 1, weightLabel: 'jusqu a 1 kg', fee: OSizes.kShippingFee),
    _ShippingTier(maxItems: 5, weightLabel: '1 a 5 kg', fee: 13000),
    _ShippingTier(maxItems: 999, weightLabel: '5 a 20 kg', fee: 35000),
  ];

  static const _africaTiers = [
    _ShippingTier(maxItems: 1, weightLabel: 'jusqu a 1 kg', fee: OSizes.kAfricaShippingFee),
    _ShippingTier(maxItems: 2, weightLabel: 'jusqu a 2 kg', fee: 20500),
    _ShippingTier(maxItems: 5, weightLabel: 'jusqu a 5 kg', fee: 26200),
    _ShippingTier(maxItems: 999, weightLabel: 'jusqu a 10 kg', fee: 43400),
  ];

  static const _europeTiers = [
    _ShippingTier(maxItems: 1, weightLabel: 'jusqu a 1 kg', fee: OSizes.kEuropeShippingFee),
    _ShippingTier(maxItems: 2, weightLabel: 'jusqu a 2 kg', fee: 14600),
    _ShippingTier(maxItems: 5, weightLabel: 'jusqu a 5 kg', fee: 18800),
    _ShippingTier(maxItems: 999, weightLabel: 'jusqu a 10 kg', fee: 30900),
  ];

  static const _northAmericaTiers = [
    _ShippingTier(maxItems: 1, weightLabel: 'jusqu a 1 kg', fee: OSizes.kNorthAmericaShippingFee),
    _ShippingTier(maxItems: 2, weightLabel: 'jusqu a 2 kg', fee: 35500),
    _ShippingTier(maxItems: 5, weightLabel: 'jusqu a 5 kg', fee: 51600),
    _ShippingTier(maxItems: 999, weightLabel: 'jusqu a 10 kg', fee: 97800),
  ];

  static const _worldTiers = [
    _ShippingTier(maxItems: 1, weightLabel: 'jusqu a 1 kg', fee: OSizes.kInternationalShippingFee),
    _ShippingTier(maxItems: 2, weightLabel: 'jusqu a 2 kg', fee: 35500),
    _ShippingTier(maxItems: 5, weightLabel: 'jusqu a 5 kg', fee: 51600),
    _ShippingTier(maxItems: 999, weightLabel: 'jusqu a 10 kg', fee: 97800),
  ];
}
