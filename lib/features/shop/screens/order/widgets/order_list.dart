import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/features/shop/controllers/order_controller.dart';
import 'package:osho/features/shop/models/order_model.dart';
import 'package:osho/features/shop/screens/orders/order_tracking.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/helpers/helper_functions.dart';
import 'package:osho/utils/helpers/logistics_calculator.dart';

class OOrderListItems extends StatelessWidget {
  const OOrderListItems({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = OHelperFunctions.isDarkMode(context);
    final controller = Get.put(OrderController());

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 80),
            child: CircularProgressIndicator(color: OColors.primary, strokeWidth: 2),
          ),
        );
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return _buildError(controller, isDark);
      }

      if (controller.orders.isEmpty) {
        return _buildEmpty(isDark);
      }

      return RefreshIndicator(
        onRefresh: controller.fetchOrders,
        color: OColors.primary,
        child: ListView.separated(
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: controller.orders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) =>
              _OrderCard(order: controller.orders[index]),
        ),
      );
    });
  }

  Widget _buildError(OrderController controller, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
              child: Icon(Iconsax.warning_2, size: 40,
                  color: Colors.red.withValues(alpha: 0.70)),
            ),
            const SizedBox(height: 18),
            Text('generic_error'.tr,
              style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: controller.fetchOrders,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, size: 15,
                        color: isDark ? const Color(0xFF1A1A1A) : Colors.white),
                    const SizedBox(width: 6),
                    Text('retry'.tr,
                      style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: OColors.primary.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.shopping_bag, size: 44,
                  color: OColors.primary),
            ),
            const SizedBox(height: 22),
            Text('no_orders'.tr,
              style: TextStyle(
                fontSize: 17, fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text('no_orders_sub'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13, height: 1.55,
                color: isDark ? Colors.white54 : const Color(0xFF888480),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Order Card ───────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final OrderModel order;

  static const _steps = ['pending', 'processing', 'shipped', 'delivered'];

  int get _stepIndex {
    final i = _steps.indexOf(order.status);
    return i < 0 ? 0 : i;
  }

  static List<String> get _stepLabels => [
        'step_received'.tr,
        'step_in_progress'.tr,
        'step_shipped'.tr,
        'step_delivered'.tr,
      ];
  static const _stepIcons = [
    Iconsax.receipt_1,
    Iconsax.scissor,
    Iconsax.truck,
    Iconsax.tick_circle,
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = OHelperFunctions.isDarkMode(context);
    final step = _stepIndex;
    final styleData = OrderController.statusStyle(order.status);
    final statusColor = Color(styleData['color'] as int);
    final shortId = order.id.length > 8
        ? order.id.substring(0, 8).toUpperCase()
        : order.id.toUpperCase();

    // Image tissu du premier article si disponible
    String? thumbnail;
    if (order.items.isNotEmpty) {
      final img = order.items.first.customizationDetails?['tissu_image'];
      if (img is String && img.isNotEmpty) thumbnail = img;
    }

    return GestureDetector(
      onTap: () => Get.to(() => OrderTrackingScreen(order: order)),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : const Color(0xFFEEEBE6),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── En-tête ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail ou icône
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: thumbnail != null
                        ? Image.network(
                            thumbnail,
                            width: 56, height: 56, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _fallbackIcon(isDark, statusColor),
                          )
                        : _fallbackIcon(isDark, statusColor),
                  ),
                  const SizedBox(width: 12),
                  // Infos
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _statusBadge(styleData['label'] as String, statusColor),
                            const Spacer(),
                            Text(
                              OLogisticsCalculator.formatFeeLocalized(
                                  order.totalAmount),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1A1A1A),
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'order_items_count'
                              .trParams({'count': '${order.items.length}'}),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Iconsax.tag, size: 11,
                                color: isDark
                                    ? Colors.white38
                                    : const Color(0xFFB0AAA2)),
                            const SizedBox(width: 4),
                            Text(
                              '#$shortId',
                              style: TextStyle(
                                fontSize: 11,
                                fontFamily: 'monospace',
                                color: isDark
                                    ? Colors.white38
                                    : const Color(0xFFB0AAA2),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(Iconsax.calendar_1, size: 11,
                                color: isDark
                                    ? Colors.white38
                                    : const Color(0xFFB0AAA2)),
                            const SizedBox(width: 4),
                            Text(
                              order.formattedOrderDate,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? Colors.white38
                                    : const Color(0xFFB0AAA2),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Séparateur ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(
                height: 1, thickness: 0.5,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : const Color(0xFFF0EDE8),
              ),
            ),

            // ── Timeline statut ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Row(
                children: List.generate(_steps.length, (i) {
                  final isActive = i == step;
                  final isDone = i < step;
                  final isLast = i == _steps.length - 1;
                  final nodeColor = isDone || isActive ? statusColor : Colors.transparent;
                  final lineColor = isDone
                      ? statusColor.withValues(alpha: 0.5)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : const Color(0xFFEEEBE6));

                  return Expanded(
                    child: Row(
                      children: [
                        // Nœud
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: isActive ? 30 : 24,
                              height: isActive ? 30 : 24,
                              decoration: BoxDecoration(
                                color: isDone
                                    ? statusColor.withValues(alpha: 0.15)
                                    : isActive
                                        ? statusColor.withValues(alpha: 0.12)
                                        : (isDark
                                            ? Colors.white.withValues(alpha: 0.05)
                                            : const Color(0xFFF4F1EC)),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDone || isActive
                                      ? nodeColor
                                      : (isDark
                                          ? Colors.white.withValues(alpha: 0.10)
                                          : const Color(0xFFE4E0DA)),
                                  width: isActive ? 2 : 1.5,
                                ),
                              ),
                              child: Icon(
                                isDone ? Icons.check_rounded : _stepIcons[i],
                                size: isActive ? 14 : 12,
                                color: isDone || isActive
                                    ? statusColor
                                    : (isDark
                                        ? Colors.white24
                                        : const Color(0xFFCCC8C4)),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _stepLabels[i],
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: isActive
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isDone || isActive
                                    ? statusColor
                                    : (isDark
                                        ? Colors.white24
                                        : const Color(0xFFCCC8C4)),
                              ),
                            ),
                          ],
                        ),
                        // Ligne (pas après le dernier)
                        if (!isLast)
                          Expanded(
                            child: Container(
                              height: 1.5,
                              margin: const EdgeInsets.only(bottom: 18),
                              decoration: BoxDecoration(
                                color: lineColor,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _fallbackIcon(bool isDark, Color color) {
    return Container(
      width: 56, height: 56,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Iconsax.shopping_bag, size: 24, color: color),
    );
  }
}
