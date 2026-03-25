import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/features/personalization/screens/modelcustom/custommodelstep2.dart';
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

  bool get isNextEnabled {
    // If Catalog mode, must select a variant. If My Fabric mode, can proceed.
    if (controller.inputMode.value == 0) {
      return controller.selectedVariantIndex.value != -1;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => CustomizationLayout(
          title: 'Le Tissu',
          subTitle:
              'Étape 1 : Choisissez votre matière (${widget.categoryType})',
          step: 1,
          totalSteps: 4,
          isNextEnabled: isNextEnabled,
          onNext: () {
            Get.to(() =>
                CustomModelStep2(categoryType: controller.categoryType.value));
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: OSizes.spaceBtwItems),

                // --- 1. Mode Toggle (Segmented Look) ---
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!)),
                  child: Row(
                    children: [
                      _buildToggleOption(0, "Catalogue Osho", Iconsax.book_1),
                      _buildToggleOption(1, "J'ai mon tissu", Iconsax.box),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // --- 2. Content Switching ---
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: controller.inputMode.value == 0
                      ? _buildCatalogView()
                      : _buildMyFabricView(),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ));
  }

  Widget _buildToggleOption(int index, String label, IconData icon) {
    final isSelected = controller.inputMode.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.inputMode.value = index,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ]
                  : []),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18, color: isSelected ? OColors.primary : Colors.grey),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? OColors.primary : Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- View: Catalog ---
  Widget _buildCatalogView() {
    return Column(
      key: const ValueKey("Catalog"),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (controller.isLoading.value)
          const Center(child: CircularProgressIndicator())
        else if (controller.step1Options.isEmpty)
          const Center(child: Text("Aucun tissu disponible pour le moment."))
        else
          // Grid of Fabrics
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 columns for better visibility
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: controller.step1Options.length,
            itemBuilder: (context, index) {
              final option = controller.step1Options[index];
              final imageUrl = controller.getOptionImage(option);
              final name = controller.getName(option);

              return Obx(() {
                final isSelected =
                    controller.selectedVariantIndex.value == index;
                return GestureDetector(
                  onTap: () {
                    controller.selectedVariantIndex.value = index;
                    controller.selectedFabricOption.value = option;
                    controller.selectedCategory.value =
                        name; // Update display text
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: isSelected
                                ? OColors.primary
                                : Colors.transparent,
                            width: isSelected ? 2 : 0),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2))
                        ]),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (imageUrl.isNotEmpty)
                            Image(
                              image: imageUrl.startsWith('http')
                                  ? NetworkImage(imageUrl)
                                  : AssetImage(imageUrl)
                                      as ImageProvider, // Fallback for local assets if any
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey[200],
                                  child:
                                      Icon(Iconsax.image, color: Colors.grey)),
                            )
                          else
                            Container(
                                color: Colors.grey[200],
                                child: Icon(Iconsax.image, color: Colors.grey)),

                          // Gradient Protection
                          Positioned.fill(
                              child: Container(
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.6)
                              ],
                                          stops: const [
                                0.6,
                                1.0
                              ])))),

                          // Name
                          Positioned(
                              bottom: 8,
                              left: 8,
                              right: 8,
                              child: Text(
                                name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )),

                          if (isSelected)
                            Container(
                              color: OColors.primary.withOpacity(0.2),
                              child: const Center(
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 14,
                                  child: Icon(Icons.check,
                                      size: 16, color: OColors.primary),
                                ),
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                );
              });
            },
          ),

        const SizedBox(height: 32),

        // --- 3. Missing Variant / Upload Option ---
        GestureDetector(
          onTap: () => controller.pickCustomImage(1),
          // ... Rest remains same logic but connected to controller
          child: Obx(() => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: controller.selectedVariantIndex.value == 999
                      ? OColors.primary.withValues(alpha: 0.03)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: controller.selectedVariantIndex.value == 999
                        ? OColors.primary.withValues(alpha: 0.5)
                        : Colors.grey[100]!,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    // Show thumbnail of picked image or camera icon
                    controller.customImageStep1.value != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              controller.customImageStep1.value!,
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: controller.selectedVariantIndex.value == 999
                                  ? OColors.primary
                                  : Colors.grey[50],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              controller.selectedVariantIndex.value == 999
                                  ? Iconsax.gallery_tick
                                  : Iconsax.camera,
                              color: controller.selectedVariantIndex.value == 999
                                  ? Colors.white
                                  : OColors.primary.withValues(alpha: 0.6),
                              size: 20,
                            ),
                          ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.selectedVariantIndex.value == 999
                                ? "Motif Ajouté"
                                : "Autre motif ?",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color:
                                    controller.selectedVariantIndex.value == 999
                                        ? OColors.primary
                                        : Colors.black87),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            controller.selectedVariantIndex.value == 999
                                ? "Nous utiliserons ce motif pour votre tenue."
                                : "Importer une photo du motif souhaité",
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    if (controller.selectedVariantIndex.value == 999)
                      const Icon(Icons.check_circle,
                          color: OColors.primary, size: 20)
                    else
                      Icon(Icons.arrow_forward_ios,
                          size: 10, color: Colors.grey[300])
                  ],
                ),
              )),
        ),
      ],
    );
  }

  // --- View: My Fabric ---
  Widget _buildMyFabricView() {
    return Column(
      key: const ValueKey("MyFabric"),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[200]!)),
          child: Column(
            children: [
              const Icon(Iconsax.info_circle, size: 40, color: OColors.primary),
              const SizedBox(height: 16),
              const Text(
                "Vous avez déjà votre tissu ?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "Pas de problème ! Une fois la commande passée, un coursier viendra récupérer votre tissu, ou vous pourrez le déposer à notre atelier.",
                style: TextStyle(height: 1.5, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Optional Photo Upload
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              border:
                  Border.all(color: Colors.grey[300]!, style: BorderStyle.none),
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: [
              Icon(Iconsax.camera, color: Colors.grey[400], size: 32),
              const SizedBox(height: 8),
              const Text(
                "Ajouter une photo du tissu (Optionnel)",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                "Cela nous aide à anticiper le style.",
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
