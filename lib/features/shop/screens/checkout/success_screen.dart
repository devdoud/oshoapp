import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/features/shop/models/order_model.dart';
import 'package:osho/features/shop/screens/orders/order_tracking.dart';
import 'package:osho/navigation_menu.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/sizes.dart';
class OrderSuccessScreen extends StatelessWidget {
  final OrderModel order;

  const OrderSuccessScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(OSizes.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success Icon Animation (Scale)
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.elasticOut,
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Iconsax.tick_circle,
                          size: 70, color: Colors.green),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Text('order_success'.tr,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            const Text(
              "Merci pour votre confiance.\nVotre maître tailleur a bien reçu votre création unique et commence la préparation.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey,
                  height: 1.6,
                  fontSize: 15,
                  fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 48),

            // Track Order Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.offAll(() => OrderTrackingScreen(order: order));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: OColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: Text('track_order'.tr,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Get.offAll(() => const NavigationMenu()),
              child: Text("Retour à l'accueil",
                  style: TextStyle(color: Colors.grey[600])),
            )
          ],
        ),
      ),
    );
  }
}
