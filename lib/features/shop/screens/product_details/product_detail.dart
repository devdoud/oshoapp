import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/features/authentication/screens/login/login.dart';
import 'package:osho/features/personalization/screens/modelcustom/custommodelstep1.dart';
import 'package:osho/features/shop/controllers/cart_controller.dart';
import 'package:osho/features/shop/controllers/customization_controller.dart';
import 'package:osho/features/shop/controllers/favourites_controller.dart';
import 'package:osho/features/shop/models/product_model.dart';
import 'package:osho/features/shop/screens/home/widgets/product_detail_image_slide.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/helpers/helper_functions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductDetail extends StatelessWidget {
  const ProductDetail({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    // African/Earth Tone Palette
    final isDark = OHelperFunctions.isDarkMode(context);
    final favoriteController = Get.put(FavouritesController());
    final cartController = Get.put(CartController());
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFDFBF7);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: bgColor,
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                // --- 1. Immersive Header ---
                SliverAppBar(
                  expandedHeight: 450,
                  pinned: true,
                  backgroundColor: bgColor,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  leading: IconButton(
                    icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: isDark
                                ? Colors.black54
                                : Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle),
                        child: const Icon(Iconsax.arrow_left_2, size: 22)),
                    onPressed: () => Get.back(),
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  actions: [
                    Obx(
                      () => Container(
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.black54
                              : Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            favoriteController.isFavourite(product.id)
                                ? Iconsax.heart5
                                : Iconsax.heart,
                            color: favoriteController.isFavourite(product.id)
                                ? Colors.red
                                : Colors.grey,
                            size: 22,
                          ),
                          onPressed: () async {
                            // Check if logged in before favoriting
                            if (Supabase.instance.client.auth.currentUser ==
                                null) {
                              Get.to(() => const LoginScreen());
                            } else {
                              favoriteController.toggleFavoriteProduct(
                                  product.id);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        OProductDetailImageSlider(product: product),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 100,
                          child: Container(
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, bgColor],
                            )),
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                // --- 2. Body ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'DMSans',
                                            fontSize: 24,
                                            color: isDark
                                                ? Colors.white
                                                : const Color(0xFF2D2D2D)),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Collection Héritage",
                                    style: TextStyle(
                                        color: OColors.primary,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 1,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                  color: OColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12)),
                              child: Text(
                                "${product.price.toStringAsFixed(0)} Fcfa",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                        color: OColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Decorative Line
                        Row(
                          children: List.generate(
                              40,
                              (index) => Container(
                                    width: 4,
                                    height: 1,
                                    color: index % 2 == 0
                                        ? Colors.grey[300]
                                        : Colors.transparent,
                                    margin: const EdgeInsets.only(right: 2),
                                  )),
                        ),

                        const SizedBox(height: 24),

                        // Tags
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _buildPremiumTag(Iconsax.scissor, "Sur mesure"),
                            _buildPremiumTag(Iconsax.star1, "Premium Bazin"),
                            if (product.sku.isNotEmpty)
                              _buildPremiumTag(
                                  Iconsax.tag, "Ref: ${product.sku}"),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Description
                        Text(
                          "L'Histoire du tissu",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          product.description ??
                              "Ce modèle unique allie tradition et modernité. Fabriqué avec soin par nos artisans, il reflète l'élégance de la culture africaine.",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                                height: 1.6,
                                fontSize: 14,
                              ),
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                )
              ],
            ),

            // --- 3. Bottom Bar ---
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, -5))
                    ]),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          await cartController.addItem(product);
                          OLoaders.successSnackBar(
                              title: 'Ajouté',
                              message: 'Le modèle a été ajouté au panier.');
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: OColors.primary),
                          foregroundColor: OColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text(
                          'Ajouter au panier',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (Supabase.instance.client.auth.currentUser == null) {
                            _showLoginRequiredSheet(context);
                          } else {
                            _showEnhancedCustomizationSheet(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: OColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text("Commander ce modèle",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 6),
          Text(text,
              style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showLoginRequiredSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.lock, size: 32, color: OColors.primary),
            const SizedBox(height: 12),
            const Text(
              'Connexion requise',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Vous devez etre connecte pour commander.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], height: 1.4),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Get.to(() => const LoginScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: OColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Se connecter',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Plus tard',
                  style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
  void _showEnhancedCustomizationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 32),
              Text(
                "Comment souhaitez-vous commander ?",
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Une expérience sur mesure ajustée à votre corps.",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  final controller = Get.put(CustomizationController());
                  final incomingCategory = product.categoryType ?? '';
                  controller.categoryType.value =
                      incomingCategory.isNotEmpty ? incomingCategory.toLowerCase() : 'femme';
                  controller.productId.value = product.id;
                  controller.productName.value = product.title;
                  controller.productImage.value = product.thumbnail;
                  controller.basePrice.value = product.price;
                  Get.to(() => CustomModelStep1(
                      categoryType: controller.categoryType.value));
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: OColors.primary.withValues(alpha: 0.05),
                      border: Border.all(color: OColors.primary),
                      borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: OColors.primary,
                            borderRadius: BorderRadius.circular(10)),
                        child:
                            const Icon(Iconsax.magic_star, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Sur Mesure (Recommandé)",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text("Ajusté parfaitement à votre corps",
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Iconsax.arrow_right_3, size: 18)
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Corrected Option: IGNORE (Instead of Standard)
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Text(
                    "Ignorer pour l'instant",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}




