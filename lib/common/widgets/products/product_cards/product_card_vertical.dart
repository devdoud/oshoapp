import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/features/shop/controllers/favourites_controller.dart';
import 'package:osho/features/shop/models/product_model.dart';
import 'package:osho/features/shop/screens/product_details/product_detail.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/common/widgets/loaders/skeleton.dart';
import 'package:osho/utils/helpers/helper_functions.dart';

class OProductCardVertical extends StatelessWidget {
  const OProductCardVertical({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final dark = OHelperFunctions.isDarkMode(context);
    final favoriteController = Get.put(FavouritesController());

    // Soft & Modern Design Constants
    const double cardRadius = 24.0;

    return GestureDetector(
      onTap: () => Get.to(() => ProductDetail(product: product)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(cardRadius),
          color: dark ? OColors.primaryBackground : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: -5,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Image Section (Expanded to fit available space) ---
            Expanded(
              child: Stack(
                children: [
                  // Image Container
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(cardRadius)),
                      color: dark ? OColors.grey : const Color(0xFFF7F7F7),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(cardRadius)),
                      child: Stack(
                        children: [
                          const OSkeleton(
                              height: double.infinity, width: double.infinity),
                          Image(
                            image: product.thumbnail.startsWith('http')
                                ? NetworkImage(product.thumbnail)
                                : AssetImage(product.thumbnail) as ImageProvider,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                                    child: Icon(Iconsax.image,
                                        color: Colors.grey, size: 30)),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Floating Favorite Button (Save for later)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Obx(
                      () => Container(
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle),
                        child: IconButton(
                          onPressed: () => favoriteController
                              .toggleFavoriteProduct(product.id),
                          icon: Icon(
                            favoriteController.isFavourite(product.id)
                                ? Iconsax.heart5
                                : Iconsax.heart,
                            color: favoriteController.isFavourite(product.id)
                                ? Colors.red
                                : Colors.grey,
                            size: 18,
                          ),
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(6),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- 2. Details Section ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'DMSans'),
                  ),
                  const SizedBox(height: 4),

                  // Price & Add Button Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Flexible(
                        child: Text(
                          "${product.price.toStringAsFixed(0)} F",
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                  color: OColors.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15),
                        ),
                      ),

                      // Add to Cart
                      Container(
                        decoration: BoxDecoration(
                          color: OColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Iconsax.add,
                            color: OColors.primary, size: 20),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
