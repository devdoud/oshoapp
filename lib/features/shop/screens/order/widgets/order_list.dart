import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/features/shop/controllers/order_controller.dart';
import 'package:osho/features/shop/models/order_model.dart';
import 'package:osho/features/shop/screens/orders/order_tracking.dart';
import 'package:osho/utils/constants/sizes.dart';

class OOrderListItems extends StatelessWidget {
  const OOrderListItems({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialise le contrôleur si pas encore fait
    final controller = Get.put(OrderController());

    return Obx(() {
      // --- État chargement
      if (controller.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 60),
            child: CircularProgressIndicator(),
          ),
        );
      }

      // --- État erreur
      if (controller.errorMessage.value.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Iconsax.warning_2, size: 52, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: controller.fetchOrders,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        );
      }

      // --- État vide
      if (controller.orders.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 60),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Iconsax.box, size: 48, color: Colors.grey[400]),
                ),
                const SizedBox(height: 20),
                Text(
                  'Aucune commande',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Vos commandes apparaîtront ici\naprès votre premier achat.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
              ],
            ),
          ),
        );
      }

      // --- Liste des commandes
      return RefreshIndicator(
        onRefresh: controller.fetchOrders,
        child: ListView.separated(
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: controller.orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final order = controller.orders[index];
            return _OrderCard(order: order);
          },
        ),
      );
    });
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final styleData = OrderController.statusStyle(order.status);
    final statusColor = Color(styleData['color'] as int);
    final statusText = styleData['label'] as String;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- En-tête : statut + date + flèche
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Iconsax.ship, color: statusColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.formattedOrderDate,
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                // Montant total
                Text(
                  '${order.totalAmount.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: () => Get.to(() => OrderTrackingScreen(order: order)),
                  icon: Icon(
                    Iconsax.arrow_right_3,
                    size: 18,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child:
                  Divider(height: 1, thickness: 0.5, color: Color(0xFFEEEEEE)),
            ),

            // --- Détails : Numéro de commande + nombre d'articles
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    context,
                    'Numéro de commande',
                    '#${order.id.length > 8 ? order.id.substring(0, 8).toUpperCase() : order.id.toUpperCase()}',
                    Iconsax.tag,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    context,
                    'Articles',
                    "${order.items.length} article${order.items.length > 1 ? 's' : ''}",
                    Iconsax.shopping_bag,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
      BuildContext context, String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[400]),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[500], fontSize: 10),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        )
      ],
    );
  }
}
