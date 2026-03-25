import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:osho/data/repositories/shop/order_repository.dart';
import 'package:osho/features/shop/models/order_model.dart';

class TailorOrderController extends GetxController {
  static TailorOrderController get instance => Get.find();

  final _repo = Get.put(OrderRepository());
  final _supabase = Supabase.instance.client;

  final pendingOrders = <OrderModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  RealtimeChannel? _ordersChannel;

  @override
  void onInit() {
    super.onInit();
    fetchPendingOrders();
    _subscribeToNewOrders();
  }

  @override
  void onClose() {
    _ordersChannel?.unsubscribe();
    super.onClose();
  }

  /// Charge les commandes en attente depuis Supabase
  Future<void> fetchPendingOrders() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final result = await _repo.fetchPendingOrders();
      pendingOrders.assignAll(result);
    } catch (e) {
      errorMessage.value = 'Impossible de charger les commandes en attente. Réessayez.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Écoute en temps réel les nouvelles commandes
  void _subscribeToNewOrders() {
    _ordersChannel = _supabase
        .channel('public:orders:status=eq.pending')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'orders',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'status',
            value: 'pending',
          ),
          callback: (payload) {
            // Ajouter la nouvelle commande à la liste
            final newOrder = OrderModel.fromJson(payload.newRecord);
            pendingOrders.insert(0, newOrder);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'orders',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'status',
            value: 'pending',
          ),
          callback: (payload) {
            // Mettre à jour le statut si changé
            final updatedOrder = OrderModel.fromJson(payload.newRecord);
            final index = pendingOrders.indexWhere((o) => o.id == updatedOrder.id);
            if (index != -1) {
              if (updatedOrder.status != 'pending') {
                // Retirer si plus en pending
                pendingOrders.removeAt(index);
              } else {
                pendingOrders[index] = updatedOrder;
              }
            }
          },
        )
        .subscribe();
  }

  /// Accepter une commande (changer statut à 'processing')
  Future<void> acceptOrder(String orderId) async {
    try {
      await _supabase
          .from('orders')
          .update({'status': 'processing'})
          .eq('id', orderId);
      // La mise à jour sera gérée par le callback real-time
    } catch (e) {
      throw 'Erreur lors de l\'acceptation de la commande: $e';
    }
  }
}