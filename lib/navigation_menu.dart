import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/features/measurement/screens/body_pose.dart';
import 'package:osho/features/measurement/screens/measurement_wrapper.dart';
import 'package:osho/features/measurement/screens/onboarding/measurement_onboarding.dart';
import 'package:osho/features/personalization/screens/settings/setting.dart';
import 'package:osho/features/personalization/screens/support/support_chat.dart';
import 'package:osho/features/shop/controllers/cart_controller.dart';
import 'package:osho/features/shop/screens/home/home.dart';
import 'package:osho/features/shop/screens/store/store.dart';
import 'package:osho/features/shop/screens/wishlist/wishlist.dart';
import 'package:osho/utils/constants/colors.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    final cartController = Get.put(CartController());

    return Scaffold(
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: 70,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          backgroundColor: Colors.white,
          indicatorColor: OColors.primary.withOpacity(0.1),
          // labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          onDestinationSelected: (index) => controller.selectedIndex.value = index,
          destinations: [
            NavigationDestination(
              icon: const Icon(Iconsax.home), 
              selectedIcon: const Icon(Iconsax.home5, color: OColors.primary),
              label: 'nav_home'.tr
            ),
            NavigationDestination(
              icon: _buildCartIcon(cartController, selected: false),
              selectedIcon: _buildCartIcon(cartController, selected: true),
              label: 'nav_cart'.tr
            ),
            NavigationDestination(
              icon: const Icon(Iconsax.heart), 
              selectedIcon: const Icon(Iconsax.heart5, color: OColors.primary),
              label: 'nav_favorites'.tr
            ),
            NavigationDestination(
              icon: const Icon(Iconsax.scan), 
              selectedIcon: const Icon(Iconsax.scan5, color: OColors.primary),
              label: 'nav_measurements'.tr
            ),
            NavigationDestination(
              icon: const Icon(Iconsax.message), 
              selectedIcon: const Icon(Iconsax.message5, color: OColors.primary),
              label: 'nav_support'.tr
            ),
            NavigationDestination(
              icon: const Icon(Iconsax.user), 
              selectedIcon: const Icon(Iconsax.user, color: Colors.black),
              label: 'nav_profile'.tr
            ),
          ],
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }

  Widget _buildCartIcon(CartController cartController, {required bool selected}) {
    return Obx(() {
      final count = cartController.totalItems;
      final label = count > 99 ? '99+' : count.toString();
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            Iconsax.shopping_bag,
            color: selected ? OColors.primary : OColors.textprimary,
          ),
          if (count > 0)
            Positioned(
              right: -6,
              top: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                decoration: const BoxDecoration(
                  color: OColors.primary,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Text(
                  label,
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
    });
  }

}

class NavigationController extends GetxController{
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    const HomeScreen(), 
    const StoreScreen(),
    const WishlistScreen(),
    const MeasurementWrapper(), // 4. Measurement
    const SupportChatScreen(), // 5. Support
    const SettingsScreen(), // 6. Profile
  ];
}
