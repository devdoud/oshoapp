import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/common/widgets/appbar/appbar.dart';
import 'package:osho/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:osho/features/shop/controllers/favourites_controller.dart';
import 'package:osho/navigation_menu.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/sizes.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FavouritesController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Soft background
      appBar: OAppBar(
        title: Text('Mes Favoris',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        showBackArrow: false, // Corrected: No back arrow for main tab
        actions: [
          IconButton(
              onPressed: () => Get.offAll(() => const NavigationMenu()),
              icon: const Icon(Iconsax.add))
        ],
      ),
      body: Obx(() {
        if (controller.favoriteProducts.isEmpty) {
          return _buildEmptyState(context);
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(OSizes.defaultPadding),
            child: Column(
              children: [
                GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.favoriteProducts.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: OSizes.gridViewSpacing,
                      crossAxisSpacing: OSizes.gridViewSpacing,
                      childAspectRatio: 0.65, // Adjusted to match SearchScreen
                    ),
                    itemBuilder: (_, index) => OProductCardVertical(
                        product: controller.favoriteProducts[index]))
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: OSizes.defaultPadding * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Modern Glowy Icon
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: OColors.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.heart5,
                size: 80,
                color: OColors.primary.withOpacity(0.2),
              ),
            ),
            const SizedBox(height: OSizes.spaceBtwSections),

            // Text
            Text(
              "Votre liste d'envies est vide",
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: OSizes.sm),
            Text(
              "Explorez nos modèles et ajoutez vos coups de cœur ici pour les retrouver plus tard.",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey[600], height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: OSizes.spaceBtwSections),

            // CTA Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.offAll(() => const NavigationMenu()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: OColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text("Découvrir les modèles",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
