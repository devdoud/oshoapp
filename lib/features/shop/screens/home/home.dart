import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/common/widgets/loaders/skeleton.dart';
import 'package:osho/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:osho/features/shop/controllers/category_controller.dart';
import 'package:osho/features/shop/controllers/product_controller.dart';
import 'package:osho/features/shop/controllers/cart_controller.dart';
import 'package:osho/features/shop/screens/search/search.dart';
import 'package:osho/features/shop/screens/store/store.dart';
import 'package:osho/features/personalization/controllers/user_controller.dart';
import 'package:osho/features/personalization/models/user_model.dart';
import 'package:osho/features/personalization/screens/settings/setting.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/constants/image_strings.dart';
import 'package:osho/utils/helpers/helper_functions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final productController = Get.put(ProductController());
  final categoryController = Get.put(CategoryController());
  final cartController = Get.put(CartController());
  final userController = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    final isDark = OHelperFunctions.isDarkMode(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light
              .copyWith(statusBarColor: Colors.transparent)
          : SystemUiOverlayStyle.dark
              .copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF111111) : const Color(0xFFF8F6F3),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 1. Header ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E1E1E)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : const Color(0xFFEEEBE6),
                          ),
                        ),
                        child: Image(
                          image: const AssetImage(OImages.logo),
                          width: 80,
                          height: 26,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Row(
                        children: [
                          _iconBtn(
                            icon: Iconsax.refresh,
                            isDark: isDark,
                            onTap: () {
                              categoryController.fetchCategories();
                              productController.fetchAllProducts();
                            },
                          ),
                          const SizedBox(width: 6),
                          Obx(() {
                            final count = cartController.totalItems;
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                _iconBtn(
                                  icon: Iconsax.shopping_bag,
                                  isDark: isDark,
                                  onTap: () =>
                                      Get.to(() => const StoreScreen()),
                                ),
                                if (count > 0)
                                  Positioned(
                                    right: -3,
                                    top: -3,
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      constraints: const BoxConstraints(
                                          minWidth: 16, minHeight: 16),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Colors.white
                                            : OColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        count.toString(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: isDark
                                              ? const Color(0xFF1A1A1A)
                                              : Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          }),
                          const SizedBox(width: 6),
                          Obx(() {
                            final user = userController.user.value;
                            final isLoggedIn = user.email.isNotEmpty;
                            return GestureDetector(
                              onTap: () => Get.to(() => const SettingsScreen()),
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: isLoggedIn
                                      ? (isDark
                                          ? Colors.white.withValues(alpha: 0.10)
                                          : OColors.primary.withValues(alpha: 0.08))
                                      : (isDark
                                          ? const Color(0xFF1E1E1E)
                                          : Colors.white),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isLoggedIn
                                        ? (isDark
                                            ? Colors.white.withValues(alpha: 0.20)
                                            : OColors.primary.withValues(alpha: 0.25))
                                        : (isDark
                                            ? Colors.white.withValues(alpha: 0.08)
                                            : const Color(0xFFEEEBE6)),
                                  ),
                                ),
                                child: isLoggedIn
                                    ? _buildUserAvatar(user, isDark)
                                    : Icon(
                                        Iconsax.user,
                                        size: 18,
                                        color: isDark
                                            ? Colors.white70
                                            : const Color(0xFF4A4542),
                                      ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── 2. Greeting ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
                  child: Text.rich(
                    TextSpan(
                      text: 'home_title_1'.tr,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        fontFamily: 'DMSans',
                      ),
                      children: [
                        TextSpan(
                          text: 'home_title_2'.tr,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white60
                                : OColors.primary,
                            fontSize: 26,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'DMSans',
                          ),
                        ),
                        TextSpan(
                          text: 'home_title_3'.tr,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1A1A1A),
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'DMSans',
                          ),
                        ),
                        TextSpan(
                          text: 'home_title_4'.tr,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white60
                                : OColors.primary,
                            fontSize: 26,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'DMSans',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── 3. Search ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: GestureDetector(
                    onTap: () => Get.to(() => const SearchScreen()),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E1E1E)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : const Color(0xFFEEEBE6),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          Icon(
                            Iconsax.search_normal,
                            size: 17,
                            color: isDark
                                ? Colors.white38
                                : const Color(0xFFB0AAA2),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'search_hint'.tr,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.white38
                                  : const Color(0xFFB0AAA2),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── 4. Categories ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'categories'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1A1A1A),
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      Text(
                        'view_all'.tr,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.white54
                              : OColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                Obx(() {
                  if (categoryController.isLoading.value) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: List.generate(
                          5,
                          (_) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: OSkeleton(
                                height: 34, width: 80, radius: 30),
                          ),
                        ),
                      ),
                    );
                  }
                  if (categoryController.featuredCategories.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  final categories =
                      categoryController.featuredCategories;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children:
                          List.generate(categories.length, (index) {
                        return Obx(() {
                          final isSelected = categoryController
                                  .selectedCategoryIndex.value ==
                              index;
                          return GestureDetector(
                            onTap: () =>
                                categoryController.selectCategory(index),
                            child: AnimatedContainer(
                              duration:
                                  const Duration(milliseconds: 250),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark
                                        ? Colors.white
                                        : OColors.primary)
                                    : (isDark
                                        ? const Color(0xFF1E1E1E)
                                        : Colors.white),
                                borderRadius:
                                    BorderRadius.circular(30),
                                border: Border.all(
                                  color: isSelected
                                      ? (isDark
                                          ? Colors.white
                                          : OColors.primary)
                                      : (isDark
                                          ? Colors.white
                                              .withValues(alpha: 0.10)
                                          : const Color(0xFFE8E4DE)),
                                ),
                              ),
                              child: Text(
                                categories[index].name,
                                style: TextStyle(
                                  color: isSelected
                                      ? (isDark
                                          ? const Color(0xFF1A1A1A)
                                          : Colors.white)
                                      : (isDark
                                          ? Colors.white60
                                          : const Color(0xFF4A4542)),
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        });
                      }),
                    ),
                  );
                }),
                const SizedBox(height: 20),

                // ── 5. Products ────────────────────────────────────────────
                Obx(() {
                  if (productController.isLoading.value) {
                    return Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        itemCount: 4,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.68,
                        ),
                        itemBuilder: (_, __) => const OSkeleton(
                            height: 220, width: 170, radius: 20),
                      ),
                    );
                  }
                  if (productController.featuredProducts.isEmpty) {
                    return Center(
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          'Aucun produit disponible',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white38
                                : Colors.grey[400],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      itemCount:
                          productController.featuredProducts.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.68,
                      ),
                      itemBuilder: (_, index) => OProductCardVertical(
                        product:
                            productController.featuredProducts[index],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar(UserModel user, bool isDark) {
    if (user.profilePicture.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          user.profilePicture,
          width: 38,
          height: 38,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _avatarInitials(user, isDark),
        ),
      );
    }
    return _avatarInitials(user, isDark);
  }

  Widget _avatarInitials(UserModel user, bool isDark) {
    final name = user.fullName.trim();
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    final initials = parts.isEmpty
        ? ''
        : parts.length == 1
            ? parts[0][0].toUpperCase()
            : '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return Center(
      child: initials.isNotEmpty
          ? Text(
              initials,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : OColors.primary,
              ),
            )
          : Icon(
              Iconsax.user,
              size: 16,
              color: isDark ? Colors.white70 : OColors.primary,
            ),
    );
  }

  Widget _iconBtn({
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFEEEBE6),
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isDark ? Colors.white70 : const Color(0xFF4A4542),
        ),
      ),
    );
  }
}
