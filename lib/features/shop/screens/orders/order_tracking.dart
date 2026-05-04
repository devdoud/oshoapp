import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:osho/common/widgets/appbar/appbar.dart';
import 'package:osho/features/shop/controllers/order_controller.dart';
import 'package:osho/features/shop/models/order_model.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/sizes.dart';

class OrderTrackingScreen extends StatelessWidget {
  final OrderModel order;

  const OrderTrackingScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrderController());

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: OAppBar(title: Text('track_order'.tr), showBackArrow: true),
      body: Obx(() {
        final currentOrder = controller.orders.firstWhere(
          (o) => o.id == order.id,
          orElse: () => order,
        );

        final shortId = currentOrder.id.length > 8
            ? currentOrder.id.substring(0, 8).toUpperCase()
            : currentOrder.id.toUpperCase();

        final deliveryDate = currentOrder.deliveryDate ??
            currentOrder.orderDate.add(const Duration(days: 7));
        final formattedDelivery =
            DateFormat('dd MMM yyyy', 'fr_FR').format(deliveryDate);

        final status = currentOrder.status.toLowerCase();
        final isDeliveredStatus = status == 'delivered';

        final isConfirmedCompleted = status == 'processing' ||
            status == 'shipped' ||
            status == 'delivered' ||
            status == 'accepted';
        final isConfirmedActive = status == 'pending';

        final isProcessingCompleted =
            status == 'shipped' || status == 'delivered';
        final isProcessingActive =
            status == 'processing' || status == 'accepted';

        final isShippingCompleted = status == 'delivered';
        final isShippingActive = status == 'shipped';

        final isDeliveredCompleted = currentOrder.customerConfirmed;
        final isDeliveredActive =
            isDeliveredStatus && !currentOrder.customerConfirmed;

        final isConfirming =
            controller.activeOrderActionId.value == currentOrder.id;
        final isSubmittingReview =
            controller.activeReviewOrderId.value == currentOrder.id;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(OSizes.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        child: const Icon(
                          Iconsax.box,
                          color: OColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Commande #$shortId',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Livraison estimee : $formattedDelivery',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Iconsax.arrow_right_3,
                        color: Colors.grey,
                        size: 18,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    'Statut de la commande',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                  ),
                ),
                const SizedBox(height: 28),
                _buildTimelineStep(
                  context,
                  'order_status_confirmed'.tr,
                  'tracking_confirmed_sub'.tr,
                  isConfirmedCompleted,
                  isConfirmedActive,
                ),
                _buildTimelineStep(
                  context,
                  'order_status_processing'.tr,
                  'tracking_processing_sub'.tr,
                  isProcessingCompleted,
                  isProcessingActive,
                ),
                _buildTimelineStep(
                  context,
                  'order_status_shipping'.tr,
                  'tracking_shipping_sub'.tr,
                  isShippingCompleted,
                  isShippingActive,
                ),
                _buildTimelineStep(
                  context,
                  'order_status_delivered'.tr,
                  currentOrder.customerConfirmed
                      ? 'Reception confirmee par vos soins.'
                      : 'Confirmez ici lorsque la commande vous a bien ete remise.',
                  isDeliveredCompleted,
                  isDeliveredActive,
                  isLast: true,
                ),
                const SizedBox(height: 12),
                if (isDeliveredStatus)
                  _buildCustomerActionCard(
                    context,
                    controller,
                    currentOrder,
                    isConfirming: isConfirming,
                    isSubmittingReview: isSubmittingReview,
                  ),
                const SizedBox(height: 32),
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
                                child: const Icon(
                                  Iconsax.map,
                                  size: 44,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Suivi cartographique',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Bientot disponible pour votre region',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
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

  Widget _buildCustomerActionCard(
    BuildContext context,
    OrderController controller,
    OrderModel order, {
    required bool isConfirming,
    required bool isSubmittingReview,
  }) {
    if (!order.customerConfirmed) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Avez-vous bien recu votre commande ?',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Confirmez la reception pour cloturer le suivi et pouvoir noter le travail du tailleur.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isConfirming
                    ? null
                    : () async {
                        final confirmed =
                            await controller.confirmOrderReceived(order);
                        if (confirmed &&
                            order.primaryTailorId != null &&
                            order.tailorReview == null &&
                            context.mounted) {
                          await _showReviewSheet(
                            context,
                            controller,
                            order,
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: OColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: isConfirming
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Confirmer la reception',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      );
    }

    if (order.tailorReview == null && order.primaryTailorId != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Votre avis compte',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Notez la qualite du travail du tailleur pour nous aider a mieux recommander les meilleurs profils.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: isSubmittingReview
                    ? null
                    : () => _showReviewSheet(context, controller, order),
                style: OutlinedButton.styleFrom(
                  foregroundColor: OColors.primary,
                  side: const BorderSide(color: OColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: isSubmittingReview
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: OColors.primary,
                        ),
                      )
                    : const Text(
                        'Noter le tailleur',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      );
    }

    final review = order.tailorReview!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Merci pour votre retour',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            children: List.generate(
              5,
              (index) => Icon(
                index < review.rating ? Icons.star : Icons.star_border,
                color: const Color(0xFFFFB300),
                size: 22,
              ),
            ),
          ),
          if (review.reviewText != null && review.reviewText!.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                review.reviewText!,
                style: TextStyle(
                  color: Colors.grey[700],
                  height: 1.45,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showReviewSheet(
    BuildContext context,
    OrderController controller,
    OrderModel order,
  ) async {
    int rating = 5;
    final reviewController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                top: 24,
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Notez le travail du tailleur',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Une note simple nous aide a mieux suivre la qualite des prestations.',
                      style: TextStyle(
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        5,
                        (index) => IconButton(
                          onPressed: () => setState(() => rating = index + 1),
                          icon: Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: const Color(0xFFFFB300),
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: reviewController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Commentaire optionnel',
                        hintText:
                            'Ex: finition propre, bonne communication, delai respecte...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              controller.activeReviewOrderId.value == order.id
                                  ? null
                                  : () async {
                                      final success =
                                          await controller.submitTailorReview(
                                        order: order,
                                        rating: rating,
                                        reviewText: reviewController.text,
                                      );

                                      if (success && context.mounted) {
                                        Navigator.of(context).pop();
                                      }
                                    },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: OColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: controller.activeReviewOrderId.value == order.id
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Envoyer mon avis',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    reviewController.dispose();
  }

  Widget _buildTimelineStep(
    BuildContext context,
    String title,
    String subtitle,
    bool isCompleted,
    bool isActive, {
    bool isLast = false,
  }) {
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
                  color:
                      isCompleted ? Colors.green : (isActive ? Colors.white : Colors.white),
                  border: isCompleted
                      ? null
                      : Border.all(
                          color: isActive ? OColors.primary : Colors.grey[300]!,
                          width: isActive ? 6 : 2,
                        ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: OColors.primary.withValues(alpha: 0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ]
                      : null,
                ),
                child: isCompleted
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
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
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    color: (isCompleted || isActive)
                        ? Colors.black
                        : Colors.grey[400],
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: (isCompleted || isActive)
                        ? Colors.grey[600]
                        : Colors.grey[400],
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          )
        ],
      ),
    );
  }
}
