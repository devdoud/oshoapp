import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/features/authentication/screens/login/login.dart';
import 'package:osho/features/measurement/screens/manual_measurement_entry.dart';
import 'package:osho/features/personalization/controllers/measurement_controller.dart';
import 'package:osho/features/personalization/models/measurement_profile_model.dart';
import 'package:osho/features/shop/controllers/cart_controller.dart';
import 'package:osho/features/shop/controllers/favourites_controller.dart';
import 'package:osho/features/shop/models/product_model.dart';
import 'package:osho/features/shop/models/product_tag_model.dart';
import 'package:osho/features/shop/screens/checkout/cart_checkout.dart';
import 'package:osho/features/shop/screens/home/widgets/product_detail_image_slide.dart';
import 'package:osho/data/repositories/shop/catalog_repository.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/helpers/helper_functions.dart';
import 'package:osho/utils/helpers/logistics_calculator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductDetail extends StatefulWidget {
  const ProductDetail({super.key, required this.product});

  final ProductModel product;

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  late ProductModel _product;
  List<ProductTagModel> _allTags = ProductTagModel.defaults;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _refreshProduct();
    _loadTags();
  }

  Future<void> _refreshProduct() async {
    final fresh = await CatalogRepository.instance.getProductById(widget.product.id);
    if (fresh != null && mounted) {
      setState(() => _product = fresh);
    }
  }

  Future<void> _loadTags() async {
    final tags = await CatalogRepository.instance.fetchPredefinedTags();
    if (mounted) setState(() => _allTags = tags);
  }

  ProductModel get product => _product;

  @override
  Widget build(BuildContext context) {
    final isDark = OHelperFunctions.isDarkMode(context);
    final favoriteController = Get.put(FavouritesController());
    Get.put(CartController());
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFDFBF7);
    final surfaceColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    // Configuration de la barre d'état pour la transparence totale
    final SystemUiOverlayStyle systemUiStyle = isDark
        ? SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent)
        : SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiStyle,
      child: Scaffold(
        backgroundColor: bgColor,
        body: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Image slider directement dans le scroll — PageView horizontal
                // n'a aucun conflit avec CustomScrollView vertical (Flutter disambigue)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 420,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        OProductDetailImageSlider(product: product),
                        Positioned.fill(
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.15),
                                    Colors.transparent,
                                    bgColor.withValues(alpha: 0.5),
                                  ],
                                  stops: const [0, 0.55, 1],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 14,
                          bottom: 14,
                          child: GestureDetector(
                            onTap: () => _showFullscreenImage(context, product),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    width: 1),
                              ),
                              child: const Icon(
                                Iconsax.maximize_3,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 112),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeroSummary(context, isDark, surfaceColor),
                        if (product.tags.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _buildProductTags(product.tags, isDark),
                        ],
                        const SizedBox(height: 20),
                        _buildCraftDetailsCard(context, isDark, surfaceColor),
                        const SizedBox(height: 24),
                        _sectionTitle(context, 'story_title'.tr),
                        const SizedBox(height: 12),
                        Text(
                          product.description ??
                              'fabric_story_default'.tr,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color:
                                    isDark ? Colors.white70 : Colors.grey[700],
                                height: 1.75,
                                fontSize: 14,
                              ),
                        ),
                        const SizedBox(height: 24),
                        _buildPerfectForSection(context, isDark),
                      ],
                    ),
                  ),
                )
              ],
            ),
            // --- Boutons nav (overlay, toujours visibles en haut)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _roundIconButton(
                        icon: Iconsax.arrow_left_2,
                        isDark: isDark,
                        onPressed: () => Get.back(),
                      ),
                      Obx(
                        () => _roundIconButton(
                          icon: favoriteController.isFavourite(product.id)
                              ? Iconsax.heart5
                              : Iconsax.heart,
                          iconColor:
                              favoriteController.isFavourite(product.id)
                                  ? Colors.red
                                  : Colors.grey,
                          isDark: isDark,
                          onPressed: () {
                            if (Supabase.instance.client.auth.currentUser ==
                                null) {
                              Get.to(() => const LoginScreen());
                            } else {
                              favoriteController
                                  .toggleFavoriteProduct(product.id);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 30,
                        offset: const Offset(0, -8),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            if (Supabase.instance.client.auth.currentUser == null) {
                              _showLoginRequiredSheet(context, action: 'ajouter ce produit au panier');
                            } else {
                              _showProfileSelectionSheet(context, action: 'cart');
                            }
                          },
                          icon: const Icon(Icons.add_shopping_cart, size: 18),
                          label: Text('add_to_cart_btn'.tr),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: isDark ? Colors.white70 : OColors.primary,
                                width: 1.4),
                            foregroundColor: isDark ? Colors.white : OColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
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
                              _showProfileSelectionSheet(context, action: 'order');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: OColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'order_btn'.tr,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Iconsax.arrow_right_3, size: 17),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSummary(
      BuildContext context, bool isDark, Color surfaceColor) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'collection_heritage'.tr,
            style: TextStyle(
              color: OColors.primary.withValues(alpha: isDark ? 0.9 : 0.65),
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontFamily: 'DMSans',
                  fontSize: 25,
                  height: 1.15,
                  color: isDark ? Colors.white : const Color(0xFF242424),
                ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.10)
                          : OColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      OLogisticsCalculator.formatFeeLocalized(product.price),
                      style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: isDark
                                    ? Colors.white
                                    : OColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'artisanal_craft_note'.tr,
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.grey[600],
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCraftDetailsCard(
      BuildContext context, bool isDark, Color surfaceColor) {
    final model = _firstAvailable([
      product.categoryStyle,
      product.categoryName,
      product.categoryType,
      product.title,
    ]);
    final details = [
      _CraftDetail(
        icon: Iconsax.shapes,
        label: 'material'.tr,
        value: _cleanValue(product.fabric),
      ),
      _CraftDetail(
        icon: Iconsax.picture_frame,
        label: 'model_label'.tr,
        value: model,
      ),
      _CraftDetail(
        icon: Iconsax.magicpen,
        label: 'embroidery'.tr,
        value: _cleanValue(product.embroidery),
      ),
      _CraftDetail(
        icon: Iconsax.tick_circle,
        label: 'finishing_label'.tr,
        value: _cleanValue(product.accessory),
      ),
      if (product.estimatedDays != null && product.estimatedDays! > 0)
        _CraftDetail(
          icon: Iconsax.timer_1,
          label: 'crafting_time_label'.tr,
          value: 'days_value'.trParams({'count': '${product.estimatedDays}'}),
        ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : OColors.primary.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Iconsax.category,
                    color: isDark ? Colors.white : OColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'craft_title'.tr,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'craft_subtitle'.tr,
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 10) / 2;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: details
                    .map((detail) => SizedBox(
                          width: itemWidth,
                          child: _buildCraftDetailTile(detail, isDark),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCraftDetailTile(_CraftDetail detail, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : OColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(detail.icon,
              size: 16, color: isDark ? Colors.white70 : OColors.primary),
          const SizedBox(height: 8),
          Text(
            detail.label,
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.grey[600],
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            detail.value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF242424),
              fontSize: 13,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductTags(List<String> tags, bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((slug) {
        final label = _tagLabel(slug);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: OColors.primary,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Normalise (minuscules, sans accents) pour matcher des tags legacy
  /// enregistrés avec des variantes ("Nouveauté", "CÉRÉMONIE", "nouveaute"...).
  String _normalizeTagKey(String s) {
    const accents = {
      'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
      'à': 'a', 'â': 'a', 'ä': 'a',
      'î': 'i', 'ï': 'i',
      'ô': 'o', 'ö': 'o',
      'ù': 'u', 'û': 'u', 'ü': 'u',
      'ç': 'c',
    };
    var result = s.toLowerCase().trim();
    accents.forEach((k, v) => result = result.replaceAll(k, v));
    return result;
  }

  String _tagLabel(String slug) {
    final langCode = Get.locale?.languageCode == 'en' ? 'en' : 'fr';
    final key = _normalizeTagKey(slug);
    for (final list in [_allTags, ProductTagModel.defaults]) {
      for (final t in list) {
        if (_normalizeTagKey(t.name) == key ||
            _normalizeTagKey(t.label) == key ||
            (t.labelEn != null && _normalizeTagKey(t.labelEn!) == key)) {
          return t.labelFor(langCode);
        }
      }
    }
    return slug;
  }

  void _showFullscreenImage(BuildContext context, ProductModel product) {
    // Même logique de déduplication que le slider
    final seen = <String>{};
    final images = <String>[];
    for (final url in [
      product.thumbnail,
      ...?product.images,
    ]) {
      final clean = url.trim();
      if (clean.isNotEmpty && seen.add(clean)) images.add(clean);
    }
    if (images.isEmpty) return;

    final pageController = PageController();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'close',
      barrierColor: Colors.black.withValues(alpha: 0.92),
      transitionDuration: const Duration(milliseconds: 220),
      transitionBuilder: (ctx, anim, _, child) => FadeTransition(
        opacity: anim,
        child: child,
      ),
      pageBuilder: (ctx, _, __) => SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: pageController,
              itemCount: images.length,
              itemBuilder: (ctx, i) => InteractiveViewer(
                minScale: 0.8,
                maxScale: 4.0,
                child: Center(
                  child: Image.network(
                    images[i],
                    fit: BoxFit.contain,
                    loadingBuilder: (ctx, child, progress) => progress == null
                        ? child
                        : const Center(
                            child: CircularProgressIndicator(
                                color: Colors.white54, strokeWidth: 1.5)),
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image, color: Colors.white38, size: 64),
                  ),
                ),
              ),
            ),
            // Bouton fermer
            Positioned(
              top: 12,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.of(ctx).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2), width: 1),
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ),
            // Indicateur de pages
            if (images.length > 1)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    images.length,
                    (i) => AnimatedBuilder(
                      animation: pageController,
                      builder: (_, __) {
                        final page = pageController.hasClients
                            ? (pageController.page ?? 0).round()
                            : 0;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: i == page ? 16 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: i == page
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 17,
          ),
    );
  }

  Widget _roundIconButton({
    required IconData icon,
    required bool isDark,
    required VoidCallback onPressed,
    Color? iconColor,
  }) {
    return IconButton(
      onPressed: onPressed,
      color: iconColor ?? (isDark ? Colors.white : Colors.black),
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? Colors.black54 : Colors.white.withValues(alpha: 0.92),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Icon(icon, size: 22),
      ),
    );
  }

  // ── "Perfect For" defaults ──────────────────────────────────────────────────

  static const _perfectForEnDefault = [
    'Wedding guest outfit',
    'Traditional ceremonies',
    'Luxury African fashion lovers',
  ];

  static const _perfectForFrDefault = [
    'Tenue de mariage',
    'Cérémonies traditionnelles',
    'Amateurs de mode africaine de luxe',
  ];

  Widget _buildPerfectForSection(BuildContext context, bool isDark) {
    final isEn = Get.locale?.languageCode == 'en';
    final langCode = isEn ? 'en' : 'fr';
    final stored = product.perfectFor ?? [];
    // Supabase values (bilingues) take priority; fallback = 3 defaults only
    final items = stored.isNotEmpty
        ? stored.map((p) => p.forLocale(langCode)).toList()
        : (isEn ? _perfectForEnDefault : _perfectForFrDefault);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(context, 'perfect_for'.tr),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFEEEBE6),
            ),
          ),
          child: Column(
            children: items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.diamond_outlined,
                            size: 13,
                            color: isDark
                                ? Colors.white38
                                : OColors.primary
                                    .withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF4A4542),
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  String _cleanValue(String? value) {
    final cleaned = value?.trim();
    if (cleaned == null || cleaned.isEmpty) return 'A preciser';
    return cleaned;
  }

  String _firstAvailable(List<String?> values) {
    for (final value in values) {
      final cleaned = value?.trim();
      if (cleaned != null && cleaned.isNotEmpty) return cleaned;
    }
    return 'A preciser';
  }

  void _showProfileSelectionSheet(BuildContext context, {required String action}) {
    Get.put(MeasurementController());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _ProfileSelectionSheet(product: product, action: action),
      ),
    );
  }

  void _showLoginRequiredSheet(
    BuildContext context, {
    String action = 'commander',
  }) {
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
              'Vous devez etre connecte pour $action.',
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
                child: const Text(
                  'Se connecter',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Plus tard', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

}

// ─── Profile selection bottom sheet ──────────────────────────────────────────

class _ProfileSelectionSheet extends StatefulWidget {
  const _ProfileSelectionSheet({required this.product, required this.action});
  final ProductModel product;
  final String action; // 'cart' | 'order'

  @override
  State<_ProfileSelectionSheet> createState() => _ProfileSelectionSheetState();
}

class _ProfileSelectionSheetState extends State<_ProfileSelectionSheet> {
  bool _forSelf = true;
  MeasurementProfileModel? _selectedProfile;
  MeasurementProfileModel? _selectedProfile2;
  bool _isLoading = false;

  MeasurementController get _mc => MeasurementController.instance;

  bool get _isCouple => widget.product.isCouple;

  @override
  void initState() {
    super.initState();
    final profiles = _mc.userMeasurements;
    final primary = profiles.firstWhereOrNull((p) => p.isPrimary);
    _selectedProfile = primary ?? (profiles.isNotEmpty ? profiles.first : null);
  }

  Future<void> _confirm() async {
    if (_selectedProfile == null) return;
    if (_isCouple && _selectedProfile2 == null) return;
    setState(() => _isLoading = true);

    _mc.selectedProfile.value = _selectedProfile;
    _mc.selectedProfile2.value = _isCouple ? _selectedProfile2 : null;

    final cartCtrl = CartController.instance;
    await cartCtrl.addItem(widget.product);

    if (!mounted) return;
    Navigator.pop(context);

    if (widget.action == 'order') {
      Get.to(() => const CartCheckoutScreen());
    } else {
      OLoaders.successSnackBar(
        title: 'Ajouté au panier',
        message: '${widget.product.title} a été ajouté à votre panier.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = OHelperFunctions.isDarkMode(context);
    final bg = isDark ? const Color(0xFF1A1A1A) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: SingleChildScrollView(
        child: Obx(() {
          final profiles = _mc.userMeasurements;
          if (_selectedProfile == null && profiles.isNotEmpty) {
            _selectedProfile =
                profiles.firstWhereOrNull((p) => p.isPrimary) ?? profiles.first;
          }
          final selfProfile =
              profiles.firstWhereOrNull((p) => p.isPrimary) ??
                  (profiles.isNotEmpty ? profiles.first : null);
          // "Quelqu'un d'autre" ne doit jamais proposer le profil principal
          // de l'utilisateur : on ne montre que les profils créés pour d'autres.
          final otherProfiles =
              profiles.where((p) => p.id != selfProfile?.id).toList();
          final displayProfiles = _forSelf ? profiles : otherProfiles;
          return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : const Color(0xFFE8E4DE),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Pour qui commandez-vous ?',
              style: TextStyle(
                fontSize: 17, fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Sélectionnez le profil de mesure pour la confection.',
              style: TextStyle(
                fontSize: 12, height: 1.4,
                color: isDark ? Colors.white54 : Colors.grey[500],
              ),
            ),
            const SizedBox(height: 18),

            // ── Choix Pour moi / Quelqu'un d'autre ────────────────
            Row(children: [
              _choiceCard(
                icon: Iconsax.user, label: 'Pour moi',
                selected: _forSelf, isDark: isDark,
                onTap: () => setState(() {
                  _forSelf = true;
                  final primary = profiles.firstWhereOrNull((p) => p.isPrimary);
                  _selectedProfile = primary ?? (profiles.isNotEmpty ? profiles.first : null);
                }),
              ),
              const SizedBox(width: 10),
              _choiceCard(
                icon: Iconsax.profile_2user, label: "Quelqu'un d'autre",
                selected: !_forSelf, isDark: isDark,
                onTap: () => setState(() {
                  _forSelf = false;
                  _selectedProfile =
                      otherProfiles.isNotEmpty ? otherProfiles.first : null;
                }),
              ),
            ]),
            const SizedBox(height: 20),

            // ── Liste des profils ──────────────────────────────────
            if (displayProfiles.isEmpty)
              _forSelf
                  ? _buildEmptyState(isDark)
                  : _buildEmptyOtherState(isDark)
            else ...[
              Text(
                _forSelf ? 'MON PROFIL' : 'CHOISIR UN PROFIL',
                style: const TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700,
                  letterSpacing: 1.2, color: Color(0xFFB0AAA2),
                ),
              ),
              const SizedBox(height: 10),
              ...displayProfiles.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _profileTile(p, isDark),
              )),
            ],

            // ── Créer nouveau profil (seulement "quelqu'un d'autre") ──
            if (!_forSelf && displayProfiles.isNotEmpty) ...[
              const SizedBox(height: 4),
              _createProfileBtn(isDark),
            ],

            // ── Article couple : second profil (partenaire) ────────
            if (_isCouple && profiles.isNotEmpty) ...[
              const SizedBox(height: 24),
              Container(height: 1, color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFEEEBE6)),
              const SizedBox(height: 20),
              Text(
                'couple_second_profile_title'.tr,
                style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'couple_second_profile_sub'.tr,
                style: TextStyle(
                  fontSize: 11, height: 1.4,
                  color: isDark ? Colors.white54 : Colors.grey[500],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'partner_2'.tr.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700,
                  letterSpacing: 1.2, color: Color(0xFFB0AAA2),
                ),
              ),
              const SizedBox(height: 10),
              ...profiles.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _profileTile(p, isDark, slot: 2),
              )),
              const SizedBox(height: 4),
              _createProfileBtn(isDark),
            ],

            const SizedBox(height: 20),

            // ── Bouton confirmer ───────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_selectedProfile != null &&
                        (!_isCouple || _selectedProfile2 != null) &&
                        !_isLoading)
                    ? _confirm
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: OColors.primary,
                  disabledBackgroundColor: isDark ? Colors.white12 : const Color(0xFFD0CCC8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        widget.action == 'order' ? 'order_btn'.tr : 'add_to_cart'.tr,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
              ),
            ),
          ],
          );
        }),
      ),
    );
  }

  Widget _choiceCard({
    required IconData icon, required String label,
    required bool selected, required bool isDark, required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
          decoration: BoxDecoration(
            color: selected
                ? OColors.primary.withValues(alpha: 0.08)
                : (isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8F6F3)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? OColors.primary.withValues(alpha: 0.40)
                  : (isDark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFEEEBE6)),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(children: [
            Icon(icon, size: 15,
                color: selected ? OColors.primary : (isDark ? Colors.white54 : Colors.grey)),
            const SizedBox(width: 7),
            Expanded(
              child: Text(label,
                style: TextStyle(
                  fontSize: 12, fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? OColors.primary : (isDark ? Colors.white70 : const Color(0xFF4A4542)),
                ),
              ),
            ),
            if (selected)
              Container(
                width: 16, height: 16,
                decoration: const BoxDecoration(color: OColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 10),
              ),
          ]),
        ),
      ),
    );
  }

  Widget _profileTile(MeasurementProfileModel profile, bool isDark, {int slot = 1}) {
    final current = slot == 2 ? _selectedProfile2 : _selectedProfile;
    final isSelected = current?.id == profile.id ||
        (current?.id == null && current?.profileName == profile.profileName);
    return GestureDetector(
      onTap: () => setState(() {
        if (slot == 2) {
          _selectedProfile2 = profile;
        } else {
          _selectedProfile = profile;
        }
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? OColors.primary.withValues(alpha: 0.07)
              : (isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8F6F3)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? OColors.primary.withValues(alpha: 0.35)
                : (isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFEEEBE6)),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: isSelected
                  ? OColors.primary.withValues(alpha: 0.12)
                  : (isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF0EDE8)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              profile.gender == 'homme' ? Iconsax.man : Iconsax.woman,
              size: 18,
              color: isSelected ? OColors.primary : (isDark ? Colors.white54 : const Color(0xFF888480)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(
                  child: Text(profile.profileName,
                    style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                if (profile.isPrimary) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: OColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Principal',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: OColors.primary),
                    ),
                  ),
                ],
              ]),
              const SizedBox(height: 2),
              Text(_profileSummary(profile),
                style: TextStyle(fontSize: 11,
                  color: isDark ? Colors.white38 : const Color(0xFFB0AAA2)),
              ),
            ]),
          ),
          if (isSelected)
            Container(
              width: 20, height: 20,
              decoration: const BoxDecoration(color: OColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.check, color: Colors.white, size: 12),
            ),
        ]),
      ),
    );
  }

  String _profileSummary(MeasurementProfileModel p) {
    final parts = <String>[];
    if (p.chest != null) parts.add('P: ${p.chest!.toStringAsFixed(0)}cm');
    if (p.waist != null) parts.add('T: ${p.waist!.toStringAsFixed(0)}cm');
    if (p.hips != null) parts.add('H: ${p.hips!.toStringAsFixed(0)}cm');
    return parts.isEmpty ? (p.gender == 'homme' ? 'Homme' : 'Femme') : parts.join(' · ');
  }

  Widget _createProfileBtn(bool isDark) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        await Get.to(() => const ManualMeasurementEntryScreen());
        await _mc.fetchUserMeasurements();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: OColors.primary.withValues(alpha: 0.25), width: 1.5),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: OColors.primary.withValues(alpha: 0.10), shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.add, size: 12, color: OColors.primary),
          ),
          const SizedBox(width: 8),
          const Text('Créer un nouveau profil',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: OColors.primary),
          ),
        ]),
      ),
    );
  }

  Widget _buildEmptyOtherState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8F6F3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFEEEBE6),
        ),
      ),
      child: Column(children: [
        Icon(Iconsax.profile_2user, size: 32, color: isDark ? Colors.white38 : Colors.grey[400]),
        const SizedBox(height: 10),
        Text("Aucun profil pour quelqu'un d'autre",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
        ),
        const SizedBox(height: 6),
        Text(
          'Créez un profil de mesure pour la personne destinataire de la commande.',
          style: TextStyle(fontSize: 12, height: 1.4,
            color: isDark ? Colors.white54 : Colors.grey[500]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: _createProfileBtn(isDark),
        ),
      ]),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8F6F3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFEEEBE6),
        ),
      ),
      child: Column(children: [
        Icon(Iconsax.ruler, size: 32, color: isDark ? Colors.white38 : Colors.grey[400]),
        const SizedBox(height: 10),
        Text('Aucun profil de mesure',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
        ),
        const SizedBox(height: 6),
        Text(
          'Créez un profil pour que le tailleur confectionne votre tenue sur mesure.',
          style: TextStyle(fontSize: 12, height: 1.4,
            color: isDark ? Colors.white54 : Colors.grey[500]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await Get.to(() => const ManualMeasurementEntryScreen());
              await _mc.fetchUserMeasurements();
            },
            icon: const Icon(Iconsax.ruler, size: 15),
            label: const Text('Créer mon profil'),
            style: ElevatedButton.styleFrom(
              backgroundColor: OColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ]),
    );
  }
}

class _CraftDetail {
  const _CraftDetail({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;
}
