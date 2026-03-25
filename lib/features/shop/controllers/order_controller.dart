import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:osho/data/repositories/shop/order_repository.dart';
import 'package:osho/features/shop/models/order_model.dart';

class OrderController extends GetxController {
  static OrderController get instance => Get.find();

  final _repo = Get.put(OrderRepository());
  final _supabase = Supabase.instance.client;

  final orders = <OrderModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  RealtimeChannel? _ordersChannel;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
    _subscribeToOrderUpdates();
  }

  @override
  void onClose() {
    _ordersChannel?.unsubscribe();
    super.onClose();
  }

  /// Charge les commandes depuis Supabase
  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final result = await _repo.fetchUserOrders();
      orders.assignAll(result);
    } catch (e) {
      errorMessage.value = 'Impossible de charger les commandes. Réessayez.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Écoute en temps réel les nouvelles commandes de l'utilisateur
  void _subscribeToOrderUpdates() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    _ordersChannel = _supabase
        .channel('public:orders:user_id=eq.$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'orders',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            // Recharge la liste lors d'une nouvelle commande
            fetchOrders();
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'orders',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            // Recharge pour mettre à jour les statuts (ex. tailleur accepte)
            fetchOrders();
          },
        )
        .subscribe();
  }

  /// Couleur selon le statut
  static Map<String, dynamic> statusStyle(String status) {
    switch (status) {
      case 'delivered':
        return {'color': 0xFF4CAF50, 'label': 'Livré'};
      case 'shipped':
        return {'color': 0xFF2196F3, 'label': 'Expédié'};
      case 'processing':
        return {'color': 0xFFFF9800, 'label': 'En traitement'};
      case 'pending':
      default:
        return {'color': 0xFFE91E8C, 'label': 'En cours'};
    }
  }
}
