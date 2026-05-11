import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/features/personalization/screens/modelcustom/custommodelstep3.dart';
import 'package:osho/features/personalization/screens/modelcustom/custommodelstep4.dart';
import 'package:osho/features/personalization/screens/modelcustom/widgets/customization_layout.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/sizes.dart';
import 'package:osho/features/shop/controllers/customization_controller.dart';

class CustomModelStep1 extends StatefulWidget {
  final String categoryType;
  const CustomModelStep1({super.key, this.categoryType = 'femme'});

  @override
  State<CustomModelStep1> createState() => _CustomModelStep1State();
}

class _CustomModelStep1State extends State<CustomModelStep1> {
  final controller = Get.put(CustomizationController());

  bool get isNextEnabled =>
      controller.selectedFabricOption.value != null ||
      controller.selectedVariantIndex.value == 999;

  @override
  Widget build(BuildContext context) {
    return Obx(() => CustomizationLayout(
          title: 'Le Tissu',
          subTitle: 'Étape 1 · Choisissez votre matière',
          step: 1,
          totalSteps: 4,
          isNextEnabled: isNextEnabled,
          onNext: () {
            final showStep3 = controller.hasFinition.value &&
                controller.step3Options.isNotEmpty;
            if (showStep3) {
              Get.to(() => CustomModelStep3(
                  categoryType: controller.categoryType.value));
            } else {
              Get.to(() => CustomModelStep4(
                  categoryType: controller.categoryType.value));
            }
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: OSizes.spaceBtwItems),
                _buildCatalogView(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ));
  }

  // ── Catalog view ────────────────────────────────────────────────────────────

  Widget _buildCatalogView() {
    if (controller.isLoading.value) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final fabrics = controller.filteredFabrics;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filtres catégorie (uniquement s'il y en a plusieurs)
        if (controller.fabricCategories.length > 1) ...[
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: controller.fabricCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                final cat = controller.fabricCategories[i];
                final isSel =
                    controller.selectedFabricCategory.value == cat;
                return GestureDetector(
                  onTap: () =>
                      controller.selectedFabricCategory.value = cat,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSel ? OColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSel
                            ? OColors.primary
                            : const Color(0xFFE8E4DE),
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSel ? FontWeight.w700 : FontWeight.w500,
                        color: isSel
                            ? Colors.white
                            : const Color(0xFF6B6560),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
        ],

        if (fabrics.isEmpty && controller.fabricCategories.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'Aucun tissu dans cette catégorie.',
                style: TextStyle(fontSize: 13, color: Colors.grey[400]),
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 10,
              childAspectRatio: 0.72,
            ),
            itemCount: fabrics.length + 1,
            itemBuilder: (context, index) {
              if (index == fabrics.length) return _buildCustomCard();
              return _buildFabricCard(fabrics[index]);
            },
          ),
      ],
    );
  }

  // ── Fabric card ─────────────────────────────────────────────────────────────

  Widget _buildFabricCard(Map<String, dynamic> option) {
    final imageUrl = controller.getOptionImage(option);
    final name = controller.getName(option);

    return Obx(() {
      final isSelected = controller.selectedFabricOption.value == option;
      return GestureDetector(
        onTap: () {
          controller.selectedFabricOption.value = option;
          controller.selectedVariantIndex.value =
              controller.step1Options.indexOf(option);
        },
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
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? OColors.primary
                            : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(isSelected ? 7.5 : 10),
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
                      top: 5,
                      right: 5,
                      child: Container(
                        width: 17,
                        height: 17,
                        decoration: const BoxDecoration(
                          color: OColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check,
                            size: 10, color: Colors.white),
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
      final isSelected = controller.selectedVariantIndex.value == 999;
      final hasImage = controller.customImageStep1.value != null;
      return GestureDetector(
        onTap: () => controller.pickCustomImage(1),
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
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? OColors.primary
                        : const Color(0xFFE4E0DA),
                    width: isSelected ? 2.5 : 1,
                  ),
                ),
                child: hasImage
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(
                            isSelected ? 7.5 : 9),
                        child: Image.file(
                          controller.customImageStep1.value!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      )
                    : Center(
                        child: Icon(
                          Iconsax.add_circle,
                          size: 20,
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
        child: Icon(Iconsax.image, color: Color(0xFFD0CCC8), size: 18),
      ),
    );
  }
}
