import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/common/widgets/loaders/skeleton.dart';
import 'package:osho/features/shop/controllers/product_controller.dart';
import 'package:osho/features/shop/models/product_model.dart';
import 'package:osho/features/shop/screens/product_details/product_detail.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/helpers/helper_functions.dart';
import 'package:osho/utils/helpers/logistics_calculator.dart';

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
    if (productController.featuredProducts.isEmpty) {
      productController.fetchAllProducts();
    }
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) FocusScope.of(context).requestFocus(_focusNode);
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
    final isDark = OHelperFunctions.isDarkMode(context);
    final query = _searchController.text.trim().toLowerCase();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF111111) : const Color(0xFFF8F6F3),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(isDark),
              Expanded(
                child: query.isEmpty
                    ? _buildDiscovery(isDark)
                    : _buildResults(query, isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Search bar ────────────────────────────────────────────────────────────

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF222222) : Colors.white,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF2E2E2E)
                      : const Color(0xFFEEEBE6),
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 15,
                color: isDark ? Colors.white70 : OColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF2A2A2A)
                      : const Color(0xFFEEEBE6),
                ),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                onChanged: (_) => setState(() {}),
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF2C2A27),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'search_placeholder'.tr,
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white30 : const Color(0xFFB0AAA2),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Icon(
                    Iconsax.search_normal,
                    color: isDark ? Colors.white30 : const Color(0xFFB0AAA2),
                    size: 17,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(13),
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white12
                                    : const Color(0xFFE8E4DF),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: 11,
                                color: isDark
                                    ? Colors.white60
                                    : const Color(0xFF6E6660),
                              ),
                            ),
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Discovery (empty query) ───────────────────────────────────────────────

  Widget _buildDiscovery(bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          _sectionLabel('discover'.tr, isDark),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                'category_men',
                'category_women',
                'category_kids',
                'category_accessories',
              ].map((k) => _buildCategoryChip(k.tr, isDark)).toList(),
            ),
          ),
          const SizedBox(height: 24),
          _sectionLabel('popular_searches'.tr, isDark),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                'subcategory_dresses',
                'subcategory_shirts',
                'subcategory_shoes',
                'subcategory_bags',
                'subcategory_jewelry',
              ].map((k) => _buildTrendingTag(k.tr, isDark)).toList(),
            ),
          ),
          const SizedBox(height: 24),
          _sectionLabel('suggested_for_you'.tr, isDark),
          const SizedBox(height: 10),
          _buildSuggestionsVertical(isDark),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          color: isDark ? Colors.white : OColors.primary,
        ),
      ),
    );
  }

  // ── Suggestion rows ───────────────────────────────────────────────────────

  Widget _buildSuggestionsVertical(bool isDark) {
    return Obx(() {
      if (productController.isLoading.value) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: List.generate(
              4,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OSkeleton(
                    height: 62, width: double.infinity, radius: 14),
              ),
            ),
          ),
        );
      }

      // Only show products explicitly marked as featured
      final suggestions = productController.featuredProducts
          .where((p) => p.isFeatured)
          .take(6)
          .toList();
      if (suggestions.isEmpty) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            for (int i = 0; i < suggestions.length; i++) ...[
              _buildSuggestionRow(suggestions[i], isDark),
              if (i < suggestions.length - 1) const SizedBox(height: 8),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildSuggestionRow(ProductModel product, bool isDark) {
    return GestureDetector(
      onTap: () => Get.to(() => ProductDetail(product: product)),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? const Color(0xFF2A2A2A)
                : const Color(0xFFF0EDE8),
          ),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: SizedBox(
                width: 46,
                height: 46,
                child: Image(
                  image: product.thumbnail.startsWith('http')
                      ? NetworkImage(product.thumbnail)
                      : AssetImage(product.thumbnail) as ImageProvider,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: isDark
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFFF3F0EC),
                    child: Icon(Iconsax.image,
                        size: 18,
                        color: isDark
                            ? Colors.white24
                            : const Color(0xFFCCC8C2)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 11),
            // Info
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? Colors.white
                          : const Color(0xFF2C2A27),
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    OLogisticsCalculator.formatFee(product.price),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: OColors.primary.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            // Chevron
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF282828)
                    : const Color(0xFFF5F2EE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 11,
                color: isDark
                    ? Colors.white38
                    : const Color(0xFFB0AAA2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Search results ────────────────────────────────────────────────────────

  Widget _buildResults(String query, bool isDark) {
    return Obx(() {
      if (productController.isLoading.value) {
        return const Center(
            child: CircularProgressIndicator(color: OColors.primary));
      }

      final results = productController.featuredProducts.where((p) {
        final title = p.title.toLowerCase();
        final category = (p.categoryName ?? '').toLowerCase();
        return title.contains(query) || category.contains(query);
      }).toList();

      if (results.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1C1C1C)
                      : const Color(0xFFF0EDE8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Iconsax.search_status,
                    size: 28,
                    color: isDark
                        ? Colors.white24
                        : const Color(0xFFB0AAA2)),
              ),
              const SizedBox(height: 14),
              Text(
                'Aucun résultat pour "$query"',
                style: TextStyle(
                  color: isDark ? Colors.white38 : const Color(0xFFB0AAA2),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: results.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => _buildResultRow(results[i], isDark),
      );
    });
  }

  Widget _buildResultRow(ProductModel product, bool isDark) {
    return GestureDetector(
      onTap: () => Get.to(() => ProductDetail(product: product)),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? const Color(0xFF2A2A2A)
                : const Color(0xFFF0EDE8),
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: SizedBox(
                width: 46,
                height: 46,
                child: Image(
                  image: product.thumbnail.startsWith('http')
                      ? NetworkImage(product.thumbnail)
                      : AssetImage(product.thumbnail) as ImageProvider,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: isDark
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFFF3F0EC),
                    child: Icon(Iconsax.image,
                        size: 18,
                        color: isDark
                            ? Colors.white24
                            : const Color(0xFFCCC8C2)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? Colors.white
                          : const Color(0xFF2C2A27),
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    OLogisticsCalculator.formatFee(product.price),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: OColors.primary.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF282828)
                    : const Color(0xFFF5F2EE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 11,
                color: isDark ? Colors.white38 : const Color(0xFFB0AAA2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Category chip ─────────────────────────────────────────────────────────

  Widget _buildCategoryChip(String label, bool isDark) {
    return GestureDetector(
      onTap: () {
        _searchController.text = label;
        _searchController.selection = TextSelection.fromPosition(
            TextPosition(offset: label.length));
        setState(() {});
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1C1C1C)
              : OColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isDark
                ? const Color(0xFF2E2E2E)
                : OColors.primary.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white70 : OColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // ── Trending tag ──────────────────────────────────────────────────────────

  Widget _buildTrendingTag(String label, bool isDark) {
    return GestureDetector(
      onTap: () {
        _searchController.text = label;
        _searchController.selection = TextSelection.fromPosition(
            TextPosition(offset: label.length));
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1C1C1C)
              : const Color(0xFFF0EDE8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? const Color(0xFF2A2A2A)
                : const Color(0xFFE8E4DE),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.trend_up,
                size: 12,
                color: isDark
                    ? Colors.white30
                    : const Color(0xFFB0AAA2)),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: isDark
                    ? Colors.white60
                    : const Color(0xFF6E6660),
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
