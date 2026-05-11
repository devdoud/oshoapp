import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/features/personalization/screens/modelcustom/custommodelstep4.dart';
import 'package:osho/features/personalization/screens/modelcustom/widgets/customization_layout.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/sizes.dart';
import 'package:osho/features/shop/controllers/customization_controller.dart';

class CustomModelStep3 extends StatefulWidget {
  final String categoryType;
  const CustomModelStep3({super.key, this.categoryType = 'femme'});

  @override
  State<CustomModelStep3> createState() => _CustomModelStep3State();
}

class _CustomModelStep3State extends State<CustomModelStep3> {
  final controller = Get.put(CustomizationController());

  bool get isNextEnabled => controller.selectedStep3Option.value >= 0;

  @override
  Widget build(BuildContext context) {
    final isMale = widget.categoryType == 'homme';

    return Obx(() => CustomizationLayout(
          title: isMale ? 'Finition' : 'Accessoire',
          subTitle: isMale
              ? 'Étape 3 · Choisissez la finition'
              : "Étape 3 · Choisissez l'accessoire",
          step: 3,
          totalSteps: 4,
          isNextEnabled: isNextEnabled,
          onNext: () {
            Get.to(
                () => CustomModelStep4(categoryType: widget.categoryType));
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: OSizes.spaceBtwItems),

                if (controller.isLoading.value)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (controller.step3Options.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        'Aucune option disponible.',
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey[400]),
                      ),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: controller.step3Options.length + 1,
                    itemBuilder: (context, index) {
                      if (index == controller.step3Options.length) {
                        return _buildCustomCard();
                      }
                      return _buildOptionCard(
                          controller.step3Options[index], index);
                    },
                  ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ));
  }

  // ── Option card ─────────────────────────────────────────────────────────────

  Widget _buildOptionCard(Map<String, dynamic> option, int index) {
    final imageUrl = controller.getOptionImage(option);
    final name = controller.getName(option);

    return Obx(() {
      final isSelected = controller.selectedStep3Option.value == index;
      return GestureDetector(
        onTap: () => controller.selectedStep3Option.value = index,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? OColors.primary
                            : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                          isSelected ? 9.5 : 12),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _placeholder(),
                            )
                          : _placeholder(),
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: OColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check,
                            size: 11, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Text(
              name,
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? OColors.primary
                    : const Color(0xFF6B6560),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    });
  }

  // ── Custom "Autre" card ─────────────────────────────────────────────────────

  Widget _buildCustomCard() {
    return Obx(() {
      final isSelected = controller.selectedStep3Option.value == 999;
      final hasImage = controller.customImageStep3.value != null;
      return GestureDetector(
        onTap: () => controller.pickCustomImage(3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: isSelected
                      ? OColors.primary.withValues(alpha: 0.07)
                      : const Color(0xFFF4F1EC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? OColors.primary
                        : const Color(0xFFE4E0DA),
                    width: isSelected ? 2.5 : 1,
                  ),
                ),
                child: hasImage
                    ? ClipRRect(
                        borderRadius:
                            BorderRadius.circular(isSelected ? 9.5 : 11),
                        child: Image.file(
                          controller.customImageStep3.value!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      )
                    : Center(
                        child: Icon(
                          Iconsax.add_circle,
                          size: 22,
                          color: isSelected
                              ? OColors.primary
                              : const Color(0xFFB0AAA2),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              isSelected ? 'Ajouté' : 'Autre',
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? OColors.primary
                    : const Color(0xFF6B6560),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    });
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFF4F1EC),
      child: const Center(
        child: Icon(Iconsax.image, color: Color(0xFFD0CCC8), size: 20),
      ),
    );
  }
}
