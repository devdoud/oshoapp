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
import 'package:osho/features/shop/models/product_tag_model.dart';
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

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _refreshProduct();
  }

  Future<void> _refreshProduct() async {
    final fresh = await CatalogRepository.instance.getProductById(widget.product.id);
    if (fresh != null && mounted) {
      setState(() => _product = fresh);
    }
  }

  ProductModel get product => _product;

  @override
  Widget build(BuildContext context) {
    final isDark = OHelperFunctions.isDarkMode(context);
    final favoriteController = Get.put(FavouritesController());
    final cartController = Get.put(CartController());
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
                        _sectionTitle(context, "L'histoire du tissu"),
                        const SizedBox(height: 12),
                        Text(
                          product.description ??
                              "Ce modele unique allie tradition et modernite. Fabrique avec soin par nos artisans, il reflete l'elegance de la culture africaine.",
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
                          onPressed: () async {
                            if (Supabase.instance.client.auth.currentUser ==
                                null) {
                              _showLoginRequiredSheet(
                                context,
                                action: 'ajouter ce produit au panier',
                              );
                            } else {
                              await cartController.addItem(product);
                              OLoaders.successSnackBar(
                                title: 'Ajoute au panier',
                                message:
                                    '${product.title} a ete ajoute a votre panier.',
                              );
                            }
                          },
                          icon: const Icon(Icons.add_shopping_cart, size: 18),
                          label: const Text('Ajouter'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: isDark ? Colors.white70 : OColors.primary,
                                width: 1.4),
                            foregroundColor:
                                isDark ? Colors.white : OColors.primary,
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
                            if (Supabase.instance.client.auth.currentUser ==
                                null) {
                              _showLoginRequiredSheet(context);
                            } else {
                              _showEnhancedCustomizationSheet(context);
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
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Commander",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Iconsax.arrow_right_3, size: 17),
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
            'Collection Heritage',
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
                      OLogisticsCalculator.formatFee(product.price),
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
                  if (Get.locale?.languageCode == 'en' &&
                      product.priceUsd != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '\$${product.priceUsd!.toStringAsFixed(product.priceUsd! % 1 == 0 ? 0 : 2)} USD',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? Colors.white38
                            : const Color(0xFFB0AAA2),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Confection artisanale, ajustee a vos mesures.',
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
        label: 'Matiere',
        value: _cleanValue(product.fabric),
      ),
      _CraftDetail(
        icon: Iconsax.picture_frame,
        label: 'Modele',
        value: model,
      ),
      _CraftDetail(
        icon: Iconsax.magicpen,
        label: 'Broderie',
        value: _cleanValue(product.embroidery),
      ),
      _CraftDetail(
        icon: Iconsax.tick_circle,
        label: 'Finition',
        value: _cleanValue(product.accessory),
      ),
      if (product.estimatedDays != null && product.estimatedDays! > 0)
        _CraftDetail(
          icon: Iconsax.timer_1,
          label: 'Confection',
          value: '${product.estimatedDays} jours',
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
                    const Text(
                      'Details de confection',
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Matiere, modele et finitions definis pour ce produit.',
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

  String _tagLabel(String slug) {
    try {
      return ProductTagModel.defaults
          .firstWhere((t) => t.name == slug)
          .label;
    } catch (_) {
      return slug;
    }
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
    final stored = product.perfectFor ?? [];
    // Supabase values take priority; fallback = 3 defaults only
    final items = stored.isNotEmpty
        ? stored
        : (isEn ? _perfectForEnDefault : _perfectForFrDefault);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(context, isEn ? 'Perfect For' : 'Parfait pour'),
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

  void _showEnhancedCustomizationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _SizeSelectionSheet(product: product),
      ),
    );
  }
}

// ─── Size selection bottom sheet ──────────────────────────────────────────────

class _SizeSelectionSheet extends StatefulWidget {
  const _SizeSelectionSheet({required this.product});
  final ProductModel product;

  @override
  State<_SizeSelectionSheet> createState() => _SizeSelectionSheetState();
}

class _SizeSelectionSheetState extends State<_SizeSelectionSheet> {
  int _tab = 0;

  // Partner 1
  String _gender = 'femme';
  String? _topSize;
  String? _bottomSize;

  // Partner 2 (couple only)
  String _gender2 = 'homme';
  String? _topSize2;
  String? _bottomSize2;

  final _recipientCtrl = TextEditingController();

  bool get _isCouple {
    final p = widget.product;
    return [
      p.categoryType ?? '',
      p.categoryName ?? '',
      p.categorySlug ?? '',
      p.categoryStyle ?? '',
    ].any((f) => f.toLowerCase().contains('couple'));
  }

  static const _topSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
  static const _bottomSizes = ['30', '32', '34', '36', '38', '40', '42', '44', '46', '48'];

  @override
  void initState() {
    super.initState();
    if (_isCouple) {
      _gender = 'femme';
      _gender2 = 'homme';
    } else {
      final cat = (widget.product.categoryType ?? '').toLowerCase();
      if (cat.contains('homme')) _gender = 'homme';
    }
  }

  @override
  void dispose() {
    _recipientCtrl.dispose();
    super.dispose();
  }

  void _setupController() {
    final c = Get.put(CustomizationController());

    // Infos produit de base
    c.productId.value = widget.product.id;
    c.productName.value = widget.product.title;
    c.productImage.value = widget.product.thumbnail;
    c.basePrice.value = widget.product.price;
    c.estimatedDays.value = widget.product.estimatedDays ?? 0;

    final category = _isCouple
        ? 'couple'
        : (widget.product.categoryType ?? '').isNotEmpty
            ? widget.product.categoryType!.toLowerCase()
            : 'femme';

    // loadForProduct() garantit que hasBroderie/hasFinition sont définis
    // avant que fetchOptions() ne soit appelé (pas de problème de timing).
    c.loadForProduct(
      category: category,
      fabricTypeStr: (widget.product.fabric ?? '').toLowerCase().trim(),
      hasBroderieVal: widget.product.embroidery != null &&
          widget.product.embroidery!.trim().isNotEmpty,
      hasFinitionVal: widget.product.accessory != null &&
          widget.product.accessory!.trim().isNotEmpty,
      fabricOpts: widget.product.fabricOptions,
      embroideryOpts: widget.product.embroideryOptions,
      finishOpts: widget.product.finishOptions,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE8E4DE),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Informations de taille',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 4),
            Text(
              'Choisissez comment vous souhaitez définir votre taille.',
              style: TextStyle(fontSize: 12, color: Colors.grey[500], height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F1EC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(children: [
                _tabBtn('Sur Mesure', 0),
                _tabBtn('Taille Standard', 1),
              ]),
            ),
            const SizedBox(height: 18),
            _tab == 0 ? _buildSurMesureTab() : _buildStandardTab(),
          ],
        ),
      ),
    );
  }

  Widget _tabBtn(String label, int index) {
    final selected = _tab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: selected
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? const Color(0xFF1A1A1A) : Colors.grey[500],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSurMesureTab() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: OColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: OColors.primary.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: OColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Iconsax.magic_star, color: OColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mesures personnalisées', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    SizedBox(height: 2),
                    Text('Parfaitement ajusté à votre morphologie', style: TextStyle(fontSize: 11, color: Color(0xFF888480))),
                  ],
                ),
              ),
              const Icon(Iconsax.tick_circle, color: OColors.primary, size: 18),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _setupController();
              final c = CustomizationController.instance;
              c.standardTopSize.value = '';
              c.standardBottomSize.value = '';
              c.sizeRecipientName.value = '';
              c.standardTopSize2.value = '';
              c.standardBottomSize2.value = '';
              Get.to(() => CustomModelStep1(categoryType: c.categoryType.value));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: OColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Continuer', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          ),
        ),
      ],
    );
  }

  Widget _buildStandardTab() {
    final couple = _isCouple;
    final canConfirm = _topSize != null && _bottomSize != null &&
        (!couple || (_topSize2 != null && _bottomSize2 != null));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Partner 1 ──────────────────────────────────────────
        if (couple) _partnerLabel('Partenaire 1', '1'),
        if (couple) const SizedBox(height: 14),

        const Text('GENRE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: Color(0xFFB0AAA2))),
        const SizedBox(height: 8),
        _genderRow(_gender, (v) => setState(() { _gender = v; _topSize = null; _bottomSize = null; })),
        const SizedBox(height: 14),

        const Text('TAILLE HAUT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: Color(0xFFB0AAA2))),
        const SizedBox(height: 10),
        _sizeGrid(sizes: _topSizes, selected: _topSize, onTap: (v) => setState(() => _topSize = v)),
        const SizedBox(height: 14),

        const Text('TAILLE BAS — PANTALON', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: Color(0xFFB0AAA2))),
        const SizedBox(height: 10),
        _sizeGrid(sizes: _bottomSizes, selected: _bottomSize, onTap: (v) => setState(() => _bottomSize = v)),

        // ── "Pour qui?" — single only ───────────────────────────
        if (!couple) ...[
          const SizedBox(height: 14),
          const Text('POUR QUI ? (FACULTATIF)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: Color(0xFFB0AAA2))),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F6F3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEEEBE6)),
            ),
            child: TextField(
              controller: _recipientCtrl,
              style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A1A)),
              decoration: const InputDecoration(
                hintText: 'Ex: pour ma mère, pour un ami...',
                hintStyle: TextStyle(fontSize: 12, color: Color(0xFFD0CCC8)),
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: InputBorder.none,
              ),
            ),
          ),
        ],

        // ── Partner 2 ──────────────────────────────────────────
        if (couple) ...[
          const SizedBox(height: 22),
          Container(height: 1, color: const Color(0xFFEEEBE6)),
          const SizedBox(height: 22),

          _partnerLabel('Partenaire 2', '2'),
          const SizedBox(height: 14),

          const Text('GENRE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: Color(0xFFB0AAA2))),
          const SizedBox(height: 8),
          _genderRow(_gender2, (v) => setState(() { _gender2 = v; _topSize2 = null; _bottomSize2 = null; })),
          const SizedBox(height: 14),

          const Text('TAILLE HAUT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: Color(0xFFB0AAA2))),
          const SizedBox(height: 10),
          _sizeGrid(sizes: _topSizes, selected: _topSize2, onTap: (v) => setState(() => _topSize2 = v)),
          const SizedBox(height: 14),

          const Text('TAILLE BAS — PANTALON', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: Color(0xFFB0AAA2))),
          const SizedBox(height: 10),
          _sizeGrid(sizes: _bottomSizes, selected: _bottomSize2, onTap: (v) => setState(() => _bottomSize2 = v)),
        ],

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canConfirm
                ? () {
                    Navigator.pop(context);
                    _setupController();
                    final c = CustomizationController.instance;
                    c.standardTopSize.value = _topSize!;
                    c.standardBottomSize.value = _bottomSize!;
                    c.sizeRecipientName.value = couple ? '' : _recipientCtrl.text.trim();
                    if (couple) {
                      c.standardTopSize2.value = _topSize2!;
                      c.standardBottomSize2.value = _bottomSize2!;
                      c.sizeGender2.value = _gender2;
                    } else {
                      c.standardTopSize2.value = '';
                      c.standardBottomSize2.value = '';
                    }
                    Get.to(() => CustomModelStep1(categoryType: c.categoryType.value));
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: OColors.primary,
              disabledBackgroundColor: const Color(0xFFD0CCC8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Commander', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          ),
        ),
      ],
    );
  }

  Widget _partnerLabel(String label, String number) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(color: OColors.primary, shape: BoxShape.circle),
          child: Center(
            child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
      ],
    );
  }

  Widget _genderRow(String current, ValueChanged<String> onChange) {
    return Row(children: [
      _genderChip('Femme', 'femme', Iconsax.woman, current, onChange),
      const SizedBox(width: 10),
      _genderChip('Homme', 'homme', Iconsax.man, current, onChange),
    ]);
  }

  Widget _genderChip(String label, String value, IconData icon, String current, ValueChanged<String> onChange) {
    final selected = current == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChange(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selected ? OColors.primary.withValues(alpha: 0.08) : const Color(0xFFF8F6F3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? OColors.primary.withValues(alpha: 0.3) : const Color(0xFFEEEBE6),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: selected ? OColors.primary : Colors.grey),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? OColors.primary : const Color(0xFF4A4542),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sizeGrid({
    required List<String> sizes,
    required String? selected,
    required ValueChanged<String> onTap,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: sizes.map((s) {
        final isSelected = s == selected;
        return GestureDetector(
          onTap: () => onTap(s),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            decoration: BoxDecoration(
              color: isSelected
                  ? OColors.primary.withValues(alpha: 0.10)
                  : const Color(0xFFF4F1EC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? OColors.primary.withValues(alpha: 0.55)
                    : const Color(0xFFE4E0DA),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Text(
              s,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected
                    ? OColors.primary
                    : const Color(0xFF6B6560),
                letterSpacing: 0.2,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CraftDetail {
  const _CraftDetail({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}
