import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/features/personalization/screens/modelcustom/widgets/customization_layout.dart';
import 'package:osho/features/shop/screens/checkout/checkout.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/sizes.dart';
import 'package:osho/features/shop/controllers/customization_controller.dart';
import 'package:osho/utils/helpers/logistics_calculator.dart';

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
      nextButtonText: 'Passer à la commande',
      onNext: () {
        Get.to(() => const CheckoutScreen());
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Obx(() {
          final days = controller.estimatedDays.value;

          final top = controller.standardTopSize.value;
          final bottom = controller.standardBottomSize.value;
          final sizeLabel = (top.isNotEmpty && bottom.isNotEmpty)
              ? '$top / $bottom'
              : 'Sur Mesure';

          return Column(
            children: [
              const SizedBox(height: OSizes.spaceBtwSections / 1.5),

              // ── Product header ──────────────────────────────────────────
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: OColors.primary.withValues(alpha: 0.07),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Iconsax.scissor,
                        color: OColors.primary, size: 28),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    controller.productName.value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: Color(0xFF1A1A1A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _subtitleText(controller.categoryType.value,
                        controller.fabricName),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFB0AAA2),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Attributes list ─────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _attrRow('Matière', controller.fabricName, Iconsax.shapes),
                    _line(),
                    _attrRow(
                      'Broderie',
                      controller.hasBroderie.value &&
                              controller.step2Options.isNotEmpty
                          ? controller.getStep2Name()
                          : 'Aucun',
                      Iconsax.magicpen,
                    ),
                    _line(),
                    _attrRow(
                      'Accessoire',
                      controller.hasFinition.value &&
                              controller.step3Options.isNotEmpty
                          ? controller.getStep3Name()
                          : 'Aucun',
                      Iconsax.add_circle,
                    ),
                    _line(),
                    _attrRow('Taille', sizeLabel, Iconsax.frame_1),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Price block ─────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      OColors.primary.withValues(alpha: 0.10),
                      OColors.primary.withValues(alpha: 0.04),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: OColors.primary.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'PRIX TOTAL',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: Color(0xFFB0AAA2),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Livraison non incluse',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFFB0AAA2),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      OLogisticsCalculator.formatFee(
                          controller.basePrice.value),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: OColors.primary,
                        letterSpacing: -0.8,
                      ),
                    ),
                  ],
                ),
              ),

              if (days > 0) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer_outlined,
                          size: 13, color: Colors.green[700]),
                      const SizedBox(width: 6),
                      Text(
                        'Confection : $days–${days + 3} jours ouvrables',
                        style: const TextStyle(
                          color: Color(0xFF388E3C),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 10),

              TextButton(
                onPressed: () {
                  Get.snackbar(
                    'Succès',
                    'Création enregistrée dans vos designs',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.white,
                    colorText: Colors.black,
                  );
                },
                child: Text(
                  'Enregistrer pour plus tard',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),

              const SizedBox(height: OSizes.spaceBtwSections),
            ],
          );
        }),
      ),
    );
  }

  String _subtitleText(String categoryType, String fabric) {
    final String category;
    final type = categoryType.toLowerCase();
    if (type == 'homme') {
      category = 'Tenue Homme';
    } else if (type == 'couple') {
      category = 'Tenue Couple';
    } else {
      category = 'Tenue Femme';
    }
    return fabric.isNotEmpty ? '$fabric · $category' : category;
  }

  Widget _attrRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      child: Row(
        children: [
          Icon(icon, size: 15, color: const Color(0xFFB0AAA2)),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF8A8480),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _line() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 18),
      color: const Color(0xFFF4F1EC),
    );
  }
}
