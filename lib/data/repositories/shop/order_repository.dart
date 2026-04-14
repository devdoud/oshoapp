import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../features/shop/models/order_model.dart';

class OrderRepository extends GetxController {
  static OrderRepository get instance => Get.find();

  final _supabase = Supabase.instance.client;

  Future<List<OrderModel>> fetchUserOrders() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from('orders')
          .select('*, order_items(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final data = List<Map<String, dynamic>>.from(response);
      return data.map((json) => OrderModel.fromJson(json)).toList();
    } catch (e) {
      throw 'Error fetching orders: $e';
    }
  }

  Future<List<OrderModel>> fetchPendingOrders() async {
    try {
      final response = await _supabase
          .from('orders')
          .select('*, order_items(*)')
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      final data = List<Map<String, dynamic>>.from(response);
      return data.map((json) => OrderModel.fromJson(json)).toList();
    } catch (e) {
      throw 'Error fetching pending orders: $e';
    }
  }

  Future<OrderModel> saveOrder(
    OrderModel order,
    String userId, {
    String paymentStatus = 'pending',
  }) async {
    try {
      final orderData = {
        'user_id': userId,
        'status': order.status,
        'total_amount': order.totalAmount,
        'payment_status': paymentStatus,
        'payment_method': order.paymentMethod,
        'shipping_address': order.shippingAddress,
      };

      final orderResponse =
          await _supabase.from('orders').insert(orderData).select().single();

      final orderId = orderResponse['id'];

      for (var item in order.items) {
        Map<String, dynamic>? snapshot = item.measurementSnapshot;
        if (item.measurementProfileId != null && snapshot == null) {
          final profileData = await _supabase
              .from('measurement_profiles')
              .select()
              .eq('id', item.measurementProfileId!)
              .maybeSingle();
          if (profileData != null) {
            snapshot = profileData;
          }
        }

        final itemData = {
          'order_id': orderId,
          'product_id': item.productId,
          'quantity': item.quantity,
          'price': item.price,
          'measurement_profile_id': item.measurementProfileId,
          'customization_details': item.customizationDetails,
          'measurement_snapshot': snapshot,
        };

        await _supabase.from('order_items').insert(itemData);
      }

      return OrderModel(
        id: orderId,
        userId: userId,
        status: order.status,
        items: order.items,
        totalAmount: order.totalAmount,
        orderDate: order.orderDate,
        paymentMethod: order.paymentMethod,
        shippingAddress: order.shippingAddress,
        deliveryDate: order.deliveryDate,
      );
    } catch (e) {
      throw 'Error creating order: $e';
    }
  }
}
