import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:osho/features/shop/controllers/product_controller.dart';
import 'package:osho/common/widgets/loaders/skeleton.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/sizes.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final productController = Get.put(ProductController());

  @override
  void initState() {
    super.initState();
    // Fetch products if list is empty
    if (productController.featuredProducts.isEmpty) {
      productController.fetchAllProducts();
    }

    // Auto-focus the search field after a slight delay to allow transition
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        FocusScope.of(context).requestFocus(_focusNode);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Modern Header with Back Button & Search Field
            Padding(
              padding: const EdgeInsets.all(OSizes.defaultPadding),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Iconsax.arrow_left),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      shape: const CircleBorder(),
                    ),
                  ),
                  const SizedBox(width: OSizes.spaceBtwItems),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        onChanged: (value) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'search_placeholder'.tr,
                          hintStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.grey),
                          prefixIcon: const Icon(Iconsax.search_normal,
                              color: Colors.grey),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Iconsax.close_circle5,
                                      color: Colors.grey),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: OSizes.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // A. Categories (Chips)
                    Text('discover'.tr,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold, fontFamily: 'DMSans')),
                    const SizedBox(height: OSizes.spaceBtwItems),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        'category_men',
                        'category_women',
                        'category_kids',
                        'category_accessories'
                      ].map((key) => _buildCategoryChip(key.tr)).toList(),
                    ),
                    const SizedBox(height: OSizes.spaceBtwSections),

                    // B. Popular/Trending (Tags)
                    Text('popular_searches'.tr,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold, fontFamily: 'DMSans')),
                    const SizedBox(height: OSizes.spaceBtwItems),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        'subcategory_dresses',
                        'subcategory_shirts',
                        'subcategory_shoes',
                        'subcategory_bags',
                        'subcategory_jewelry'
                      ].map((key) => _buildTrendingTag(key.tr)).toList(),
                    ),
                    const SizedBox(height: OSizes.spaceBtwSections),

                    // C. Suggested Grid (Improved with Real Data)
                    Text('suggested_for_you'.tr,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold, fontFamily: 'DMSans')),
                    const SizedBox(height: OSizes.spaceBtwItems),

                    Obx(() {
                      final query = _searchController.text.trim().toLowerCase();
                      final allProducts = productController.featuredProducts;
                      final filteredProducts = query.isEmpty
                          ? allProducts
                          : allProducts.where((p) {
                              final title = p.title.toLowerCase();
                              final category = (p.categoryName ?? '').toLowerCase();
                              return title.contains(query) || category.contains(query);
                            }).toList();

                      if (productController.isLoading.value) {
                        return _buildLoadingGrid();
                      }

                      if (filteredProducts.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Text("Aucun résultat.",
                                style: TextStyle(color: Colors.grey[400])),
                          ),
                        );
                      }

                      return GridView.builder(
                        itemCount: filteredProducts.length.clamp(0, 4),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.65, // Reduced from 0.72 to fix overflow
                        ),
                        itemBuilder: (_, index) => OProductCardVertical(
                          product: filteredProducts[index],
                        ),
                      );
                    }),
                    const SizedBox(height: OSizes.spaceBtwSections),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      itemCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.65,
      ),
      itemBuilder: (_, __) => const OSkeleton(height: 250, width: 170),
    );
  }

  Widget _buildCategoryChip(String label) {
    return GestureDetector(
      onTap: () {
        _searchController.text = label;
        _searchController.selection =
            TextSelection.fromPosition(TextPosition(offset: label.length));
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: OColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: OColors.primary.withOpacity(0.1)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: OColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingTag(String label) {
    return GestureDetector(
      onTap: () {
        _searchController.text = label;
        _searchController.selection =
            TextSelection.fromPosition(TextPosition(offset: label.length));
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.trend_up, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
