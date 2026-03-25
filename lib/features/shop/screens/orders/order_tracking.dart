import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/common/widgets/appbar/appbar.dart';
import 'package:osho/features/shop/controllers/order_controller.dart';
import 'package:osho/features/shop/models/order_model.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/sizes.dart';
import 'package:intl/intl.dart';

class OrderTrackingScreen extends StatelessWidget {
  final OrderModel order;

  const OrderTrackingScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // Initialisation du contrôleur en dehors du build réactif
    final controller = Get.put(OrderController());

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: OAppBar(title: Text('track_order'.tr), showBackArrow: true),
      body: Obx(() {
        // Obtenir l'ordre mis à jour depuis le contrôleur s'il a changé (pour le temps réel)
        final currentOrder = controller.orders.firstWhere(
          (o) => o.id == order.id,
          orElse: () => order,
        );

        final shortId = currentOrder.id.length > 8
            ? currentOrder.id.substring(0, 8).toUpperCase()
            : currentOrder.id.toUpperCase();

        final deliveryDate = currentOrder.deliveryDate ??
            currentOrder.orderDate.add(const Duration(days: 7));
        
        // Formatage sécurisé de la date
        final formattedDelivery =
            DateFormat('dd MMM yyyy', 'fr_FR').format(deliveryDate);

        // Déterminer les états de la timeline
        final status = currentOrder.status.toLowerCase();
        
        bool isConfirmedCompleted = status == 'processing' || status == 'shipped' || status == 'delivered' || status == 'accepted';
        bool isConfirmedActive = status == 'pending';

        bool isProcessingCompleted = status == 'shipped' || status == 'delivered';
        bool isProcessingActive = status == 'processing' || status == 'accepted';

        bool isShippingCompleted = status == 'delivered';
        bool isShippingActive = status == 'shipped';

        bool isDeliveredCompleted = status == 'delivered';
        bool isDeliveredActive = false; 

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(OSizes.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Info Card
                Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: OColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Iconsax.box,
                          color: OColors.primary, size: 28),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Commande #$shortId",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  letterSpacing: -0.5)),
                          const SizedBox(height: 4),
                          Text("Livraison estimée : $formattedDelivery",
                              style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    const Icon(Iconsax.arrow_right_3,
                        color: Colors.grey, size: 18),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text("Statut de la commande",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w900, fontSize: 20)),
              ),
              const SizedBox(height: 28),

              // Timeline
              _buildTimelineStep(context, 'order_status_confirmed'.tr,
                  'tracking_confirmed_sub'.tr, isConfirmedCompleted, isConfirmedActive),
              _buildTimelineStep(context, 'order_status_processing'.tr,
                  'tracking_processing_sub'.tr, isProcessingCompleted, isProcessingActive),
              _buildTimelineStep(context, 'order_status_shipping'.tr,
                  'tracking_shipping_sub'.tr, isShippingCompleted, isShippingActive),
              _buildTimelineStep(context, 'order_status_delivered'.tr,
                  'tracking_delivered_sub'.tr, isDeliveredCompleted, isDeliveredActive,
                  isLast: true),

              const SizedBox(height: 32),

              // Map Placeholder
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(color: const Color(0xFFF9FBF9)),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.05),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Iconsax.map,
                                  size: 44, color: Colors.green),
                            ),
                            const SizedBox(height: 16),
                            const Text("Suivi cartographique",
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: Colors.black87)),
                            const SizedBox(height: 4),
                            Text("Bientôt disponible pour votre région",
                                style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      );
      }),
    );
  }

  Widget _buildTimelineStep(BuildContext context, String title, String subtitle,
      bool isCompleted, bool isActive,
      {bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ?
                      Colors.green
                      : (isActive ? Colors.white : Colors.white),
                  border: isCompleted ?
                      null
                      : Border.all(
                          color: isActive ? OColors.primary : Colors.grey[300]!,
                          width: isActive ? 6 : 2,
                        ),
                  boxShadow: isActive ?
                      [
                          BoxShadow(
                              color: OColors.primary.withValues(alpha: 0.3),
                              blurRadius: 10,
                              spreadRadius: 2)
                        ]
                      : null,
                ),
                child: isCompleted ?
                    const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.5,
                    color: isCompleted ? Colors.green : Colors.grey[200],
                  ),
                ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                        color: (isCompleted || isActive) ?
                            Colors.black
                            : Colors.grey[400],
                        letterSpacing: -0.2)),
                const SizedBox(height: 6),
                Text(subtitle,
                    style: TextStyle(
                        color: (isCompleted || isActive) ?
                            Colors.grey[600]
                            : Colors.grey[400],
                        fontSize: 14,
                        height: 1.4,
                        fontWeight: FontWeight.w400)),
                const SizedBox(height: 40),
              ],
            ),
          )
        ],
      ),
    );
  }
}
