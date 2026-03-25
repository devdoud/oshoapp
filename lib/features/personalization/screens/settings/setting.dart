import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/common/widgets/list_tiles/settings_menu_tile.dart';
import 'package:osho/features/authentication/controllers/login/login_controller.dart';
import 'package:osho/features/authentication/screens/login/login.dart';
import 'package:osho/features/personalization/controllers/user_controller.dart';
import 'package:osho/features/personalization/screens/address/address.dart';
import 'package:osho/features/personalization/screens/profile/profile.dart';
import 'package:osho/features/personalization/screens/settings/widgets/user_profile.dart';
import 'package:osho/features/shop/screens/order/order.dart';
import 'package:osho/features/personalization/screens/profile/security_settings.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/features/shop/screens/wishlist/wishlist.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(LoginController());
    Get.put(UserController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Soft background
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Premium Header ---
            Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'nav_profile'.tr,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Iconsax.setting_2, color: Colors.black87),
                      )
                    ],
                   ),
                   const SizedBox(height: 30),
                   const OUserProfile(), 
                ],
              ),
            ),
      
            // --- Menu Sections ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("Compte"),
                  
                  _buildMenuTile(
                    icon: Iconsax.user, 
                    title: "Mes informations", 
                    subtitle: "Modifier votre profil",
                    onTap: () => Get.to(() => const ProfileScreen())
                  ),
                  _buildMenuTile(
                    icon: Iconsax.heart, 
                    title: "Mes favoris", 
                    subtitle: "Produits sauvegardés",
                    onTap: () => Get.to(() => const WishlistScreen())
                  ),
                  _buildMenuTile(
                    icon: Iconsax.box, 
                    title: "Mes commandes",
                    subtitle: "Historique et suivi", 
                    onTap: () => Get.to(() => const OrderScreen())
                  ),
                  _buildMenuTile(
                    icon: Iconsax.location, 
                    title: "Mes adresses", 
                    subtitle: "Livraison",
                    onTap: () => Get.to(() => const UserAddressScreen())
                  ),

                  const SizedBox(height: 24),
                  _buildSectionHeader("Sécurité & App"),

                  _buildMenuTile(
                    icon: Iconsax.shield_security, 
                    title: "Sécurité", 
                    subtitle: "Mot de passe et accès",
                    onTap: () => Get.to(() => const SecuritySettingsScreen()) // We'll create this
                  ),
                  _buildMenuTile(
                    icon: Iconsax.notification, 
                    title: "Notifications", 
                    subtitle: "Préférences",
                    onTap: () {} 
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => LoginController.instance.logout(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.red.withOpacity(0.05),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Iconsax.logout, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Se déconnecter", 
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.red, 
                              fontWeight: FontWeight.w600
                            )
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      "Version 1.0.0",
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.grey),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey[400],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: OColors.primary.withOpacity(0.06),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: OColors.primary, size: 20),
        ),
        title: Text(
          title, 
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87)
        ),
        subtitle: subtitle != null ? Text(
          subtitle,
          style: TextStyle(color: Colors.grey[400], fontSize: 12)
        ) : null,
        trailing: Icon(Iconsax.arrow_right_3, size: 16, color: Colors.grey[300]),
      ),
    );
  }
}
