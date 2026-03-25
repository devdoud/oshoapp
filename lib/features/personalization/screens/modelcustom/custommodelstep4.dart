import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/features/personalization/screens/modelcustom/widgets/customization_layout.dart';
import 'package:osho/features/shop/screens/checkout/checkout.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/sizes.dart';
import 'package:osho/features/shop/controllers/customization_controller.dart';

class CustomModelStep4 extends StatelessWidget {
  final String categoryType;
  const CustomModelStep4({super.key, this.categoryType = 'femme'});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CustomizationController());

    return CustomizationLayout(
      title: 'Récapitulatif',
      subTitle: 'Étape 4 : Validation finale',
      step: 4,
      totalSteps: 4,
      nextButtonText:
          'Passer à la commande (${controller.basePrice.value.toStringAsFixed(0)} F)',
      onNext: () {
        // Direct to Checkout for "Buy Now" flow
        Get.to(() => const CheckoutScreen());
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: OSizes.spaceBtwSections / 1.5),

            // --- Receipt Card ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 30,
                        offset: const Offset(0, 12))
                  ]),
              child: Obx(() => Column(
                    children: [
                      // Icon Header
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: OColors.primary.withValues(alpha: 0.03),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Iconsax.receipt_21,
                            color: OColors.primary, size: 36),
                      ),
                      const SizedBox(height: 16),
                      Text(controller.productName.value,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5)),
                      Text(
                          controller.categoryType.value == 'homme'
                              ? "Coupe Homme Personnalisée"
                              : "Coupe Femme Personnalisée",
                          style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),

                      const SizedBox(height: 32),
                      _buildDivider(),
                      const SizedBox(height: 24),

                      _buildRow("MATIÈRE", controller.fabricName),
                      _buildRow(
                          controller.categoryType.value == 'homme'
                              ? "STYLE BRODERIE"
                              : "DÉTAIL COUPE",
                          controller.getStep2Name()),
                      _buildRow(
                          controller.categoryType.value == 'homme'
                              ? "FINITION"
                              : "ACCESSOIRE",
                          controller.getStep3Name()),
                      _buildRow("TAILLE", "Préférence Standard (M)"),

                      const SizedBox(height: 32),
                      _buildDivider(),
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("PRIX TOTAL",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.grey[400],
                                  letterSpacing: 1)),
                          Text(
                              "${controller.basePrice.value.toStringAsFixed(0)} FCFA",
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: OColors.primary)),
                        ],
                      )
                    ],
                  )),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(100)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer_outlined,
                      size: 14, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  const Text(
                    "Livraison estimée : 5-7 jours ouvrables",
                    style: TextStyle(
                        color: Color(0xFF388E3C),
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // Logic to save draft and go back or to cart
                Get.snackbar("Succès", "Création enregistrée dans vos designs",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.white,
                    colorText: Colors.black);
              },
              child: Text("Enregistrer pour plus tard",
                  style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                      fontSize: 14)),
            ),
            const SizedBox(height: OSizes.spaceBtwSections),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: List.generate(
          30,
          (index) => Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: 1,
                  color: index % 2 == 0 ? Colors.grey[200] : Colors.transparent,
                ),
              )),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Colors.black87)),
        ],
      ),
    );
  }
}
