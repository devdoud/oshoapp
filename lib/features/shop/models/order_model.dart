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
  final bool customerConfirmed;
  final DateTime? customerReceivedAt;
  final String? primaryTailorId;
  final TailorReviewModel? tailorReview;

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
    this.customerConfirmed = false,
    this.customerReceivedAt,
    this.primaryTailorId,
    this.tailorReview,
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
      'customer_confirmed': customerConfirmed,
      'customer_received_at': customerReceivedAt?.toIso8601String(),
      'primary_tailor_id': primaryTailorId,
      // items are usually handled separately in SQL but usefulness in NoSQL style objects
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final reviews = (json['tailor_reviews'] as List<dynamic>? ?? [])
        .map((item) => TailorReviewModel.fromJson(item as Map<String, dynamic>))
        .toList();

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
      customerConfirmed: json['customer_confirmed'] == true,
      customerReceivedAt: json['customer_received_at'] != null
          ? DateTime.parse(json['customer_received_at'])
          : null,
      primaryTailorId: json['primary_tailor_id'] as String?,
      tailorReview: reviews.isEmpty ? null : reviews.first,
      // Supabase join returns 'order_items', fallback to 'items'
      items: ((json['order_items'] ?? json['items']) as List<dynamic>? ?? [])
          .map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TailorReviewModel {
  final String id;
  final String orderId;
  final String tailorId;
  final String customerId;
  final int rating;
  final String? reviewText;
  final DateTime createdAt;

  TailorReviewModel({
    required this.id,
    required this.orderId,
    required this.tailorId,
    required this.customerId,
    required this.rating,
    this.reviewText,
    required this.createdAt,
  });

  factory TailorReviewModel.fromJson(Map<String, dynamic> json) {
    return TailorReviewModel(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      tailorId: json['tailor_id'] as String,
      customerId: json['customer_id'] as String,
      rating: (json['rating'] as num).toInt(),
      reviewText: json['review_text'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
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
