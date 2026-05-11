import 'package:osho/utils/constants/sizes.dart';

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
    final normalized = _normalize(country);
    final safeCount = itemCount < 1 ? 1 : itemCount;
    final zone = _zoneForCountry(normalized);

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
      if (i > 0 && (len - i) % 3 == 0) buf.write(' ');
      buf.write(str[i]);
    }
    return buf.toString();
  }

  /// Returns formatted amount with FCFA suffix: 100 000 FCFA
  static String formatFee(double amount) => '${formatAmount(amount)} FCFA';

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

  static String _zoneForCountry(String normalized) {
    if (normalized.isEmpty || _containsAny(normalized, _beninAliases)) {
      return 'benin';
    }
    if (_containsAny(normalized, _northAmericaAliases)) {
      return 'north_america';
    }
    if (_containsAny(normalized, _europeAliases)) {
      return 'europe';
    }
    if (_containsAny(normalized, _africaAliases)) {
      return 'africa';
    }
    return 'world';
  }

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

  static bool _containsAny(String value, List<String> aliases) {
    return aliases.any((alias) {
      if (alias.length <= 3) return value == alias;
      return value.contains(alias);
    });
  }

  static String _normalize(String? value) {
    return (value ?? '')
        .trim()
        .toLowerCase()
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ô', 'o')
        .replaceAll('ï', 'i')
        .replaceAll('î', 'i')
        .replaceAll('ç', 'c')
        .replaceAll('ÃƒÂ©', 'e')
        .replaceAll('ÃƒÂ¨', 'e')
        .replaceAll('ÃƒÂª', 'e')
        .replaceAll('ÃƒÂ ', 'a')
        .replaceAll('ÃƒÂ¢', 'a')
        .replaceAll('ÃƒÂ´', 'o')
        .replaceAll('ÃƒÂ¯', 'i')
        .replaceAll('ÃƒÂ®', 'i')
        .replaceAll('ÃƒÂ§', 'c');
  }

  static const _beninTiers = [
    _ShippingTier(
      maxItems: 1,
      weightLabel: 'jusqu a 1 kg',
      fee: OSizes.kShippingFee,
    ),
    _ShippingTier(
      maxItems: 5,
      weightLabel: '1 a 5 kg',
      fee: 13000,
    ),
    _ShippingTier(
      maxItems: 999,
      weightLabel: '5 a 20 kg',
      fee: 35000,
    ),
  ];

  static const _africaTiers = [
    _ShippingTier(
      maxItems: 1,
      weightLabel: 'jusqu a 1 kg',
      fee: OSizes.kAfricaShippingFee,
    ),
    _ShippingTier(
      maxItems: 2,
      weightLabel: 'jusqu a 2 kg',
      fee: 20500,
    ),
    _ShippingTier(
      maxItems: 5,
      weightLabel: 'jusqu a 5 kg',
      fee: 26200,
    ),
    _ShippingTier(
      maxItems: 999,
      weightLabel: 'jusqu a 10 kg',
      fee: 43400,
    ),
  ];

  static const _europeTiers = [
    _ShippingTier(
      maxItems: 1,
      weightLabel: 'jusqu a 1 kg',
      fee: OSizes.kEuropeShippingFee,
    ),
    _ShippingTier(
      maxItems: 2,
      weightLabel: 'jusqu a 2 kg',
      fee: 14600,
    ),
    _ShippingTier(
      maxItems: 5,
      weightLabel: 'jusqu a 5 kg',
      fee: 18800,
    ),
    _ShippingTier(
      maxItems: 999,
      weightLabel: 'jusqu a 10 kg',
      fee: 30900,
    ),
  ];

  static const _northAmericaTiers = [
    _ShippingTier(
      maxItems: 1,
      weightLabel: 'jusqu a 1 kg',
      fee: OSizes.kNorthAmericaShippingFee,
    ),
    _ShippingTier(
      maxItems: 2,
      weightLabel: 'jusqu a 2 kg',
      fee: 35500,
    ),
    _ShippingTier(
      maxItems: 5,
      weightLabel: 'jusqu a 5 kg',
      fee: 51600,
    ),
    _ShippingTier(
      maxItems: 999,
      weightLabel: 'jusqu a 10 kg',
      fee: 97800,
    ),
  ];

  static const _worldTiers = [
    _ShippingTier(
      maxItems: 1,
      weightLabel: 'jusqu a 1 kg',
      fee: OSizes.kInternationalShippingFee,
    ),
    _ShippingTier(
      maxItems: 2,
      weightLabel: 'jusqu a 2 kg',
      fee: 35500,
    ),
    _ShippingTier(
      maxItems: 5,
      weightLabel: 'jusqu a 5 kg',
      fee: 51600,
    ),
    _ShippingTier(
      maxItems: 999,
      weightLabel: 'jusqu a 10 kg',
      fee: 97800,
    ),
  ];

  static const _beninAliases = [
    'benin',
    'benin republic',
    'republique du benin',
  ];

  static const _northAmericaAliases = [
    'us',
    'u.s',
    'usa',
    'united states',
    'etats-unis',
    'etats unis',
    'america',
    'canada',
  ];

  static const _europeAliases = [
    'europe',
    'france',
    'belgique',
    'belgium',
    'allemagne',
    'germany',
    'italie',
    'italy',
    'espagne',
    'spain',
    'portugal',
    'pays-bas',
    'netherlands',
    'uk',
    'united kingdom',
    'royaume-uni',
    'switzerland',
    'suisse',
    'ireland',
    'irlande',
  ];

  static const _africaAliases = [
    'afrique',
    'nigeria',
    'ghana',
    'togo',
    'cote d ivoire',
    'cote-d ivoire',
    'ivory coast',
    'senegal',
    'mali',
    'burkina',
    'niger',
    'cameroun',
    'cameroon',
    'gabon',
    'maroc',
    'morocco',
    'tunisie',
    'tunisia',
    'algerie',
    'algeria',
    'kenya',
    'south africa',
    'afrique du sud',
  ];
}
