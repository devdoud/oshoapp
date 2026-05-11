class CartItemModel {
  final String productId;
  final String title;
  final double price;
  final String image;
  int quantity;

  /// Spécifications fixes du produit (tissu, broderie, accessoire)
  /// Renseignées automatiquement depuis le ProductModel au moment de l'ajout.
  final Map<String, dynamic>? customizationDetails;

  CartItemModel({
    required this.productId,
    required this.title,
    required this.price,
    required this.image,
    this.quantity = 1,
    this.customizationDetails,
  });

  double get lineTotal => price * quantity;

  CartItemModel copyWith({
    String? productId,
    String? title,
    double? price,
    String? image,
    int? quantity,
    Map<String, dynamic>? customizationDetails,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      title: title ?? this.title,
      price: price ?? this.price,
      image: image ?? this.image,
      quantity: quantity ?? this.quantity,
      customizationDetails: customizationDetails ?? this.customizationDetails,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'title': title,
      'price': price,
      'image': image,
      'quantity': quantity,
      'customization_details': customizationDetails,
    };
  }

  Map<String, dynamic> toSupabase(String userId) {
    return {
      'user_id': userId,
      'product_id': productId,
      'title': title,
      'price': price,
      'image': image,
      'quantity': quantity,
      'customization_details': customizationDetails,
    };
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['product_id'] ?? '',
      title: json['title'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      image: json['image'] ?? '',
      quantity: json['quantity'] ?? 1,
      customizationDetails: json['customization_details'] != null
          ? Map<String, dynamic>.from(json['customization_details'] as Map)
          : null,
    );
  }

  factory CartItemModel.fromSupabase(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['product_id']?.toString() ?? '',
      title: json['title'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      image: json['image'] ?? '',
      quantity: json['quantity'] ?? 1,
      customizationDetails: json['customization_details'] != null
          ? Map<String, dynamic>.from(json['customization_details'] as Map)
          : null,
    );
  }
}
