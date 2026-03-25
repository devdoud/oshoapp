import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/features/personalization/screens/modelcustom/custommodelstep1.dart';
import 'package:osho/features/personalization/screens/modelcustom/widgets/customization_layout.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/sizes.dart';

import 'package:osho/features/shop/controllers/customization_controller.dart';

class CustomGenderStep extends StatefulWidget {
  const CustomGenderStep({super.key});

  @override
  State<CustomGenderStep> createState() => _CustomGenderStepState();
}

class _CustomGenderStepState extends State<CustomGenderStep> {
  final controller = Get.put(CustomizationController());

  @override
  Widget build(BuildContext context) {
    return CustomizationLayout(
        title: "Pour qui ?",
        subTitle: "Étape 1 : Choisissez le genre pour les mesures",
        step: 1,
        totalSteps: 5,
        isNextEnabled: true,
        onNext: () {
          Get.to(() =>
              CustomModelStep1(categoryType: controller.categoryType.value));
        },
        child: Column(
          children: [
            const SizedBox(height: OSizes.spaceBtwSections),
            Text(
              "Cette tenue est destinée à une...",
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: OSizes.spaceBtwSections * 1.5),
            Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildGenderCard('femme', Iconsax.woman),
                    const SizedBox(width: 24),
                    _buildGenderCard('homme', Iconsax.man),
                  ],
                )),
            const SizedBox(height: 32),
            Obx(() => Column(
                  children: [
                    if (controller.categoryType.value == 'femme')
                      _buildInfoMessage(
                          "Nous adapterons les mesures pour une coupe féminine élégante."),
                    if (controller.categoryType.value == 'homme')
                      _buildInfoMessage(
                          "Les mesures seront ajustées pour une coupe masculine sahélienne."),
                  ],
                )),
          ],
        ));
  }

  Widget _buildGenderCard(String categoryType, IconData icon) {
    final isSelected = controller.categoryType.value == categoryType;

    return GestureDetector(
      onTap: () => controller.categoryType.value = categoryType,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 140,
        height: 180,
        decoration: BoxDecoration(
            color: isSelected ? OColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: isSelected ? OColors.primary : Colors.grey.shade200,
                width: 2),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: OColors.primary.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10))
                  ]
                : [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5))
                  ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : Colors.grey.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  size: 40, color: isSelected ? Colors.white : Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              categoryType,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black87),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoMessage(String msg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: OColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Iconsax.info_circle, size: 20, color: OColors.primary),
          const SizedBox(width: 12),
          Expanded(
              child: Text(msg,
                  style: const TextStyle(
                      color: OColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)))
        ],
      ),
    );
  }
}
