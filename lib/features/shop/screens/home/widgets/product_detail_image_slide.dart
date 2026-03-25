import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:osho/common/widgets/circular_container.dart';
import 'package:osho/common/widgets/loaders/skeleton.dart';
import 'package:osho/features/shop/controllers/home_controller.dart';
import 'package:osho/features/shop/models/product_model.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/sizes.dart';
import 'package:iconsax/iconsax.dart';

class OProductDetailImageSlider extends StatelessWidget {
  const OProductDetailImageSlider({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final List<String> images =
        product.images != null && product.images!.isNotEmpty ?
             product.images!
            : [product.thumbnail];

    return Stack(children: [
      CarouselSlider(
        options: CarouselOptions(
            viewportFraction: 1,
            height: 400,
            onPageChanged: (index, _) => controller.updatePageIndicator(index)),
        items: images.map((imageUrl) {
          // 🔍 DEBUG: Afficher l'URL de chaque image du carrousel
          print('🖼️ Carousel image: $imageUrl');
          print('   Starts with http: ${imageUrl.startsWith('http')}');

          return Stack(
            children: [
              const OSkeleton(
                  height: double.infinity, width: double.infinity, radius: 0),
              Image(
                image: imageUrl.startsWith('http') ?
                     NetworkImage(imageUrl)
                    : AssetImage(imageUrl) as ImageProvider,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('❌ Carousel image error: $error');
                  return const Center(
                      child: Icon(Iconsax.image, color: Colors.grey));
                },
              ),
            ],
          );
        }).toList(),
      ),

      // Indicators
      Positioned(
        bottom: 20,
        left: 0,
        right: 0,
        child: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < images.length; i++)
                OCircularContainer(
                  width: controller.carousalCurrentIndex.value == i ? 32 : 8,
                  height: 4,
                  radius: 10,
                  padding: 0,
                  margin: const EdgeInsets.only(right: 6),
                  backgroundColor: controller.carousalCurrentIndex.value == i ?
                       OColors.primary
                      : Colors.grey.withOpacity(0.3),
                ),
            ],
          ),
        ),
      ),
    ]);
  }
}
