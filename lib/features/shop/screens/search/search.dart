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

  // ── Contenu mode africaine ────────────────────────────────────────────────

  static const _discoverItems = [
    _DiscoverItem('Boubou', Iconsax.star),
    _DiscoverItem('Bazin Riche', Iconsax.diamonds),
    _DiscoverItem('Wax', Iconsax.color_swatch),
    _DiscoverItem('Mariage', Iconsax.heart),
    _DiscoverItem('Couple', Iconsax.profile_2user),
    _DiscoverItem('Kente', Iconsax.tag_2),
  ];

  static const _trendingFR = [
    'Grand Boubou',
    'Bazin brodé',
    'Tenue de mariage',
    'Kaftan femme',
    'Dashiki homme',
    'Ensemble couple',
    'Agbada',
    'Wax print',
  ];

  static const _trendingEN = [
    'Grand Boubou',
    'Embroidered Bazin',
    'Wedding outfit',
    'Kaftan women',
    'Dashiki men',
    'Couple outfit',
    'Agbada',
    'Wax print',
  ];

  bool get _isEn => Get.locale?.languageCode == 'en';
  List<String> get _trending => _isEn ? _trendingEN : _trendingFR;

  @override
  void initState() {
    super.initState();
    if (productController.featuredProducts.isEmpty) {
      productController.fetchAllProducts();
    }
    Future.delayed(const Duration(milliseconds: 280), () {
      if (mounted) FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _search(String term) {
    _searchController.text = term;
    _searchController.selection =
        TextSelection.fromPosition(TextPosition(offset: term.length));
    _focusNode.unfocus();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = OHelperFunctions.isDarkMode(context);
    final query = _searchController.text.trim().toLowerCase();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF5F3F0),
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

  // ── Barre de recherche ────────────────────────────────────────────────────

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFEEEBE6),
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 15,
                color: isDark ? Colors.white70 : const Color(0xFF1A1A1A),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFEEEBE6),
                ),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                onChanged: (_) => setState(() {}),
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'search_placeholder'.tr,
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white30 : const Color(0xFFB0AAA2),
                    fontSize: 14,
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
                            padding: const EdgeInsets.all(14),
                            child: Container(
                              width: 16, height: 16,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white12
                                    : const Color(0xFFE8E4DF),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.close_rounded,
                                  size: 10,
                                  color: isDark
                                      ? Colors.white60
                                      : const Color(0xFF6E6660)),
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

  // ── Discovery ─────────────────────────────────────────────────────────────

  Widget _buildDiscovery(bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Styles
          _sectionLabel(
              _isEn ? 'Styles' : 'Styles', isDark),
          const SizedBox(height: 12),
          SizedBox(
            height: 76,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              itemCount: _discoverItems.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) =>
                  _discoverCard(_discoverItems[i], isDark),
            ),
          ),

          const SizedBox(height: 26),

          // Tendances
          _sectionLabel(
              _isEn ? 'Trending' : 'Tendances', isDark),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8, runSpacing: 8,
              children: _trending
                  .asMap()
                  .entries
                  .map((e) => _trendTag(e.value, e.key < 3, isDark))
                  .toList(),
            ),
          ),

          const SizedBox(height: 26),

          // Suggestions
          _sectionLabel('suggested_for_you'.tr, isDark),
          const SizedBox(height: 12),
          _buildSuggestions(isDark),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Section label ─────────────────────────────────────────────────────────

  Widget _sectionLabel(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 1,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : const Color(0xFFEEEBE6),
            ),
          ),
        ],
      ),
    );
  }

  // ── Discover card ─────────────────────────────────────────────────────────

  Widget _discoverCard(_DiscoverItem item, bool isDark) {
    return GestureDetector(
      onTap: () => _search(item.label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : const Color(0xFFEEEBE6),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(item.icon, size: 16,
                color: isDark ? Colors.white38 : OColors.primary),
            const SizedBox(height: 6),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : const Color(0xFF1A1A1A),
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Trend tag ─────────────────────────────────────────────────────────────

  Widget _trendTag(String label, bool isTop, bool isDark) {
    return GestureDetector(
      onTap: () => _search(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isTop
              ? OColors.primary.withValues(alpha: isDark ? 0.12 : 0.07)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : const Color(0xFFF4F1EC)),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isTop
                ? OColors.primary.withValues(alpha: 0.20)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : const Color(0xFFE8E4DE)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isTop ? FontWeight.w700 : FontWeight.w500,
            color: isTop
                ? OColors.primary
                : (isDark ? Colors.white54 : const Color(0xFF4A4542)),
            letterSpacing: -0.1,
          ),
        ),
      ),
    );
  }

  // ── Suggestions ───────────────────────────────────────────────────────────

  Widget _buildSuggestions(bool isDark) {
    return Obx(() {
      if (productController.isLoading.value) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: List.generate(4, (_) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: OSkeleton(
                  height: 64, width: double.infinity, radius: 14),
            )),
          ),
        );
      }

      final list = productController.featuredProducts
          .where((p) => p.isFeatured)
          .take(6)
          .toList();

      if (list.isEmpty) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            for (int i = 0; i < list.length; i++) ...[
              _productRow(list[i], isDark),
              if (i < list.length - 1) const SizedBox(height: 7),
            ],
          ],
        ),
      );
    });
  }

  // ── Product row ───────────────────────────────────────────────────────────

  Widget _productRow(ProductModel product, bool isDark) {
    return GestureDetector(
      onTap: () => Get.to(() => ProductDetail(product: product)),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : const Color(0xFFEEEBE6),
          ),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 46, height: 46,
                child: Image(
                  image: product.thumbnail.startsWith('http')
                      ? NetworkImage(product.thumbnail)
                      : AssetImage(product.thumbnail) as ImageProvider,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : const Color(0xFFF3F0EC),
                    child: Icon(Iconsax.image, size: 16,
                        color: isDark
                            ? Colors.white24
                            : const Color(0xFFCCC8C2)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(children: [
                    if (product.fabric != null &&
                        product.fabric!.isNotEmpty) ...[
                      Text(
                        product.fabric!,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? Colors.white38
                              : const Color(0xFFB0AAA2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Container(
                          width: 3, height: 3,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white24
                                : const Color(0xFFCCC8C4),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                    Text(
                      OLogisticsCalculator.formatFeeLocalized(product.price),
                      style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        color: OColors.primary,
                      ),
                    ),
                  ]),
                ],
              ),
            ),
            // Chevron
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: isDark ? Colors.white24 : const Color(0xFFCCC8C4),
            ),
          ],
        ),
      ),
    );
  }

  // ── Résultats ─────────────────────────────────────────────────────────────

  Widget _buildResults(String query, bool isDark) {
    return Obx(() {
      if (productController.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
              color: OColors.primary, strokeWidth: 1.5),
        );
      }

      final results = productController.featuredProducts.where((p) {
        final title = p.title.toLowerCase();
        final category = (p.categoryName ?? '').toLowerCase();
        final fabric = (p.fabric ?? '').toLowerCase();
        final tags = p.tags.join(' ').toLowerCase();
        return title.contains(query) ||
            category.contains(query) ||
            fabric.contains(query) ||
            tags.contains(query);
      }).toList();

      if (results.isEmpty) {
        return _buildEmptyState(query, isDark);
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
            child: Text(
              _isEn
                  ? '${results.length} result${results.length > 1 ? 's' : ''}'
                  : '${results.length} résultat${results.length > 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white38 : const Color(0xFFB0AAA2),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: results.length,
              separatorBuilder: (_, __) => const SizedBox(height: 7),
              itemBuilder: (_, i) => _productRow(results[i], isDark),
            ),
          ),
        ],
      );
    });
  }

  // ── État vide ─────────────────────────────────────────────────────────────

  Widget _buildEmptyState(String query, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : const Color(0xFFF0EDE8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Iconsax.search_status, size: 24,
                  color: isDark ? Colors.white24 : const Color(0xFFB0AAA2)),
            ),
            const SizedBox(height: 16),
            Text(
              _isEn
                  ? 'No results for "$query"'
                  : 'Aucun résultat pour\n« $query »',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600,
                color: isDark ? Colors.white54 : const Color(0xFF4A4542),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _isEn
                  ? 'Try one of these searches'
                  : 'Essayez l\'une de ces recherches',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white30 : const Color(0xFFB0AAA2),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8, runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _trending.take(4).map((term) =>
                GestureDetector(
                  onTap: () => _search(term),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : const Color(0xFFF4F1EC),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.07)
                            : const Color(0xFFE8E4DE),
                      ),
                    ),
                    child: Text(term,
                      style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500,
                        color: isDark
                            ? Colors.white54
                            : const Color(0xFF4A4542),
                      ),
                    ),
                  ),
                ),
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data ──────────────────────────────────────────────────────────────────────

class _DiscoverItem {
  const _DiscoverItem(this.label, this.icon);
  final String label;
  final IconData icon;
}
