class CartItemModel {
  final String productId;
  final String title;
  final double price;
  final String image;
  int quantity;

  CartItemModel({
    required this.productId,
    required this.title,
    required this.price,
    required this.image,
    this.quantity = 1,
  });

  double get lineTotal => price * quantity;

  CartItemModel copyWith({
    String? productId,
    String? title,
    double? price,
    String? image,
    int? quantity,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      title: title ?? this.title,
      price: price ?? this.price,
      image: image ?? this.image,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'title': title,
      'price': price,
      'image': image,
      'quantity': quantity,
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
    };
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['product_id'] ?? '',
      title: json['title'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      image: json['image'] ?? '',
      quantity: json['quantity'] ?? 1,
    );
  }

  factory CartItemModel.fromSupabase(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['product_id']?.toString() ?? '',
      title: json['title'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      image: json['image'] ?? '',
      quantity: json['quantity'] ?? 1,
    );
  }
}
