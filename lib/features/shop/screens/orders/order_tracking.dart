import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:osho/features/shop/controllers/order_controller.dart';
import 'package:osho/features/shop/models/order_model.dart';
import 'package:osho/navigation_menu.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/helpers/helper_functions.dart';
import 'package:osho/utils/helpers/logistics_calculator.dart';

class OrderTrackingScreen extends StatelessWidget {
  final OrderModel order;

  const OrderTrackingScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final isDark = OHelperFunctions.isDarkMode(context);
    final controller = Get.put(OrderController());

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light
              .copyWith(statusBarColor: Colors.transparent)
          : SystemUiOverlayStyle.dark
              .copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF111111) : const Color(0xFFF8F6F3),
        body: Obx(() {
          final current = controller.orders.firstWhere(
            (o) => o.id == order.id,
            orElse: () => order,
          );

          final status = current.status.toLowerCase();
          final isConfirmedDone = status == 'processing' ||
              status == 'accepted' ||
              status == 'shipped' ||
              status == 'delivered';
          final isConfirmedActive = status == 'pending';
          final isProcessingDone =
              status == 'shipped' || status == 'delivered';
          final isProcessingActive =
              status == 'processing' || status == 'accepted';
          final isShippedDone = status == 'delivered';
          final isShippedActive = status == 'shipped';
          final isDeliveredDone = current.customerConfirmed;
          final isDeliveredActive =
              status == 'delivered' && !current.customerConfirmed;
          final isConfirming =
              controller.activeOrderActionId.value == current.id;
          final isSubmittingReview =
              controller.activeReviewOrderId.value == current.id;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── AppBar ──────────────────────────────────────────────────
              SliverAppBar(
                pinned: true,
                backgroundColor: isDark
                    ? const Color(0xFF111111)
                    : const Color(0xFFF8F6F3),
                elevation: 0,
                scrolledUnderElevation: 0,
                systemOverlayStyle: isDark
                    ? SystemUiOverlayStyle.light
                        .copyWith(statusBarColor: Colors.transparent)
                    : SystemUiOverlayStyle.dark
                        .copyWith(statusBarColor: Colors.transparent),
                leadingWidth: 64,
                leading: GestureDetector(
                  onTap: () {
                    if (Navigator.of(context).canPop()) {
                      Get.back();
                    } else {
                      Get.offAll(() => const NavigationMenu());
                    }
                  },
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.only(left: 16),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF2A2A2A)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(11),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 14,
                        color: isDark
                            ? Colors.white
                            : const Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                ),
                centerTitle: true,
                title: Text(
                  'Suivi de commande',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    letterSpacing: -0.3,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header card ─────────────────────────────────────
                      _buildHeaderCard(current, isDark),
                      const SizedBox(height: 24),

                      // ── Timeline title ──────────────────────────────────
                      Text(
                        'Statut de la commande',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          letterSpacing: -0.2,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // ── Timeline ────────────────────────────────────────
                      _TimelineStep(
                        isDark: isDark,
                        icon: Iconsax.receipt_item,
                        title: 'order_status_confirmed'.tr,
                        subtitle: 'tracking_confirmed_sub'.tr,
                        isDone: isConfirmedDone,
                        isActive: isConfirmedActive,
                        isLast: false,
                      ),
                      _TimelineStep(
                        isDark: isDark,
                        icon: Iconsax.activity,
                        title: 'order_status_processing'.tr,
                        subtitle: 'tracking_processing_sub'.tr,
                        isDone: isProcessingDone,
                        isActive: isProcessingActive,
                        isLast: false,
                      ),
                      _TimelineStep(
                        isDark: isDark,
                        icon: Iconsax.truck,
                        title: 'order_status_shipping'.tr,
                        subtitle: 'tracking_shipping_sub'.tr,
                        isDone: isShippedDone,
                        isActive: isShippedActive,
                        isLast: false,
                      ),
                      _TimelineStep(
                        isDark: isDark,
                        icon: Iconsax.home_2,
                        title: 'order_status_delivered'.tr,
                        subtitle: current.customerConfirmed
                            ? 'Réception confirmée par vos soins.'
                            : 'Confirmez ici lorsque la commande vous a bien été remise.',
                        isDone: isDeliveredDone,
                        isActive: isDeliveredActive,
                        isLast: true,
                      ),

                      const SizedBox(height: 8),

                      // ── Customer action card ────────────────────────────
                      if (status == 'delivered')
                        _buildActionCard(
                          context,
                          isDark,
                          controller,
                          current,
                          isConfirming: isConfirming,
                          isSubmittingReview: isSubmittingReview,
                        ),

                      const SizedBox(height: 20),

                      // ── Map placeholder ─────────────────────────────────
                      _buildMapPlaceholder(isDark),

                      const SizedBox(height: 28),

                      // ── Home button ─────────────────────────────────────
                      GestureDetector(
                        onTap: () =>
                            Get.offAll(() => const NavigationMenu()),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Iconsax.home,
                                size: 15,
                                color: isDark
                                    ? const Color(0xFF1A1A1A)
                                    : Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Retour à l\'accueil',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? const Color(0xFF1A1A1A)
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ── Header card ─────────────────────────────────────────────────────────────

  Widget _buildHeaderCard(OrderModel current, bool isDark) {
    final shortId = current.id.length > 8
        ? current.id.substring(0, 8).toUpperCase()
        : current.id.toUpperCase();
    final deliveryDate = current.deliveryDate ??
        current.orderDate.add(const Duration(days: 7));
    final formattedDelivery =
        DateFormat('d MMM yyyy', 'fr_FR').format(deliveryDate);
    final styleData = OrderController.statusStyle(current.status);
    final statusLabel = styleData['label'] as String;
    final statusColor = Color(styleData['color'] as int);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1C1714), Color(0xFF2A2018)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: Stack(
          children: [
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: OColors.primary.withValues(alpha: 0.10),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: statusColor.withValues(alpha: 0.30)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                  color: statusColor, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              statusLabel,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '#$shortId',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.40),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    OLogisticsCalculator.formatFee(current.totalAmount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.2,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.white.withValues(alpha: 0),
                        Colors.white.withValues(alpha: 0.09),
                        Colors.white.withValues(alpha: 0),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _headerMeta(
                        icon: Iconsax.calendar,
                        label: DateFormat('d MMM yyyy', 'fr_FR')
                            .format(current.orderDate),
                      ),
                      Container(
                        width: 1,
                        height: 16,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        color: Colors.white.withValues(alpha: 0.10),
                      ),
                      _headerMeta(
                        icon: Iconsax.clock,
                        label: 'Livr. est. $formattedDelivery',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerMeta({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(icon, size: 11, color: Colors.white.withValues(alpha: 0.32)),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.45),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ── Map placeholder ──────────────────────────────────────────────────────────

  Widget _buildMapPlaceholder(bool isDark) {
    return Container(
      height: 80,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFEEEBE6),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.map, size: 18, color: Colors.green),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Suivi cartographique',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Bientôt disponible',
                style: TextStyle(
                  color: isDark ? Colors.white38 : const Color(0xFFB0AAA2),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Action card ──────────────────────────────────────────────────────────────

  Widget _buildActionCard(
    BuildContext context,
    bool isDark,
    OrderController controller,
    OrderModel current, {
    required bool isConfirming,
    required bool isSubmittingReview,
  }) {
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final border = isDark
        ? Border.all(color: Colors.white.withValues(alpha: 0.07))
        : Border.all(color: const Color(0xFFEEEBE6));

    if (!current.customerConfirmed) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          border: border,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Iconsax.box_tick,
                      size: 17, color: Colors.green),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Avez-vous bien reçu votre commande ?',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Confirmez la réception pour clôturer le suivi.',
              style: TextStyle(
                color: isDark ? Colors.white54 : const Color(0xFF888480),
                fontSize: 12,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: isConfirming
                  ? null
                  : () async {
                      final confirmed =
                          await controller.confirmOrderReceived(current);
                      if (confirmed &&
                          current.primaryTailorId != null &&
                          current.tailorReview == null &&
                          context.mounted) {
                        await _showReviewSheet(context, controller, current);
                      }
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: isConfirming
                      ? Colors.green.withValues(alpha: 0.5)
                      : Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: isConfirming
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Confirmer la réception',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (current.tailorReview == null && current.primaryTailorId != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          border: border,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB300).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Iconsax.star,
                      size: 17, color: Color(0xFFFFB300)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Votre avis compte',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Notez la qualité du travail du tailleur pour aider la communauté.',
              style: TextStyle(
                color: isDark ? Colors.white54 : const Color(0xFF888480),
                fontSize: 12,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: isSubmittingReview
                  ? null
                  : () => _showReviewSheet(context, controller, current),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2A2A2A)
                      : const Color(0xFFF8F6F3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.10)
                        : const Color(0xFFEEEBE6),
                  ),
                ),
                child: Center(
                  child: isSubmittingReview
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: OColors.primary),
                        )
                      : Text(
                          'Noter le tailleur',
                          style: TextStyle(
                            color: isDark ? Colors.white : OColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final review = current.tailorReview!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: border,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Merci pour votre retour',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(
              5,
              (i) => Padding(
                padding: const EdgeInsets.only(right: 2),
                child: Icon(
                  i < review.rating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: const Color(0xFFFFB300),
                  size: 20,
                ),
              ),
            ),
          ),
          if (review.reviewText != null &&
              review.reviewText!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.reviewText!,
              style: TextStyle(
                color: isDark ? Colors.white60 : const Color(0xFF888480),
                height: 1.45,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Review sheet ─────────────────────────────────────────────────────────────

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
      builder: (sheetCtx) {
        final isDark = OHelperFunctions.isDarkMode(sheetCtx);
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 32,
                        height: 3,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.12)
                              : const Color(0xFFE8E4DE),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Notez le travail du tailleur',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color:
                            isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Une note simple nous aide à mieux suivre la qualité des prestations.',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white54
                            : const Color(0xFF888480),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        5,
                        (i) => GestureDetector(
                          onTap: () => setState(() => rating = i + 1),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 3),
                            child: Icon(
                              i < rating
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: const Color(0xFFFFB300),
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: reviewController,
                      minLines: 3,
                      maxLines: 4,
                      style: TextStyle(
                        color:
                            isDark ? Colors.white : const Color(0xFF1A1A1A),
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Ex : finition propre, délai respecté...',
                        hintStyle: TextStyle(
                          color: isDark
                              ? Colors.white38
                              : const Color(0xFFB0AAA2),
                          fontSize: 12,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF2A2A2A)
                            : const Color(0xFFF8F6F3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Obx(
                      () => GestureDetector(
                        onTap: controller.activeReviewOrderId.value ==
                                order.id
                            ? null
                            : () async {
                                final success =
                                    await controller.submitTailorReview(
                                  order: order,
                                  rating: rating,
                                  reviewText: reviewController.text,
                                );
                                if (success && ctx.mounted) {
                                  Navigator.of(ctx).pop();
                                }
                              },
                        child: Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: OColors.primary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child:
                                controller.activeReviewOrderId.value ==
                                        order.id
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Envoyer mon avis',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
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
}

// ── Timeline step ─────────────────────────────────────────────────────────────

class _TimelineStep extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDone;
  final bool isActive;
  final bool isLast;

  const _TimelineStep({
    required this.isDark,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDone,
    required this.isActive,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final Color nodeColor;
    final Color lineColor;
    final Color titleColor;
    final Color subtitleColor;

    if (isDone) {
      nodeColor = const Color(0xFF34C759);
      lineColor = const Color(0xFF34C759).withValues(alpha: 0.35);
      titleColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
      subtitleColor = isDark ? Colors.white54 : const Color(0xFF888480);
    } else if (isActive) {
      nodeColor = OColors.primary;
      lineColor = isDark
          ? Colors.white.withValues(alpha: 0.10)
          : const Color(0xFFE8E4DE);
      titleColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
      subtitleColor = isDark ? Colors.white54 : const Color(0xFF888480);
    } else {
      nodeColor = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0EDEA);
      lineColor = isDark
          ? Colors.white.withValues(alpha: 0.07)
          : const Color(0xFFEEEBE6);
      titleColor = isDark ? Colors.white38 : const Color(0xFFB0AAA2);
      subtitleColor = isDark ? Colors.white24 : const Color(0xFFCCC8C4);
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Node + line
          SizedBox(
            width: 36,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDone
                        ? nodeColor
                        : nodeColor.withValues(
                            alpha: isActive ? 0.10 : 0.30),
                    shape: BoxShape.circle,
                    border: isActive
                        ? Border.all(color: nodeColor, width: 1.5)
                        : null,
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: nodeColor.withValues(alpha: 0.20),
                              blurRadius: 10,
                              spreadRadius: 1,
                            )
                          ]
                        : null,
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(Icons.check_rounded,
                            size: 16, color: Colors.white)
                        : Icon(
                            icon,
                            size: 16,
                            color: isActive
                                ? nodeColor
                                : (isDark
                                    ? Colors.white38
                                    : const Color(0xFFB0AAA2)),
                          ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      decoration: BoxDecoration(
                        color: lineColor,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: titleColor,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
