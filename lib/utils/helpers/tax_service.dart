/// Matching priority (highest to lowest) :
///   1. Exact ISO alpha-2 code  (e.g. "US", "FR", "GB")
///   2. Exact ISO alpha-3 code  (e.g. "USA", "FRA", "GBR")
///   3. input.contains(namePattern) — single direction only, min 3 chars
///
/// We NEVER use pattern.contains(input) to avoid false positives
/// like "australia".contains("us") matching the USA rule.
class TaxConfig {
  final double rate;
  final String label;
  final String country;
  final String iso2;

  const TaxConfig({
    required this.rate,
    required this.label,
    required this.country,
    this.iso2 = '',
  });

  factory TaxConfig.none() =>
      const TaxConfig(rate: 0.0, label: '', country: '', iso2: '');

  bool get applies => rate > 0;

  double compute(double baseAmount) =>
      double.parse((baseAmount * rate).toStringAsFixed(2));

  String get ratePercent {
    final pct = rate * 100;
    return pct == pct.roundToDouble()
        ? '${pct.round()} %'
        : '${pct.toStringAsFixed(2)} %';
  }

  String get fullLabel => applies ? '$label $ratePercent' : '';
}

class _Rule {
  final String iso2;
  final String iso3;
  final List<String> namePatterns;
  final double rate;
  final String label;
  final String displayName;

  const _Rule({
    required this.iso2,
    required this.iso3,
    required this.namePatterns,
    required this.rate,
    required this.label,
    required this.displayName,
  });
}

class TaxService {
  TaxService._();

  static const _rules = <_Rule>[
    // ── UEMOA ────────────────────────────────────────────────────────────────
    _Rule(iso2: 'BJ', iso3: 'BEN', namePatterns: ['benin', 'bénin'],
        rate: 0.18, label: 'TVA', displayName: 'Bénin'),
    _Rule(iso2: 'CI', iso3: 'CIV',
        namePatterns: ['ivoire', 'ivory coast', "côte d'ivoire",
            "cote d'ivoire", 'cote divoire'],
        rate: 0.18, label: 'TVA', displayName: "Côte d'Ivoire"),
    _Rule(iso2: 'SN', iso3: 'SEN', namePatterns: ['senegal', 'sénégal'],
        rate: 0.18, label: 'TVA', displayName: 'Sénégal'),
    _Rule(iso2: 'TG', iso3: 'TGO', namePatterns: ['togo'],
        rate: 0.18, label: 'TVA', displayName: 'Togo'),
    _Rule(iso2: 'BF', iso3: 'BFA', namePatterns: ['burkina'],
        rate: 0.18, label: 'TVA', displayName: 'Burkina Faso'),
    _Rule(iso2: 'ML', iso3: 'MLI', namePatterns: ['mali'],
        rate: 0.18, label: 'TVA', displayName: 'Mali'),
    _Rule(iso2: 'NE', iso3: 'NER', namePatterns: ['niger'],
        rate: 0.19, label: 'TVA', displayName: 'Niger'),
    _Rule(iso2: 'GW', iso3: 'GNB',
        namePatterns: ['guinea-bissau', 'guinee-bissau', 'guinée-bissau'],
        rate: 0.15, label: 'TVA', displayName: 'Guinée-Bissau'),

    // ── CEMAC ────────────────────────────────────────────────────────────────
    _Rule(iso2: 'CM', iso3: 'CMR', namePatterns: ['cameroun', 'cameroon'],
        rate: 0.1925, label: 'TVA', displayName: 'Cameroun'),
    _Rule(iso2: 'GA', iso3: 'GAB', namePatterns: ['gabon'],
        rate: 0.18, label: 'TVA', displayName: 'Gabon'),
    _Rule(iso2: 'CG', iso3: 'COG', namePatterns: ['congo brazza', 'republic of congo'],
        rate: 0.18, label: 'TVA', displayName: 'Congo'),
    _Rule(iso2: 'CD', iso3: 'COD',
        namePatterns: ['democratic republic', 'republique democratique', 'rdc', 'zaire'],
        rate: 0.16, label: 'TVA', displayName: 'RD Congo'),
    _Rule(iso2: 'TD', iso3: 'TCD', namePatterns: ['tchad', 'chad'],
        rate: 0.18, label: 'TVA', displayName: 'Tchad'),
    _Rule(iso2: 'CF', iso3: 'CAF',
        namePatterns: ['centrafrique', 'central african', 'rca'],
        rate: 0.18, label: 'TVA', displayName: 'RCA'),
    _Rule(iso2: 'GQ', iso3: 'GNQ',
        namePatterns: ['equatorial guinea', 'guinee equatoriale', 'guinée équatoriale'],
        rate: 0.15, label: 'TVA', displayName: 'Guinée Équatoriale'),

    // ── Afrique ──────────────────────────────────────────────────────────────
    _Rule(iso2: 'NG', iso3: 'NGA', namePatterns: ['nigeria', 'nigéria'],
        rate: 0.075, label: 'VAT', displayName: 'Nigeria'),
    _Rule(iso2: 'GH', iso3: 'GHA', namePatterns: ['ghana'],
        rate: 0.15, label: 'VAT', displayName: 'Ghana'),
    _Rule(iso2: 'KE', iso3: 'KEN', namePatterns: ['kenya'],
        rate: 0.16, label: 'VAT', displayName: 'Kenya'),
    _Rule(iso2: 'ZA', iso3: 'ZAF',
        namePatterns: ['south africa', 'afrique du sud'],
        rate: 0.15, label: 'VAT', displayName: 'Afrique du Sud'),
    _Rule(iso2: 'ET', iso3: 'ETH', namePatterns: ['ethiopie', 'ethiopia'],
        rate: 0.15, label: 'VAT', displayName: 'Éthiopie'),
    _Rule(iso2: 'TZ', iso3: 'TZA', namePatterns: ['tanzanie', 'tanzania'],
        rate: 0.18, label: 'VAT', displayName: 'Tanzanie'),
    _Rule(iso2: 'UG', iso3: 'UGA', namePatterns: ['ouganda', 'uganda'],
        rate: 0.18, label: 'VAT', displayName: 'Ouganda'),
    _Rule(iso2: 'MZ', iso3: 'MOZ', namePatterns: ['mozambique'],
        rate: 0.17, label: 'VAT', displayName: 'Mozambique'),
    _Rule(iso2: 'ZM', iso3: 'ZMB', namePatterns: ['zambie', 'zambia'],
        rate: 0.16, label: 'VAT', displayName: 'Zambie'),
    _Rule(iso2: 'ZW', iso3: 'ZWE', namePatterns: ['zimbabwe'],
        rate: 0.15, label: 'VAT', displayName: 'Zimbabwe'),
    _Rule(iso2: 'MA', iso3: 'MAR', namePatterns: ['maroc', 'morocco'],
        rate: 0.20, label: 'TVA', displayName: 'Maroc'),
    _Rule(iso2: 'TN', iso3: 'TUN', namePatterns: ['tunisie', 'tunisia'],
        rate: 0.19, label: 'TVA', displayName: 'Tunisie'),
    _Rule(iso2: 'EG', iso3: 'EGY', namePatterns: ['egypte', 'egypt'],
        rate: 0.14, label: 'VAT', displayName: 'Égypte'),
    _Rule(iso2: 'DZ', iso3: 'DZA', namePatterns: ['algerie', 'algérie', 'algeria'],
        rate: 0.19, label: 'TVA', displayName: 'Algérie'),
    _Rule(iso2: 'GN', iso3: 'GIN', namePatterns: ['guinee conakry', 'guinea conakry'],
        rate: 0.18, label: 'TVA', displayName: 'Guinée'),
    _Rule(iso2: 'SL', iso3: 'SLE', namePatterns: ['sierra leone'],
        rate: 0.15, label: 'GST', displayName: 'Sierra Leone'),
    _Rule(iso2: 'LR', iso3: 'LBR', namePatterns: ['liberia'],
        rate: 0.10, label: 'GST', displayName: 'Liberia'),

    // ── Europe ────────────────────────────────────────────────────────────────
    _Rule(iso2: 'FR', iso3: 'FRA', namePatterns: ['france'],
        rate: 0.20, label: 'TVA', displayName: 'France'),
    _Rule(iso2: 'GB', iso3: 'GBR',
        namePatterns: ['united kingdom', 'royaume-uni', 'great britain', 'england',
            'scotland', 'wales'],
        rate: 0.20, label: 'VAT', displayName: 'Royaume-Uni'),
    _Rule(iso2: 'DE', iso3: 'DEU', namePatterns: ['germany', 'allemagne', 'deutschland'],
        rate: 0.19, label: 'VAT', displayName: 'Allemagne'),
    _Rule(iso2: 'IT', iso3: 'ITA', namePatterns: ['italy', 'italie', 'italia'],
        rate: 0.22, label: 'IVA', displayName: 'Italie'),
    _Rule(iso2: 'ES', iso3: 'ESP', namePatterns: ['spain', 'espagne', 'españa'],
        rate: 0.21, label: 'IVA', displayName: 'Espagne'),
    _Rule(iso2: 'BE', iso3: 'BEL',
        namePatterns: ['belgium', 'belgique', 'belgie'],
        rate: 0.21, label: 'TVA', displayName: 'Belgique'),
    _Rule(iso2: 'NL', iso3: 'NLD',
        namePatterns: ['netherlands', 'pays-bas', 'holland', 'nederland'],
        rate: 0.21, label: 'BTW', displayName: 'Pays-Bas'),
    _Rule(iso2: 'PT', iso3: 'PRT', namePatterns: ['portugal'],
        rate: 0.23, label: 'IVA', displayName: 'Portugal'),
    _Rule(iso2: 'CH', iso3: 'CHE', namePatterns: ['switzerland', 'suisse', 'schweiz'],
        rate: 0.081, label: 'TVA', displayName: 'Suisse'),
    _Rule(iso2: 'SE', iso3: 'SWE', namePatterns: ['sweden', 'suede', 'suède', 'sverige'],
        rate: 0.25, label: 'Moms', displayName: 'Suède'),
    _Rule(iso2: 'NO', iso3: 'NOR', namePatterns: ['norway', 'norvège', 'norge'],
        rate: 0.25, label: 'MVA', displayName: 'Norvège'),
    _Rule(iso2: 'DK', iso3: 'DNK', namePatterns: ['denmark', 'danemark', 'danmark'],
        rate: 0.25, label: 'Moms', displayName: 'Danemark'),
    _Rule(iso2: 'LU', iso3: 'LUX', namePatterns: ['luxembourg'],
        rate: 0.17, label: 'TVA', displayName: 'Luxembourg'),
    _Rule(iso2: 'IE', iso3: 'IRL', namePatterns: ['ireland', 'irlande'],
        rate: 0.23, label: 'VAT', displayName: 'Irlande'),

    // ── Amériques ─────────────────────────────────────────────────────────────
    // USA : pas de taxe fédérale sur la vente — on n'applique pas de taxe
    // pour une vente internationale (import depuis l'Afrique < 800 USD → exonéré de customs duty).
    // Taux 0 affiché explicitement comme "Hors taxe" et non "Exempt" pour éviter la confusion.
    // USA : taux moyen national par défaut (affiné par état via forRegion)
    _Rule(iso2: 'US', iso3: 'USA',
        namePatterns: ['united states', 'etats-unis', 'états-unis', 'united states of america'],
        rate: 0.08, label: 'Sales Tax', displayName: 'États-Unis'),
    _Rule(iso2: 'CA', iso3: 'CAN', namePatterns: ['canada'],
        rate: 0.05, label: 'TPS', displayName: 'Canada'),
    _Rule(iso2: 'BR', iso3: 'BRA', namePatterns: ['brazil', 'bresil', 'brésil', 'brasil'],
        rate: 0.12, label: 'ICMS', displayName: 'Brésil'),
    _Rule(iso2: 'MX', iso3: 'MEX', namePatterns: ['mexique', 'mexico'],
        rate: 0.16, label: 'IVA', displayName: 'Mexique'),

    // ── Asie / Océanie ────────────────────────────────────────────────────────
    _Rule(iso2: 'AU', iso3: 'AUS', namePatterns: ['australia', 'australie'],
        rate: 0.10, label: 'GST', displayName: 'Australie'),
    _Rule(iso2: 'NZ', iso3: 'NZL',
        namePatterns: ['new zealand', 'nouvelle-zelande', 'nouvelle-zélande'],
        rate: 0.15, label: 'GST', displayName: 'Nouvelle-Zélande'),
    _Rule(iso2: 'JP', iso3: 'JPN', namePatterns: ['japan', 'japon'],
        rate: 0.10, label: 'Consumption Tax', displayName: 'Japon'),
    _Rule(iso2: 'CN', iso3: 'CHN', namePatterns: ['china', 'chine', 'zhongguo'],
        rate: 0.13, label: 'VAT', displayName: 'Chine'),
    _Rule(iso2: 'IN', iso3: 'IND', namePatterns: ['india', 'inde'],
        rate: 0.18, label: 'GST', displayName: 'Inde'),
    _Rule(iso2: 'SG', iso3: 'SGP', namePatterns: ['singapore', 'singapour'],
        rate: 0.09, label: 'GST', displayName: 'Singapour'),
    _Rule(iso2: 'AE', iso3: 'ARE',
        namePatterns: ['emirates', 'emirats', 'émirats', 'uae', 'dubai', 'abu dhabi'],
        rate: 0.05, label: 'VAT', displayName: 'Émirats Arabes Unis'),
    _Rule(iso2: 'SA', iso3: 'SAU',
        namePatterns: ['saudi', 'arabie saoudite', 'arabia'],
        rate: 0.15, label: 'VAT', displayName: 'Arabie Saoudite'),
  ];

  /// Returns the [TaxConfig] for [country] (ISO code or country name, any case).
  /// Returns [TaxConfig.none()] if the country is blank or not found.
  static TaxConfig forCountry(String country) {
    final raw = country.trim();
    if (raw.isEmpty) return TaxConfig.none();

    final input = raw.toLowerCase();
    final len = input.length;

    // ── Pass 1 : exact ISO alpha-2 match (2 chars) ──────────────────────────
    if (len == 2) {
      for (final r in _rules) {
        if (r.iso2.toLowerCase() == input) return _toConfig(r);
      }
      return TaxConfig.none(); // 2-char input that's not a valid ISO2 → no match
    }

    // ── Pass 2 : exact ISO alpha-3 match (3 chars) ──────────────────────────
    if (len == 3) {
      for (final r in _rules) {
        if (r.iso3.toLowerCase() == input) return _toConfig(r);
        // Also try exact name match for very short country names (e.g. "Togo")
        for (final p in r.namePatterns) {
          if (p == input) return _toConfig(r);
        }
      }
      return TaxConfig.none();
    }

    // ── Pass 3 : name pattern (single-direction contains, input ≥ 4 chars) ──
    for (final r in _rules) {
      // Exact name match first
      for (final p in r.namePatterns) {
        if (p == input) return _toConfig(r);
      }
    }
    for (final r in _rules) {
      // Partial name match (input contains pattern)
      for (final p in r.namePatterns) {
        if (p.length >= 4 && input.contains(p)) return _toConfig(r);
      }
    }

    return TaxConfig.none();
  }

  static TaxConfig _toConfig(_Rule r) => TaxConfig(
        rate: r.rate,
        label: r.label,
        country: r.displayName,
        iso2: r.iso2,
      );

  /// Returns all supported countries sorted alphabetically.
  static List<({String name, String iso2})> get supportedCountries => _rules
      .map((r) => (name: r.displayName, iso2: r.iso2))
      .toList()
    ..sort((a, b) => a.name.compareTo(b.name));

  /// Converts an ISO 3166-1 alpha-2 code to its flag emoji.
  static String flagEmoji(String iso2) {
    if (iso2.length != 2) return '';
    const base = 0x1F1E6 - 0x41;
    final upper = iso2.toUpperCase();
    return String.fromCharCode(upper.codeUnitAt(0) + base) +
        String.fromCharCode(upper.codeUnitAt(1) + base);
  }

  /// Retourne le TaxConfig précis pour un pays + région (état US / province CA).
  /// Priorité : région > pays.
  static TaxConfig forRegion(String country, String region) {
    final iso2 = forCountry(country).iso2;
    if (iso2 == 'US') {
      final code = region.trim().toUpperCase();
      final rate = _usStateTax[code];
      if (rate != null) {
        return TaxConfig(
          rate: rate,
          label: 'Sales Tax',
          country: 'États-Unis',
          iso2: 'US',
        );
      }
    }
    if (iso2 == 'CA') {
      final code = region.trim().toUpperCase();
      final entry = _caProvinceTax[code];
      if (entry != null) {
        return TaxConfig(
          rate: entry.$1,
          label: entry.$2,
          country: 'Canada',
          iso2: 'CA',
        );
      }
    }
    return forCountry(country);
  }

  /// Régions disponibles pour un pays (code ISO2 → liste de (code, nom))
  static List<({String code, String name})>? regionsFor(String iso2) {
    if (iso2 == 'US') return _usStates;
    if (iso2 == 'CA') return _caProvinces;
    return null;
  }

  // ── États US — taux combinés état + local moyen (Tax Foundation 2024) ──────
  // Source : https://taxfoundation.org/data/all/state/state-and-local-sales-tax-rates-2024/

  static const _usStateTax = <String, double>{
    'AL': 0.0924, 'AK': 0.0176, 'AZ': 0.0837, 'AR': 0.0946,
    'CA': 0.0882, 'CO': 0.0777, 'CT': 0.0635, 'DE': 0.0000,
    'FL': 0.0702, 'GA': 0.0733, 'HI': 0.0444, 'ID': 0.0602,
    'IL': 0.0886, 'IN': 0.0700, 'IA': 0.0694, 'KS': 0.0868,
    'KY': 0.0600, 'LA': 0.0955, 'ME': 0.0550, 'MD': 0.0600,
    'MA': 0.0625, 'MI': 0.0600, 'MN': 0.0749, 'MS': 0.0707,
    'MO': 0.0829, 'MT': 0.0000, 'NE': 0.0694, 'NV': 0.0823,
    'NH': 0.0000, 'NJ': 0.0660, 'NM': 0.0783, 'NY': 0.0852,
    'NC': 0.0698, 'ND': 0.0696, 'OH': 0.0724, 'OK': 0.0898,
    'OR': 0.0000, 'PA': 0.0634, 'RI': 0.0700, 'SC': 0.0744,
    'SD': 0.0640, 'TN': 0.0955, 'TX': 0.0819, 'UT': 0.0718,
    'VT': 0.0624, 'VA': 0.0575, 'WA': 0.0938, 'WV': 0.0655,
    'WI': 0.0543, 'WY': 0.0533, 'DC': 0.0600,
  };

  static const _usStates = <({String code, String name})>[
    (code: 'AL', name: 'Alabama'),        (code: 'AK', name: 'Alaska'),
    (code: 'AZ', name: 'Arizona'),        (code: 'AR', name: 'Arkansas'),
    (code: 'CA', name: 'California'),     (code: 'CO', name: 'Colorado'),
    (code: 'CT', name: 'Connecticut'),    (code: 'DE', name: 'Delaware'),
    (code: 'DC', name: 'Washington D.C.'),(code: 'FL', name: 'Florida'),
    (code: 'GA', name: 'Georgia'),        (code: 'HI', name: 'Hawaii'),
    (code: 'ID', name: 'Idaho'),          (code: 'IL', name: 'Illinois'),
    (code: 'IN', name: 'Indiana'),        (code: 'IA', name: 'Iowa'),
    (code: 'KS', name: 'Kansas'),         (code: 'KY', name: 'Kentucky'),
    (code: 'LA', name: 'Louisiana'),      (code: 'ME', name: 'Maine'),
    (code: 'MD', name: 'Maryland'),       (code: 'MA', name: 'Massachusetts'),
    (code: 'MI', name: 'Michigan'),       (code: 'MN', name: 'Minnesota'),
    (code: 'MS', name: 'Mississippi'),    (code: 'MO', name: 'Missouri'),
    (code: 'MT', name: 'Montana'),        (code: 'NE', name: 'Nebraska'),
    (code: 'NV', name: 'Nevada'),         (code: 'NH', name: 'New Hampshire'),
    (code: 'NJ', name: 'New Jersey'),     (code: 'NM', name: 'New Mexico'),
    (code: 'NY', name: 'New York'),       (code: 'NC', name: 'North Carolina'),
    (code: 'ND', name: 'North Dakota'),   (code: 'OH', name: 'Ohio'),
    (code: 'OK', name: 'Oklahoma'),       (code: 'OR', name: 'Oregon'),
    (code: 'PA', name: 'Pennsylvania'),   (code: 'RI', name: 'Rhode Island'),
    (code: 'SC', name: 'South Carolina'), (code: 'SD', name: 'South Dakota'),
    (code: 'TN', name: 'Tennessee'),      (code: 'TX', name: 'Texas'),
    (code: 'UT', name: 'Utah'),           (code: 'VT', name: 'Vermont'),
    (code: 'VA', name: 'Virginia'),       (code: 'WA', name: 'Washington'),
    (code: 'WV', name: 'West Virginia'),  (code: 'WI', name: 'Wisconsin'),
    (code: 'WY', name: 'Wyoming'),
  ];

  // ── Provinces Canada — GST/HST/PST (Agence du revenu du Canada 2024) ───────

  // (taux, label)
  static const _caProvinceTax = <String, (double, String)>{
    'AB': (0.05,     'GST'),           // Alberta
    'BC': (0.12,     'GST+PST'),       // Colombie-Britannique
    'MB': (0.12,     'GST+PST'),       // Manitoba
    'NB': (0.15,     'TVH'),           // Nouveau-Brunswick
    'NL': (0.15,     'TVH'),           // Terre-Neuve
    'NS': (0.15,     'TVH'),           // Nouvelle-Écosse
    'NT': (0.05,     'TPS'),           // Territoires du Nord-Ouest
    'NU': (0.05,     'TPS'),           // Nunavut
    'ON': (0.13,     'TVH'),           // Ontario
    'PE': (0.15,     'TVH'),           // Île-du-Prince-Édouard
    'QC': (0.14975,  'TPS+TVQ'),       // Québec
    'SK': (0.11,     'TPS+TVP'),       // Saskatchewan
    'YT': (0.05,     'TPS'),           // Yukon
  };

  static const _caProvinces = <({String code, String name})>[
    (code: 'AB', name: 'Alberta'),
    (code: 'BC', name: 'Colombie-Britannique'),
    (code: 'MB', name: 'Manitoba'),
    (code: 'NB', name: 'Nouveau-Brunswick'),
    (code: 'NL', name: 'Terre-Neuve-et-Labrador'),
    (code: 'NS', name: 'Nouvelle-Écosse'),
    (code: 'NT', name: 'Territoires du Nord-Ouest'),
    (code: 'NU', name: 'Nunavut'),
    (code: 'ON', name: 'Ontario'),
    (code: 'PE', name: 'Île-du-Prince-Édouard'),
    (code: 'QC', name: 'Québec'),
    (code: 'SK', name: 'Saskatchewan'),
    (code: 'YT', name: 'Yukon'),
  ];
}
