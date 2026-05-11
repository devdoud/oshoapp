import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:osho/features/authentication/controllers/login/login_controller.dart';
import 'package:osho/features/authentication/screens/login/login.dart';
import 'package:osho/features/personalization/controllers/user_controller.dart';
import 'package:osho/features/personalization/screens/address/address.dart';
import 'package:osho/features/personalization/screens/notifications/notifications_screen.dart';
import 'package:osho/features/personalization/screens/profile/profile.dart';
import 'package:osho/features/personalization/screens/profile/security_settings.dart';
import 'package:osho/features/shop/screens/order/order.dart';
import 'package:osho/features/shop/screens/wishlist/wishlist.dart';
import 'package:osho/utils/constants/colors.dart';
import 'package:osho/utils/helpers/helper_functions.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(LoginController());
    final userController = Get.put(UserController());
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
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(userController, isDark),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Compte'),
                    const SizedBox(height: 10),
                    _tile(
                      isDark: isDark,
                      icon: Iconsax.user_edit,
                      title: 'Mes informations',
                      subtitle: 'Modifier votre profil',
                      onTap: () => Get.to(() => const ProfileScreen()),
                    ),
                    _tile(
                      isDark: isDark,
                      icon: Iconsax.heart,
                      title: 'Mes favoris',
                      subtitle: 'Produits sauvegardés',
                      onTap: () => Get.to(() => const WishlistScreen()),
                    ),
                    _tile(
                      isDark: isDark,
                      icon: Iconsax.box,
                      title: 'Mes commandes',
                      subtitle: 'Historique et suivi',
                      onTap: () => Get.to(() => const OrderScreen()),
                    ),
                    _tile(
                      isDark: isDark,
                      icon: Iconsax.location,
                      title: 'Mes adresses',
                      subtitle: 'Adresses de livraison',
                      onTap: () => Get.to(() => const UserAddressScreen()),
                    ),
                    const SizedBox(height: 26),
                    _sectionLabel('Préférences'),
                    const SizedBox(height: 10),
                    _tile(
                      isDark: isDark,
                      icon: Iconsax.shield_security,
                      title: 'Sécurité',
                      subtitle: 'Mot de passe et accès',
                      onTap: () =>
                          Get.to(() => const SecuritySettingsScreen()),
                    ),
                    _tile(
                      isDark: isDark,
                      icon: Iconsax.notification,
                      title: 'Notifications',
                      subtitle: 'Gérer vos notifications',
                      onTap: () => Get.to(() => const NotificationsScreen()),
                    ),
                    const SizedBox(height: 36),
                    _logoutButton(isDark),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white24 : Colors.grey[400],
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(UserController controller, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 58, 20, 28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mon profil',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              fontFamily: 'DMSans',
              height: 1.1,
            ),
          ),
          const SizedBox(height: 24),
          Obx(() {
            final user = controller.user.value;
            final networkImage = user.profilePicture;

            return Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : OColors.primary.withValues(alpha: 0.07),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : OColors.primary.withValues(alpha: 0.18),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: networkImage.isNotEmpty
                        ? Image.network(
                            networkImage,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _avatarPlaceholder(user.fullName, 64, isDark),
                          )
                        : _avatarPlaceholder(user.fullName, 64, isDark),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName.trim().isEmpty
                            ? 'Bienvenue !'
                            : user.fullName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color:
                              isDark ? Colors.white : const Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        user.email.isEmpty ? 'Non connecté' : user.email,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.white54
                              : const Color(0xFF888480),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (user.email.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: GestureDetector(
                            onTap: () => Get.to(() => const LoginScreen()),
                            child: Text(
                              'Se connecter →',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white70
                                    : OColors.primary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => Get.to(() => const ProfileScreen()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.07)
                          : const Color(0xFFF8F6F3),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.10)
                            : const Color(0xFFEEEBE6),
                      ),
                    ),
                    child: Text(
                      'Modifier',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.white70
                            : const Color(0xFF4A4542),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: Color(0xFFB0AAA2),
        fontFamily: 'Montserrat',
      ),
    );
  }

  Widget _tile({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : const Color(0xFFEEEBE6),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : OColors.primary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isDark ? Colors.white70 : OColors.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? Colors.white38
                          : const Color(0xFF888480),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Iconsax.arrow_right_3,
              size: 15,
              color: isDark ? Colors.white24 : const Color(0xFFD0CCC8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatarPlaceholder(String name, double size, bool isDark) {
    final parts =
        name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    final initials = parts.isEmpty
        ? ''
        : parts.length == 1
            ? parts[0][0].toUpperCase()
            : '${parts[0][0]}${parts[1][0]}'.toUpperCase();

    return Container(
      width: size,
      height: size,
      color: isDark
          ? Colors.white.withValues(alpha: 0.07)
          : OColors.primary.withValues(alpha: 0.07),
      child: Center(
        child: initials.isNotEmpty
            ? Text(
                initials,
                style: TextStyle(
                  fontSize: size * 0.32,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? Colors.white54
                      : OColors.primary.withValues(alpha: 0.6),
                ),
              )
            : Icon(
                Iconsax.user,
                size: size * 0.42,
                color: isDark
                    ? Colors.white38
                    : OColors.primary.withValues(alpha: 0.4),
              ),
      ),
    );
  }

  Widget _logoutButton(bool isDark) {
    return GestureDetector(
      onTap: () => LoginController.instance.logout(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withValues(alpha: 0.18)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.logout,
              color: Colors.red.withValues(alpha: 0.75),
              size: 17,
            ),
            const SizedBox(width: 8),
            Text(
              'Se déconnecter',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.red.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
