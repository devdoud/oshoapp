import '../../../utils/helpers/helper_functions.dart';

class OrderModel {
  final String id;
  final String userId;
  final String status;
  final double totalAmount;
  final DateTime orderDate;
  final String paymentMethod;
  final Map<String, dynamic>? shippingAddress;
  final DateTime? deliveryDate;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    this.userId = '',
    required this.status,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    this.paymentMethod = 'Paypal',
    this.shippingAddress,
    this.deliveryDate,
  });

  String get formattedOrderDate => OHelperFunctions.getFormattedDate(orderDate);

  String get orderStatusText {
    switch (status) {
      case 'delivered':
        return 'Livré';
      case 'shipped':
        return 'Expédié';
      case 'processing':
        return 'En traitement';
      case 'pending':
      default:
        return 'En cours';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'status': status,
      'total_amount': totalAmount,
      'created_at': orderDate.toIso8601String(),
      'payment_method':
          paymentMethod, // Assuming column exists or mapping to payment_status
      'shipping_address': shippingAddress,
      'delivery_date': deliveryDate?.toIso8601String(),
      // items are usually handled separately in SQL but usefulness in NoSQL style objects
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      status: json['status'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      orderDate: DateTime.parse(json['created_at']),
      paymentMethod: json['payment_method'] ?? 'Card',
      shippingAddress: json['shipping_address'] as Map<String, dynamic>?,
      deliveryDate: json['delivery_date'] != null
          ? DateTime.parse(json['delivery_date'])
          : null,
      // Supabase join returns 'order_items', fallback to 'items'
      items: ((json['order_items'] ?? json['items']) as List<dynamic>? ?? [])
          .map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class OrderItemModel {
  String? id;
  String productId;
  String? measurementProfileId;
  int quantity;
  double price;
  Map<String, dynamic>? customizationDetails;
  Map<String, dynamic>? measurementSnapshot;

  OrderItemModel({
    this.id,
    required this.productId,
    this.measurementProfileId,
    required this.quantity,
    required this.price,
    this.customizationDetails,
    this.measurementSnapshot,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'measurement_profile_id': measurementProfileId,
      'quantity': quantity,
      'price': price,
      'customization_details': customizationDetails,
      'measurement_snapshot': measurementSnapshot,
    };
  }

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'],
      productId: json['product_id'],
      measurementProfileId: json['measurement_profile_id'],
      quantity: json['quantity'] ?? 1,
      price: (json['price'] as num).toDouble(),
      customizationDetails: json['customization_details'],
      measurementSnapshot: json['measurement_snapshot'],
    );
  }
}
