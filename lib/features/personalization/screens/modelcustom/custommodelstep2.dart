import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/features/personalization/screens/modelcustom/custommodelstep3.dart';
import 'package:osho/features/personalization/screens/modelcustom/widgets/customization_layout.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/sizes.dart';
import 'package:osho/features/shop/controllers/customization_controller.dart';

class CustomModelStep2 extends StatefulWidget {
  final String categoryType;
  const CustomModelStep2({super.key, this.categoryType = 'femme'});

  @override
  State<CustomModelStep2> createState() => _CustomModelStep2State();
}

class _CustomModelStep2State extends State<CustomModelStep2> {
  final controller = Get.put(CustomizationController());

  bool get isNextEnabled {
    // Basic validation: ensure something is selected (either generic or custom)
    return controller.selectedStep2Option.value >= 0;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentOptions = controller.step2Options;

      return CustomizationLayout(
        title: widget.categoryType == 'homme' ? "La Broderie" : "La Coupe",
        subTitle: widget.categoryType == 'homme'
            ? "Étape 2 : Style de broderie"
            : "Étape 2 : Détails de la coupe",
        step: 2,
        totalSteps: 4,
        isNextEnabled: isNextEnabled,
        onNext: () {
          Get.to(() => CustomModelStep3(categoryType: widget.categoryType));
        },
        child: Column(
          children: [
            const SizedBox(height: OSizes.spaceBtwSections / 2),

            if (controller.isLoading.value)
              const CircularProgressIndicator()
            else if (currentOptions.isEmpty)
              const Center(child: Text("Aucune option disponible."))
            else
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.72, // Proportion for elegant cards
                  ),
                  itemCount: currentOptions.length,
                  itemBuilder: (context, index) {
                    final option = currentOptions[index];
                    final imageUrl = controller.getOptionImage(option);
                    final title = controller.getName(option);

                    return Obx(() {
                      final isSelected =
                          controller.selectedStep2Option.value == index;

                      return GestureDetector(
                        onTap: () =>
                            controller.selectedStep2Option.value = index,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isSelected
                                  ? OColors.primary
                                  : Colors.transparent,
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(isSelected ? 0.08 : 0.03),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              )
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Image layer
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      21.5), // Match container radius minus border
                                  child: imageUrl.isNotEmpty
                                      ? Image(
                                          image: imageUrl.startsWith('http')
                                              ? NetworkImage(imageUrl)
                                              : AssetImage(imageUrl)
                                                  as ImageProvider,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                                  color: Colors.grey[200],
                                                  child: Icon(Iconsax.image,
                                                      color: Colors.grey)),
                                        )
                                      : Container(
                                          color: Colors.grey[200],
                                          child: Icon(Iconsax.image,
                                              color: Colors.grey)),
                                ),
                              ),

                              // Subtle Gradient Overlay for Text Readability
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(21.5),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.0),
                                        Colors.black.withOpacity(0.6),
                                      ],
                                      stops: const [0.5, 0.7, 1.0],
                                    ),
                                  ),
                                ),
                              ),

                              // Selection Badge (Top Right)
                              if (isSelected)
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: OColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.check,
                                        size: 14, color: Colors.white),
                                  ),
                                ),

                              // Option Title (Bottom)
                              Positioned(
                                bottom: 16,
                                left: 12,
                                right: 12,
                                child: Text(
                                  title.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),

            const SizedBox(height: 24),

            // --- 3. Custom Style Upload Option ---
            GestureDetector(
              onTap: () => controller.pickCustomImage(2),
              child: Obx(() => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: controller.selectedStep2Option.value == 999
                          ? OColors.primary.withOpacity(0.03)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: controller.selectedStep2Option.value == 999
                            ? OColors.primary.withOpacity(0.1)
                            : Colors.grey[100]!,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Show thumbnail if image was picked
                        controller.customImageStep2.value != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  controller.customImageStep2.value!,
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      controller.selectedStep2Option.value == 999
                                          ? OColors.primary
                                          : Colors.grey[50],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  controller.selectedStep2Option.value == 999
                                      ? Iconsax.gallery_tick
                                      : Iconsax.add_square,
                                  color:
                                      controller.selectedStep2Option.value == 999
                                          ? OColors.primary
                                          : OColors.primary.withOpacity(0.6),
                                  size: 20,
                                ),
                              ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.selectedStep2Option.value == 999
                                    ? "Style Personnalisé Ajouté"
                                    : "Autre style ?",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color:
                                      controller.selectedStep2Option.value == 999
                                          ? OColors.primary
                                          : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                controller.selectedStep2Option.value == 999
                                    ? "Nous réaliserons votre tenue selon votre photo."
                                    : "Uploader une photo de votre modèle",
                                style: TextStyle(
                                    color: Colors.grey[500], fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        if (controller.selectedStep2Option.value == 999)
                          const Icon(Icons.check_circle,
                              color: OColors.primary, size: 20)
                        else
                          Icon(Icons.arrow_forward_ios,
                              size: 10, color: Colors.grey[300])
                      ],
                    ),
                  )),
            ),

            const SizedBox(height: OSizes.spaceBtwSections / 2),
          ],
        ),
      );
    });
  }
}
