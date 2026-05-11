import 'dart:convert';

class ProductModel {
  String id;
  String title;
  double price;
  String thumbnail;
  String? description;
  String? categoryId;
  String? categoryType;
  String? categoryName;
  String? categorySlug;
  String? categoryStyle;
  List<String>? images;
  List<Map<String, dynamic>>? customizationOptions;
  Map<String, dynamic>? asset3D;
  bool? isTraditional;
  String? traditionalOrigin;
  String? difficulty;
  int? estimatedDays;
  List? measurements;
  String sku;
  bool isFeatured;

  // --- Spécifications fixes du produit (définies à la création) ---
  String? fabric;      // Tissu / Matière (ex: "Bazin Riche", "Kente", "Wax")
  String? embroidery;  // Broderie / Coupe / Style (ex: "Broderie standard", "Col V brodé")
  String? accessory;   // Accessoire / Finition (ex: "Sans accessoire", "Ceinture tissu")

  // --- Tags prédéfinis (ex: ["nouveaute", "bestseller"]) ---
  List<String> tags;

  // --- Listes d'options spécifiques au produit pour la personnalisation ---
  // Chaque entrée : {name: String, image_url: String}
  // Vide = utiliser le catalogue global filtré par le type du champ correspondant
  List<Map<String, dynamic>> fabricOptions;
  List<Map<String, dynamic>> embroideryOptions;
  List<Map<String, dynamic>> finishOptions;

  // --- "Perfect For" / "Parfait pour" ---
  List<String>? perfectFor;

  // --- Prix en dollars (saisi manuellement, indépendant du prix FCFA) ---
  double? priceUsd;

  DateTime? createdAt;

  ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.thumbnail,
    required this.sku,
    this.description,
    this.categoryId,
    this.categoryType,
    this.categoryName,
    this.categorySlug,
    this.categoryStyle,
    this.images,
    this.customizationOptions,
    this.asset3D,
    this.isTraditional,
    this.traditionalOrigin,
    this.difficulty,
    this.estimatedDays,
    this.measurements,
    this.isFeatured = false,
    this.fabric,
    this.embroidery,
    this.accessory,
    this.tags = const [],
    this.fabricOptions = const [],
    this.embroideryOptions = const [],
    this.finishOptions = const [],
    this.perfectFor,
    this.priceUsd,
    this.createdAt,
  });

  /// Create Empty func for clean code
  static ProductModel empty() =>
      ProductModel(id: '', title: '', price: 0, thumbnail: '', sku: '');

  /// Json Format
  toJson() {
    return {
      'SKU': sku,
      'Title': title,
      'Price': price,
      'Thumbnail': thumbnail,
      'Description': description,
      'CategoryId': categoryId,
      'CategoryType': categoryType,
      'CategoryName': categoryName,
      'CategorySlug': categorySlug,
      'CategoryStyle': categoryStyle,
      'Images': images ?? [],
      'CustomizationOptions': customizationOptions ?? [],
      'Asset3D': asset3D,
      'IsTraditional': isTraditional,
      'TraditionalOrigin': traditionalOrigin,
      'Difficulty': difficulty,
      'EstimatedDays': estimatedDays,
      'Measurements': measurements ?? [],
      'IsFeatured': isFeatured,
      'fabric': fabric,
      'embroidery': embroidery,
      'accessory': accessory,
      'tags': tags,
      'fabric_options': fabricOptions,
      'embroidery_options': embroideryOptions,
      'finish_options': finishOptions,
      'perfect_for': perfectFor,
      'price_usd': priceUsd,
    };
  }

  /// Map Json document from NodeJS/API to Model
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['name'] is Map
          ? json['name']['fr'] ?? json['name']['en'] ?? ''
          : json['name'] ?? json['title'] ?? '',
      price: double.parse(
          (json['basePrice'] ?? json['base_price'] ?? json['price'] ?? 0.0)
              .toString()),
      thumbnail: (() {
        // Helper pour extraire l'URL du thumbnail
        var thumb = json['thumbnail'] ?? json['image'];

        // Si thumbnail est une string qui ressemble ? du JSON, la parser
        if (thumb is String && thumb.trim().startsWith('{')) {
          try {
            var parsed = jsonDecode(thumb);
            if (parsed is Map && parsed['url'] != null) {
              return parsed['url'].toString();
            }
          } catch (e) {
            // Si le parsing ?choue, continuer
          }
        }

        // Si thumbnail est un objet JSON {"url": "..."}
        if (thumb is Map) {
          return thumb['url']?.toString() ?? '';
        }

        // Si thumbnail est une string simple
        if (thumb is String && thumb.isNotEmpty) {
          return thumb;
        }

        // Sinon, essayer de récupérer depuis images
        if (json['images'] != null && (json['images'] as List).isNotEmpty) {
          var firstImage = (json['images'] as List)[0];
          if (firstImage is Map) {
            return firstImage['url']?.toString() ?? '';
          }
          if (firstImage is String) {
            return firstImage;
          }
        }

        return '';
      })(),
      sku: json['slug'] ?? json['_id'] ?? json['sku'] ?? '',
      description: json['description'] is Map
          ? json['description']['fr'] ?? json['description']['en'] ?? ''
          : json['description'] ?? '',
      categoryId: json['category'] is Map
          ? json['category']['_id'] ?? ''
          : json['category_id'] ?? json['categoryId'] ?? '',
      categoryType: (() {
        var catObj = json['category'];
        if (catObj is List && catObj.isNotEmpty) {
          catObj = catObj[0];
        }

        // First try the explicit type fields
        String type = catObj is Map
            ? catObj['type'] ?? ''
            : json['category_type'] ?? '';

        // If empty, try to derive from the category name or slug (e.g. "Homme", "Femme")
        if (type.isEmpty) {
          String nameFallback = catObj is Map
              ? (catObj['name'] is Map
                  ? catObj['name']['fr'] ?? catObj['name']['en'] ?? ''
                  : catObj['name'] ?? '')
              : json['category_name'] ?? '';

          if (nameFallback.toLowerCase().contains('homme')) {
            return 'homme';
          } else if (nameFallback.toLowerCase().contains('femme')) {
            return 'femme';
          }
        }
        return type.toLowerCase();
      })(),
      categoryName: json['category'] is Map
          ? json['category']['name'] is Map
              ? json['category']['name']['fr'] ?? ''
              : ''
          : json['category_name'] ?? '',
      categorySlug: json['category'] is Map
          ? json['category']['slug'] ?? ''
          : json['category_slug'] ?? '',
      categoryStyle: json['category'] is Map
          ? json['category']['style'] ?? ''
          : json['category_style'] ?? '',
      images: json['images'] != null
          ? (json['images'] as List)
              .map((img) {
                if (img is Map) {
                  return img['url']?.toString() ?? '';
                } else if (img is String) {
                  // Si c'est une string JSON, la parser
                  if (img.trim().startsWith('{')) {
                    try {
                      var parsed = jsonDecode(img);
                      if (parsed is Map && parsed['url'] != null) {
                        return parsed['url'].toString();
                      }
                    } catch (_) {}
                  }
                  return img;
                }
                return '';
              })
              .toList()
              .cast<String>()
          : [],
      customizationOptions: (() {
        final options = json['customization_options'] ?? json['customizationOptions'];
        if (options is List) {
          return List<Map<String, dynamic>>.from(options);
        }
        return <Map<String, dynamic>>[];
      })(),
      asset3D: json['asset_3d'] ?? json['asset3D'],
      isTraditional: json['is_traditional'] ?? json['isTraditional'] ?? false,
      traditionalOrigin:
          json['traditional_origin'] ?? json['traditionalOrigin'] ?? '',
      difficulty: json['difficulty'] ?? '',
      estimatedDays: json['estimated_days'] ?? json['estimatedDays'] ?? 0,
      measurements: json['measurements'] ?? [],
      isFeatured: json['is_featured'] ?? json['isFeatured'] ?? false,
      fabric: json['fabric'] as String?,
      embroidery: json['embroidery'] as String?,
      accessory: json['accessory'] as String?,
      tags: json['tags'] != null
          ? List<String>.from((json['tags'] as List).map((e) => e.toString()))
          : [],
      fabricOptions: _parseOptionList(json['fabric_options']),
      embroideryOptions: _parseOptionList(json['embroidery_options']),
      finishOptions: _parseOptionList(json['finish_options']),
      perfectFor: _parseStringList(json['perfect_for']),
      priceUsd: json['price_usd'] != null
          ? double.tryParse(json['price_usd'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}

List<String> _parseStringList(dynamic raw) {
  if (raw == null) return [];
  if (raw is List) return raw.map((e) => e.toString()).toList();
  if (raw is String && raw.trim().isNotEmpty) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) return decoded.map((e) => e.toString()).toList();
    } catch (_) {}
  }
  return [];
}

List<Map<String, dynamic>> _parseOptionList(dynamic raw) {
  if (raw == null) return [];
  if (raw is List) {
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
  if (raw is String && raw.trim().isNotEmpty) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (_) {}
  }
  return [];
}
