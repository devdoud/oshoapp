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

  bool get isNextEnabled {
    // Basic validation
    return controller.selectedStep3Option.value >= 0;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentOptions = controller.step3Options;

      return CustomizationLayout(
        title: widget.categoryType == 'homme' ? "Finition" : "Accessoire",
        subTitle: widget.categoryType == 'homme'
            ? "Étape 3 : Choisissez la finition"
            : "Étape 3 : Choisissez l'accessoire",
        step: 3,
        totalSteps: 4,
        isNextEnabled: isNextEnabled,
        onNext: () {
          Get.to(() => CustomModelStep4(categoryType: widget.categoryType));
        },
        child: Column(
          children: [
            const SizedBox(height: OSizes.spaceBtwSections / 1.5),

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
                    crossAxisSpacing: 22, // Increased spacing
                    mainAxisSpacing: 22,
                    childAspectRatio: 0.7, // Slightly taller for more elegance
                  ),
                  itemCount: currentOptions.length,
                  itemBuilder: (context, index) {
                    final option = currentOptions[index];
                    final imageUrl = controller.getOptionImage(option);
                    final title = controller.getName(option);

                    return Obx(() {
                      final isSelected =
                          controller.selectedStep3Option.value == index;

                      return GestureDetector(
                        onTap: () =>
                            controller.selectedStep3Option.value = index,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutQuint,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(28), // Softer radius
                            border: Border.all(
                              color: isSelected
                                  ? OColors.primary
                                  : Colors.transparent,
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? OColors.primary.withOpacity(0.12)
                                    : Colors.black.withOpacity(0.05),
                                blurRadius: isSelected ? 25 : 15,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(25.5),
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

                              // Softer Gradient
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25.5),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.0),
                                        Colors.black.withOpacity(0.55),
                                      ],
                                      stops: const [0.6, 0.75, 1.0],
                                    ),
                                  ),
                                ),
                              ),

                              if (isSelected)
                                Positioned(
                                  top: 14,
                                  right: 14,
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: const BoxDecoration(
                                      color: OColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.check,
                                        size: 12, color: Colors.white),
                                  ),
                                ),

                              Positioned(
                                bottom: 18,
                                left: 14,
                                right: 14,
                                child: Text(
                                  title.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9.5, // Even more minimalist
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
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

            const SizedBox(height: 28),

            // --- 3. Custom Option Upload ---
            GestureDetector(
              onTap: () => controller.pickCustomImage(3),
              child: Obx(() => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: controller.selectedStep3Option.value == 999
                          ? OColors.primary.withOpacity(0.03)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: controller.selectedStep3Option.value == 999
                            ? OColors.primary.withOpacity(0.5)
                            : Colors.grey[100]!,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Show thumbnail if image was picked
                        controller.customImageStep3.value != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  controller.customImageStep3.value!,
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      controller.selectedStep3Option.value == 999
                                          ? OColors.primary
                                          : Colors.grey[50],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  controller.selectedStep3Option.value == 999
                                      ? Iconsax.gallery_tick
                                      : Iconsax.magic_star,
                                  color:
                                      controller.selectedStep3Option.value == 999
                                          ? Colors.white
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
                                controller.selectedStep3Option.value == 999
                                    ? "Option Spécifiée"
                                    : "Un souhait particulier ?",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color:
                                      controller.selectedStep3Option.value == 999
                                          ? OColors.primary
                                          : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                controller.selectedStep3Option.value == 999
                                    ? "Nous prendrons cela en compte."
                                    : "Uploader une photo pour un détail unique",
                                style: TextStyle(
                                    color: Colors.grey[500], fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        if (controller.selectedStep3Option.value == 999)
                          const Icon(Icons.check_circle,
                              color: OColors.primary, size: 20)
                        else
                          Icon(Icons.arrow_forward_ios,
                              size: 10, color: Colors.grey[300])
                      ],
                    ),
                  )),
            ),
            const SizedBox(height: OSizes.spaceBtwSections / 1.5),
          ],
        ),
      );
    });
  }
}
