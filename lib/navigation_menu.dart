import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/common/widgets/loaders/loader.dart';
import 'package:osho/data/repositories/authentication/authentication_repository.dart';
import 'package:osho/features/authentication/screens/login/login.dart';
import 'package:osho/features/measurement/screens/measurement_wrapper.dart';
import 'package:osho/features/personalization/screens/settings/setting.dart';
import 'package:osho/features/shop/controllers/cart_controller.dart';
import 'package:osho/features/shop/screens/home/home.dart';
import 'package:osho/features/shop/screens/store/store.dart';
import 'package:osho/features/shop/screens/wishlist/wishlist.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/helpers/helper_functions.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    final cartController = Get.put(CartController());
    final isDark = OHelperFunctions.isDarkMode(context);

    final selectedColor = isDark ? Colors.white : OColors.primary;
    final unselectedColor =
        isDark ? Colors.white54 : const Color(0xFF888480);

    return Scaffold(
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: 70,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          backgroundColor:
              isDark ? const Color(0xFF1A1A1A) : Colors.white,
          indicatorColor: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : OColors.primary.withValues(alpha: 0.10),
          onDestinationSelected: (index) {
            final isGuest =
                AuthenticationRepository.instance.authUser == null;
            if ((index == 1 || index == 2) && isGuest) {
              OLoaders.warningSnackBar(
                title: 'Connexion requise',
                message:
                    'Veuillez vous connecter pour accéder à cette section.',
              );
              Get.to(() => const LoginScreen());
            } else if ((index == 3 || index == 4) && isGuest) {
              _showLoginSheet(isDark);
            } else {
              controller.selectedIndex.value = index;
            }
          },
          destinations: [
            NavigationDestination(
              icon: Icon(Iconsax.home, color: unselectedColor),
              selectedIcon: Icon(Iconsax.home5, color: selectedColor),
              label: 'nav_home'.tr,
            ),
            NavigationDestination(
              icon: _buildCartIcon(cartController,
                  selected: false, isDark: isDark),
              selectedIcon: _buildCartIcon(cartController,
                  selected: true, isDark: isDark),
              label: 'nav_cart'.tr,
            ),
            NavigationDestination(
              icon: Icon(Iconsax.heart, color: unselectedColor),
              selectedIcon: Icon(Iconsax.heart5, color: selectedColor),
              label: 'nav_favorites'.tr,
            ),
            NavigationDestination(
              icon: Icon(Iconsax.scan, color: unselectedColor),
              selectedIcon: Icon(Iconsax.scan5, color: selectedColor),
              label: 'nav_measurements'.tr,
            ),
            NavigationDestination(
              icon: Icon(Iconsax.user, color: unselectedColor),
              selectedIcon: Icon(Iconsax.user, color: selectedColor),
              label: 'nav_profile'.tr,
            ),
          ],
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }

  void _showLoginSheet(bool isDark) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : const Color(0xFFE8E4DE),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : OColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.lock,
                color: isDark ? Colors.white : OColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Connexion requise',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Connectez-vous pour accéder à cette section et profiter d\'une expérience 100% sur mesure.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? Colors.white54
                      : const Color(0xFF888480),
                  height: 1.55,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () {
                Get.back();
                Get.to(() => const LoginScreen());
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white : OColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    'Se connecter',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? const Color(0xFF1A1A1A)
                          : Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : const Color(0xFFF8F6F3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.09)
                        : const Color(0xFFEEEBE6),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Annuler',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? Colors.white70
                          : const Color(0xFF4A4542),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  Widget _buildCartIcon(
    CartController cartController, {
    required bool selected,
    required bool isDark,
  }) {
    return Obx(() {
      final count = cartController.totalItems;
      final label = count > 99 ? '99+' : count.toString();
      final iconColor = selected
          ? (isDark ? Colors.white : OColors.primary)
          : (isDark ? Colors.white54 : const Color(0xFF888480));

      return Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(Iconsax.shopping_bag, color: iconColor),
          if (count > 0)
            Positioned(
              right: -6,
              top: -6,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                constraints:
                    const BoxConstraints(minWidth: 16, minHeight: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white : OColors.primary,
                  borderRadius:
                      const BorderRadius.all(Radius.circular(10)),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    const HomeScreen(),
    const StoreScreen(),
    const WishlistScreen(),
    const MeasurementWrapper(),
    const SettingsScreen(),
  ];
}
