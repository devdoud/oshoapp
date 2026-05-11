class ProductTagModel {
  final String id;
  final String name;
  final String label;
  final String color;
  final int sortOrder;

  const ProductTagModel({
    required this.id,
    required this.name,
    required this.label,
    this.color = '#181818',
    this.sortOrder = 0,
  });

  factory ProductTagModel.fromJson(Map<String, dynamic> json) {
    return ProductTagModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String,
      label: json['label'] as String,
      color: json['color'] as String? ?? '#181818',
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  /// Used offline / before first Supabase fetch
  static List<ProductTagModel> get defaults => const [
        ProductTagModel(
            id: 'nouveaute', name: 'nouveaute', label: 'Nouveauté', sortOrder: 1),
        ProductTagModel(
            id: 'bestseller', name: 'bestseller', label: 'Best Seller', sortOrder: 2),
        ProductTagModel(
            id: 'promo', name: 'promo', label: 'Promo', sortOrder: 3),
        ProductTagModel(
            id: 'exclusif', name: 'exclusif', label: 'Exclusif', sortOrder: 4),
        ProductTagModel(
            id: 'artisanal', name: 'artisanal', label: 'Artisanal', sortOrder: 5),
        ProductTagModel(
            id: 'traditionnel',
            name: 'traditionnel',
            label: 'Traditionnel',
            sortOrder: 6),
        ProductTagModel(
            id: 'edition_limitee',
            name: 'edition_limitee',
            label: 'Édition Limitée',
            sortOrder: 7),
        ProductTagModel(
            id: 'mariage', name: 'mariage', label: 'Mariage', sortOrder: 8),
        ProductTagModel(
            id: 'ceremonie', name: 'ceremonie', label: 'Cérémonie', sortOrder: 9),
        ProductTagModel(
            id: 'casual', name: 'casual', label: 'Casual', sortOrder: 10),
      ];
}
