import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/common/widgets/custom_shapes/containers/search_container.dart';
import 'package:osho/common/widgets/loaders/skeleton.dart';
import 'package:osho/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:osho/features/shop/controllers/category_controller.dart';
import 'package:osho/features/shop/controllers/product_controller.dart';
import 'package:osho/features/shop/controllers/cart_controller.dart';
import 'package:osho/features/shop/screens/search/search.dart';
import 'package:osho/features/shop/screens/store/store.dart';
import 'package:osho/features/personalization/screens/settings/setting.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/image_strings.dart';
import 'package:osho/utils/constants/sizes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final productController = Get.put(ProductController());
  final categoryController = Get.put(CategoryController());
  final cartController = Get.put(CartController());

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            Brightness.dark, // Dark icons for white background
        statusBarBrightness: Brightness.light, // For iOS
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: OSizes.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: OSizes.sm),

                  // --- 1. Header (Logo + Refresh + Profile Icon) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image(
                        image: AssetImage(OImages.logo),
                        width: 90,
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                      Row(
                        children: [
                          // 🔄 Refresh Button
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.05),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () {
                                categoryController.fetchCategories();
                                productController.fetchAllProducts();
                              },
                              icon: const Icon(Iconsax.refresh,
                                  color: OColors.primary, size: 22),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Obx(() {
                            final count = cartController.totalItems;
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.05),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    onPressed: () =>
                                        Get.to(() => const StoreScreen()),
                                    icon: const Icon(Iconsax.shopping_bag,
                                        color: OColors.textprimary, size: 22),
                                  ),
                                ),
                                if (count > 0)
                                  Positioned(
                                    right: -2,
                                    top: -2,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      constraints: const BoxConstraints(
                                          minWidth: 18, minHeight: 18),
                                      decoration: const BoxDecoration(
                                        color: OColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        count.toString(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          }),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.05),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () => Get.to(() => const SettingsScreen()),
                              icon: const Icon(Iconsax.user,
                                  color: OColors.textprimary, size: 22),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: OSizes.spaceBtwSections),

                  // --- 2. Headlines ---
                  // Using Wrap or constraining width to prevent overflow on smaller screens
                  SizedBox(
                    width: double.infinity,
                    child: Text.rich(
                      TextSpan(
                        text: "home_title_1".tr,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                                color: OColors.textprimary,
                                fontSize: 26, // Reduced slightly
                                fontWeight: FontWeight.w700,
                                height: 1.2),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'home_title_2'.tr,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: OColors.primary,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w400,
                                ),
                          ),
                          TextSpan(
                            text: 'home_title_3'.tr,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: OColors.textprimary,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          TextSpan(
                            text: 'home_title_4'.tr,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: OColors.primary,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w400,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: OSizes.spaceBtwSections),

                  // --- 3. Search Bar ---
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9F9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: OSearchContainer(
                      text: "search_hint".tr,
                      onTap: () => Get.to(() => const SearchScreen()),
                    ),
                  ),
                  const SizedBox(height: OSizes.spaceBtwSections),

                  // --- 4. Categories ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "categories".tr,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "view_all".tr,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: OColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: OSizes.spaceBtwItems),

                  Obx(() {
                    if (categoryController.isLoading.value) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(
                              5,
                              (index) => Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: OSkeleton(
                                        height: 45, width: 100, radius: 30),
                                  )),
                        ),
                      );
                    }
                    if (categoryController.featuredCategories.isEmpty) {
                      return Center(
                          child: Text('No Categories Found!',
                              style: Theme.of(context).textTheme.bodyMedium));
                    }

                    final categories = categoryController.featuredCategories;
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(categories.length, (index) {
                          final category = categories[index];
                          return Obx(() {
                            final isSelected = categoryController
                                    .selectedCategoryIndex.value ==
                                index;
                            return GestureDetector(
                              onTap: () =>
                                  categoryController.selectCategory(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected ?
                                      OColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: isSelected ?
                                        Colors.transparent
                                        : Colors.grey.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  category.name,
                                  style: TextStyle(
                                    color: isSelected ?
                                        Colors.white
                                        : Colors.black87,
                                    fontWeight: isSelected ?
                                        FontWeight.w600
                                        : FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          });
                        }),
                      ),
                    );
                  }),
                  const SizedBox(height: OSizes.spaceBtwSections),

                  // --- 5. Grid Content ---
                  Obx(() {
                    if (productController.isLoading.value) {
                      return GridView.builder(
                        itemCount: 4,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio:
                              0.62, // Adjusted for new card height
                        ),
                        itemBuilder: (_, __) => const OSkeleton(
                            height: 180, width: 180, radius: 20),
                      );
                    }

                    if (productController.featuredProducts.isEmpty) {
                      return Center(
                          child: Text('No Products Found!',
                              style: Theme.of(context).textTheme.bodyMedium));
                    }

                    return GridView.builder(
                      itemCount: productController.featuredProducts.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.62, // Adjusted for new card height
                      ),
                      itemBuilder: (_, index) {
                        final product =
                            productController.featuredProducts[index];
                        return OProductCardVertical(product: product);
                      },
                    );
                  }),
                  const SizedBox(height: 100), // Extra space for scroll
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
